import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/transformatoren.dart';
import '../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../state/language_provider.dart';
import '../models/kabel_boom.dart';
import '../models/leiding_node.dart';
import '../state/berekening_provider.dart';
import '../state/boom_provider.dart';
import '../widgets/invoer_rij.dart';
import '../widgets/sectie_card.dart';
import 'invoer_screen.dart';
import 'resultaten_screen.dart';

class BoomScreen extends StatefulWidget {
  const BoomScreen({super.key});

  @override
  State<BoomScreen> createState() => _BoomScreenState();
}

class _BoomScreenState extends State<BoomScreen> {
  late void Function() _berekeningListener;

  /// l10n veilig vanuit event handlers (listen: false — geen abonnement).
  AppLocalizations get _l10n =>
      AppLocalizations(context.read<LanguageProvider>().locale);

  @override
  void initState() {
    super.initState();
    _berekeningListener = _onBerekeningChange;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BerekeningProvider>().addListener(_berekeningListener);
      context.read<BerekeningProvider>().setIsBoomModus(true);
    });
  }

  @override
  void dispose() {
    context.read<BerekeningProvider>().removeListener(_berekeningListener);
    context.read<BerekeningProvider>().setIsBoomModus(false);
    super.dispose();
  }

  void _onBerekeningChange() {
    final berP = context.read<BerekeningProvider>();
    final boomP = context.read<BoomProvider>();
    final nodeId = boomP.actiefNodeId;
    if (nodeId != null && berP.resultaten != null) {
      boomP.opslaanNodeResultaten(nodeId, berP.invoer, berP.resultaten!);
    }
  }

  void _selecteerNode(String nodeId) {
    final boomP = context.read<BoomProvider>();
    final berP = context.read<BerekeningProvider>();
    boomP.setActiefNode(nodeId);
    berP.berekenMet(boomP.invoerVoorNode(nodeId));
  }

  Future<void> _voegRootToe() async {
    final boomP = context.read<BoomProvider>();
    final naam = await _vraagNaam(context, _l10n.btnVoegLeidingToe);
    if (naam == null) return;
    final id = await boomP.voegNodeToe(naam: naam);
    _selecteerNode(id);
  }

  Future<void> _voegKindToe(String parentId) async {
    final boomP = context.read<BoomProvider>();
    // Controleer of ouder berekend is.
    final parent = boomP.nodeById(parentId);
    if (parent?.resultaten?.ik1fEindA == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.lblNodenvereistBerekening)),
        );
      }
      return;
    }
    final naam = await _vraagNaam(context, _l10n.btnVoegKindToe);
    if (naam == null) return;
    final id = await boomP.voegNodeToe(parentId: parentId, naam: naam);
    _selecteerNode(id);
  }

  Future<void> _verwijderNode(String nodeId) async {
    final boomP = context.read<BoomProvider>();
    final node = boomP.nodeById(nodeId);
    if (node == null) return;
    final l = _l10n;
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.lblLeidingNaam),
        content: Text('"${node.naam}" verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (bevestigd == true) {
      await boomP.verwijderNode(nodeId);
    }
  }

  Future<String?> _vraagNaam(BuildContext ctx, String titel) async {
    final controller = TextEditingController(text: 'Leiding');
    final labelTekst = _l10n.lblLeidingNaam;
    return showDialog<String>(
      context: ctx,
      builder: (dlgCtx) => AlertDialog(
        title: Text(titel),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: labelTekst,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) =>
              Navigator.pop(dlgCtx, controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dlgCtx, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final boomP = context.watch<BoomProvider>();
    final boom = boomP.boom;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(boom != null
              ? '${l10n.titBoomScreen}: ${boom.naam}'
              : l10n.titBoomScreen),
          actions: [
            if (boom != null) ...[
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.btnHerberekenAlles,
                onPressed: () => boomP.herberekenAlles(),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.lblBoomTransformator,
                onPressed: () => _toonBronConfigDialog(context, boom),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.btnVerwijderBoom,
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.btnVerwijderBoom),
                      content: Text(boom.naam),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Annuleren'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Verwijderen'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) await boomP.verwijderBoom();
                },
              ),
            ],
          ],
        ),
        body: boom == null
            ? _geenBoom(l10n)
            : _boomLayout(context, boomP, boom),
      ),
    );
  }

  Widget _geenBoom(AppLocalizations l10n) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.lblGeenBoom,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.btnNieuwKabelnet),
              onPressed: () => _maakNieuwKabelnet(context),
            ),
          ],
        ),
      );

  Future<void> _maakNieuwKabelnet(BuildContext ctx) async {
    final titel = _l10n.btnNieuwKabelnet;
    final naam = await _vraagNaam(ctx, titel);
    if (naam == null || naam.isEmpty) return;
    if (!mounted) return;
    await context.read<BoomProvider>().maakNieuweBoom(naam);
  }

  Widget _boomLayout(
      BuildContext context, BoomProvider boomP, KabelBoom boom) {
    final actiefId = boomP.actiefNodeId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Boom-paneel (links, vaste breedte) ─────────────────────────────
        SizedBox(
          width: 280,
          child: Material(
            elevation: 1,
            child: Column(
              children: [
                // Bron-info header
                _bronHeader(context, boom),
                const Divider(height: 1),
                // Boom-nodes
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    children: [
                      ...boomP
                          .rootNodes()
                          .map((n) => _nodeItem(context, boomP, n, 0)),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(context.l10n.btnVoegLeidingToe),
                          onPressed: _voegRootToe,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        // ── Detail-paneel (rechts) ─────────────────────────────────────────
        if (actiefId == null)
          Expanded(child: _geenSelectie(context.l10n))
        else ...[
          SizedBox(
            width: 430,
            child: Material(
              elevation: 1,
              child: const InvoerScreen(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          const Expanded(child: ResultatenScreen()),
        ],
      ],
    );
  }

  Widget _bronHeader(BuildContext context, KabelBoom boom) {
    final l10n = context.l10n;
    final zb = boom.zbOhm(400);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bolt, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.lblBoomTransformator,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            '${boom.transformatorKva.toInt()} kVA  —  '
            'u_cc = ${boom.transformatorUccPct.toStringAsFixed(0)}%  —  '
            '${boom.aardingsstelsel.code}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (zb > 0)
            Text(
              'Z_b = ${(zb * 1000).toStringAsFixed(2)} mΩ'
              '  |  I_k3f = ${(boom.ik3fBron(400) / 1000).toStringAsFixed(1)} kA',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _nodeItem(
      BuildContext context, BoomProvider boomP, LeidingNode node, int depth) {
    final actiefId = boomP.actiefNodeId;
    final kinderen =
        boomP.childrenVan(node.id);
    final res = node.resultaten;
    final ik1f = res?.ik1fEindA;

    Color? statusKleur;
    IconData statusIcon;
    if (res == null) {
      statusKleur = Colors.grey;
      statusIcon = Icons.help_outline;
    } else if (res.voldoet && ik1f != null && ik1f >= 100) {
      statusKleur = Colors.green.shade700;
      statusIcon = Icons.check_circle_outline;
    } else {
      statusKleur = Colors.orange.shade700;
      statusIcon = Icons.warning_amber_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          selected: node.id == actiefId,
          selectedTileColor:
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
          contentPadding: EdgeInsets.only(
              left: 12.0 + depth * 20, right: 4),
          leading: Icon(statusIcon, size: 18, color: statusKleur),
          title: Text(node.naam,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: ik1f != null
              ? Text(context.l10n.ikEindInfo(ik1f.toStringAsFixed(0)),
                  style: TextStyle(color: statusKleur, fontSize: 11))
              : Text(context.l10n.lblNietBerekend,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
          onTap: () => _selecteerNode(node.id),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.account_tree_outlined, size: 16),
                tooltip: context.l10n.btnVoegKindToe,
                onPressed: () => _voegKindToe(node.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                tooltip: 'Verwijderen',
                onPressed: () => _verwijderNode(node.id),
              ),
            ],
          ),
        ),
        // Kinderen recursief
        ...kinderen.map((k) => _nodeItem(context, boomP, k, depth + 1)),
      ],
    );
  }

  Widget _geenSelectie(AppLocalizations l10n) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.lblSelecteerNode,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );

  // ── Bron-config dialoog ───────────────────────────────────────────────────

  void _toonBronConfigDialog(BuildContext context, KabelBoom boom) {
    showDialog(
      context: context,
      builder: (ctx) => _BronConfigDialog(boom: boom),
    );
  }
}

// ── Dialoog: bronimpedantie-instellingen voor de boom ─────────────────────────

class _BronConfigDialog extends StatefulWidget {
  const _BronConfigDialog({required this.boom});
  final KabelBoom boom;

  @override
  State<_BronConfigDialog> createState() => _BronConfigDialogState();
}

class _BronConfigDialogState extends State<_BronConfigDialog> {
  late bool _handmatig;
  late double _kva;
  late double _ucc;
  late Aardingsstelsel _stelsel;
  late bool _skOneindig;
  late double _skMva;
  int _dbIndex = 3;

  @override
  void initState() {
    super.initState();
    final b = widget.boom;
    _handmatig = b.transformatorHandmatig;
    _kva = b.transformatorKva;
    _ucc = b.transformatorUccPct;
    _stelsel = b.aardingsstelsel;
    _skOneindig = b.skNetOneindig;
    _skMva = b.skNetMva;
    _dbIndex = transformatorDatabase.indexWhere(
        (t) => t.vermogenKva == _kva && t.uccPct == _ucc);
    if (_dbIndex < 0) _dbIndex = 3;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.lblBoomTransformator),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SectieCard(
                titel: l10n.sectBronimpedantie,
                icoon: Icons.transform,
                children: [
                  SchakelaarRij(
                    label: l10n.lblTransformatorHandmatig,
                    waarde: _handmatig,
                    onChanged: (v) => setState(() {
                      _handmatig = v;
                      if (!v) {
                        _kva = transformatorDatabase[_dbIndex].vermogenKva;
                        _ucc = transformatorDatabase[_dbIndex].uccPct;
                      }
                    }),
                  ),
                  const SizedBox(height: 4),
                  if (!_handmatig)
                    DropdownRij<TransformatorSpec>(
                      label: l10n.lblTransformatorSelectie,
                      waarde: transformatorDatabase[_dbIndex],
                      opties: transformatorDatabase,
                      display: (t) => t.naam,
                      onChanged: (t) => setState(() {
                        _dbIndex = transformatorDatabase.indexOf(t);
                        _kva = t.vermogenKva;
                        _ucc = t.uccPct;
                      }),
                    )
                  else ...[
                    GetalVeld(
                      label: l10n.lblTransformatorKva,
                      eenheid: 'kVA',
                      waarde: _kva,
                      onChanged: (v) => setState(() => _kva = v),
                      min: 10,
                      max: 10000,
                      decimalen: 0,
                    ),
                    const SizedBox(height: 4),
                    GetalVeld(
                      label: l10n.lblTransformatorUcc,
                      eenheid: '%',
                      waarde: _ucc,
                      onChanged: (v) => setState(() => _ucc = v),
                      min: 0.5,
                      max: 20,
                      decimalen: 1,
                    ),
                  ],
                  const SizedBox(height: 4),
                  DropdownRij<Aardingsstelsel>(
                    label: l10n.lblAardingsstelsel,
                    waarde: _stelsel,
                    opties: Aardingsstelsel.values,
                    display: (s) => s.label,
                    onChanged: (v) => setState(() => _stelsel = v),
                  ),
                  const SizedBox(height: 4),
                  SchakelaarRij(
                    label: l10n.lblSkNetOneindig,
                    waarde: _skOneindig,
                    onChanged: (v) => setState(() => _skOneindig = v),
                  ),
                  if (!_skOneindig) ...[
                    const SizedBox(height: 4),
                    GetalVeld(
                      label: l10n.lblSkNetAangepast,
                      eenheid: 'MVA',
                      waarde: _skMva,
                      onChanged: (v) => setState(() => _skMva = v),
                      min: 0.1,
                      max: 10000,
                      decimalen: 1,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () {
            final nieuw = widget.boom.copyWith(
              transformatorHandmatig: _handmatig,
              transformatorKva: _kva,
              transformatorUccPct: _ucc,
              aardingsstelsel: _stelsel,
              skNetOneindig: _skOneindig,
              skNetMva: _skMva,
            );
            context.read<BoomProvider>().updateBoomConfig(nieuw);
            Navigator.pop(context);
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
