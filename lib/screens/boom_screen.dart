// Copyright (C) 2026 Jay Smeekes
//
// This file is part of MijnKabelberekening.
//
// MijnKabelberekening is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MijnKabelberekening is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MijnKabelberekening. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../berekening/rapport.dart';
import '../berekening/pdf_rapport.dart';
import '../data/transformatoren.dart';
import '../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../models/project.dart';
import '../state/language_provider.dart';
import '../models/kabel_boom.dart';
import '../models/leiding_node.dart';
import '../state/berekening_provider.dart';
import '../state/boom_provider.dart';
import '../state/projecten_provider.dart';
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
  late BerekeningProvider _berekeningProvider;

  /// l10n veilig vanuit event handlers (listen: false — geen abonnement).
  AppLocalizations get _l10n =>
      AppLocalizations(context.read<LanguageProvider>().locale);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _berekeningProvider = context.read<BerekeningProvider>();
  }

  @override
  void initState() {
    super.initState();
    _berekeningListener = _onBerekeningChange;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _berekeningProvider.addListener(_berekeningListener);
      _berekeningProvider.setIsBoomModus(true);
    });
  }

  @override
  void dispose() {
    _berekeningProvider.removeListener(_berekeningListener);
    // setIsBoomModus roept notifyListeners aan — uitstellen tot na het frame
    // om "widget tree locked" te voorkomen tijdens unmount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _berekeningProvider.setIsBoomModus(false);
    });
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
                icon: const Icon(Icons.stacked_bar_chart),
                tooltip: l10n.tooltipSpanningsverliesOverzicht,
                onPressed: () => _toonSpanningsverliesOverzicht(context, boomP),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.btnHerberekenAlles,
                onPressed: () => boomP.herberekenAlles(),
              ),
              IconButton(
                icon: const Icon(Icons.save_outlined),
                tooltip: l10n.boomSlaOpInProject,
                onPressed: () => _slaOpInProject(context, boom),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                tooltip: l10n.btnRapportKopieren,
                onPressed: () => _kopieerRapport(context, boom),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: l10n.btnRapportPdf,
                onPressed: () => _pdfRapport(context, boom),
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

  Future<void> _pdfRapport(BuildContext ctx, KabelBoom boom) async {
    final l10n = AppLocalizations(ctx.read<LanguageProvider>().locale);
    final pdfBytes = await boomRapportPdf(boom, l10n);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${boom.naam}.pdf',
    );
  }

  void _kopieerRapport(BuildContext ctx, KabelBoom boom) {
    final l10n = AppLocalizations(ctx.read<LanguageProvider>().locale);
    final tekst = boomRapportTekst(boom, l10n);
    Clipboard.setData(ClipboardData(text: tekst));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(l10n.snackBoomRapportGekopieerd),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _slaOpInProject(BuildContext ctx, KabelBoom boom) async {
    final projectenP = context.read<ProjectenProvider>();
    final projecten = projectenP.projecten;
    if (projecten.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.projectenLeeg)),
        );
      }
      return;
    }

    final gekozen = await showDialog<Project>(
      context: ctx,
      builder: (dlgCtx) => SimpleDialog(
        title: Text(_l10n.boomSlaOpInProject),
        children: projecten
            .map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(dlgCtx, p),
                  child: Text(p.naam),
                ))
            .toList(),
      ),
    );
    if (gekozen == null || !mounted) return;

    await projectenP.voegBoomToe(gekozen.id, boom.naam, boom);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${boom.naam} → ${gekozen.naam}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bron-instellingen inline
                  _BronImpedantiePaneel(boom: boom),
                  const Divider(height: 1),
                  // Boom-nodes
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
                  const SizedBox(height: 8),
                ],
              ),
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

  // ── Spanningsverlies overzicht ────────────────────────────────────────────

  /// Berekent cumulatief spanningsverlies (V en %) voor elke node via DFS,
  /// zodat elke root zijn subtree aaneengesloten toont.
  /// [isNieuweGroep] is true voor elke root behalve de eerste — voor visuele scheiding.
  List<_SpanningsVerliesRij> _cumulatiefVerlies(BoomProvider boomP) {
    final result = <_SpanningsVerliesRij>[];
    if (boomP.boom == null) return result;

    // Multiplicatieve aanpak: U_rest = U_rest × (1 − ΔU%/100) per segment.
    // Cumulatief verlies = (1 − U_rest) × 100%.
    // Dit is correct omdat elke ΔU% relatief is aan de spanning aan het begin
    // van dat segment, niet aan de nominale spanning.
    void dfs(LeidingNode node, double cumV, double uRest, int depth,
        bool isNieuweGroep) {
      final res = node.resultaten;
      final nodeURest = uRest * (1.0 - (res?.deltaUPct ?? 0.0) / 100.0);
      final nodeCumV = cumV + (res?.deltaUV ?? 0.0);
      final nodeCumPct = (1.0 - nodeURest) * 100.0;
      result.add(_SpanningsVerliesRij(
        node: node,
        segmentV: res?.deltaUV,
        segmentPct: res?.deltaUPct,
        cumulatiefV: res != null ? nodeCumV : null,
        cumulatiefPct: res != null ? nodeCumPct : null,
        depth: depth,
        isNieuweGroep: isNieuweGroep,
      ));
      for (final kind in boomP.childrenVan(node.id)) {
        dfs(kind, nodeCumV, nodeURest, depth + 1, false);
      }
    }

    final roots = boomP.rootNodes();
    for (var i = 0; i < roots.length; i++) {
      dfs(roots[i], 0.0, 1.0, 0, i > 0);
    }
    return result;
  }

  void _toonSpanningsverliesOverzicht(BuildContext ctx, BoomProvider boomP) {
    final l10n = AppLocalizations(ctx.read<LanguageProvider>().locale);
    final rijen = _cumulatiefVerlies(boomP);
    const limietPct = 5.0;

    showDialog<void>(
      context: ctx,
      builder: (dlgCtx) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  children: [
                    const Icon(Icons.stacked_bar_chart),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.titSpanningsverliesOverzicht,
                        style: Theme.of(dlgCtx).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dlgCtx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Text(
                  l10n.lblMaxSpanningsverliesBoom,
                  style: Theme.of(dlgCtx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(dlgCtx).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const Divider(height: 1),
              // Kolomkoppen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: Text('Leiding',
                          style: Theme.of(dlgCtx).textTheme.labelSmall),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(l10n.lblSegment,
                          style: Theme.of(dlgCtx).textTheme.labelSmall,
                          textAlign: TextAlign.right),
                    ),
                    SizedBox(
                      width: 110,
                      child: Text(l10n.lblCumulatief,
                          style: Theme.of(dlgCtx)
                              .textTheme
                              .labelSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Rijen
              Flexible(
                child: rijen.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(l10n.lblNietAlleBerekend,
                              style: const TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: rijen.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final rij = rijen[i];
                          final cumPct = rij.cumulatiefPct;
                          final cumV = rij.cumulatiefV;
                          final segPct = rij.segmentPct;
                          final segV = rij.segmentV;
                          final heeftData = cumPct != null;

                          Color statusKleur;
                          if (!heeftData) {
                            statusKleur = Colors.grey;
                          } else if (cumPct > limietPct) {
                            statusKleur = Colors.red.shade700;
                          } else if (cumPct > limietPct * 0.8) {
                            statusKleur = Colors.orange.shade700;
                          } else {
                            statusKleur = Colors.green.shade700;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (rij.isNieuweGroep)
                                const Divider(height: 12, thickness: 2, indent: 0, endIndent: 0),
                              Padding(
                            padding: EdgeInsets.only(
                              left: 16.0 + rij.depth * 16,
                              right: 16,
                              top: 6,
                              bottom: 6,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  heeftData
                                      ? (cumPct > limietPct
                                          ? Icons.warning_amber_outlined
                                          : Icons.check_circle_outline)
                                      : Icons.help_outline,
                                  size: 16,
                                  color: statusKleur,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    rij.node.naam,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: heeftData && segV != null && segPct != null
                                      ? Text(
                                          '${segV.toStringAsFixed(1)} V\n${segPct.toStringAsFixed(2)} %',
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.right,
                                        )
                                      : Text(
                                          '—',
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.grey),
                                          textAlign: TextAlign.right,
                                        ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: heeftData
                                      ? RichText(
                                          textAlign: TextAlign.right,
                                          text: TextSpan(
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: statusKleur),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${cumV!.toStringAsFixed(1)} V\n'),
                                              TextSpan(
                                                  text:
                                                      '${cumPct.toStringAsFixed(2)} %'),
                                            ],
                                          ),
                                        )
                                      : Text(
                                          '—',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                          textAlign: TextAlign.right,
                                        ),
                                ),
                              ],
                            ),
                          ),
                            ],
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  rijen.any((r) => r.cumulatiefPct == null)
                      ? l10n.lblNietAlleBerekend
                      : rijen.any((r) => (r.cumulatiefPct ?? 0) > limietPct)
                          ? '⚠ ${rijen.where((r) => (r.cumulatiefPct ?? 0) > limietPct).length} leiding(en) overschrijden de 5%-grens.'
                          : l10n.lblAlleLeidingenOk,
                  style: Theme.of(dlgCtx).textTheme.bodySmall?.copyWith(
                        color: rijen.any((r) => (r.cumulatiefPct ?? 0) > limietPct)
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
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

}

// ── Hulpklasse voor het spanningsverlies-overzicht ────────────────────────────

class _SpanningsVerliesRij {
  final LeidingNode node;
  final double? segmentV;
  final double? segmentPct;
  final double? cumulatiefV;
  final double? cumulatiefPct;
  final int depth;
  final bool isNieuweGroep;

  const _SpanningsVerliesRij({
    required this.node,
    required this.segmentV,
    required this.segmentPct,
    required this.cumulatiefV,
    required this.cumulatiefPct,
    required this.depth,
    this.isNieuweGroep = false,
  });
}

// ── Inline bronimpedantie-paneel voor de kabelnet-boom ────────────────────────

class _BronImpedantiePaneel extends StatefulWidget {
  const _BronImpedantiePaneel({required this.boom});
  final KabelBoom boom;

  @override
  State<_BronImpedantiePaneel> createState() => _BronImpedantiePaneelState();
}

class _BronImpedantiePaneelState extends State<_BronImpedantiePaneel> {
  late bool _rxHandmatig;
  late double _zbR;
  late double _zbX;
  late bool _trafoHandmatig;
  late double _kva;
  late double _ucc;
  late Aardingsstelsel _stelsel;
  late bool _skOneindig;
  late double _skMva;
  int _dbIndex = 3;

  @override
  void initState() {
    super.initState();
    _initVanBoom(widget.boom);
  }

  @override
  void didUpdateWidget(_BronImpedantiePaneel old) {
    super.didUpdateWidget(old);
    // Herinitialiseer alleen bij een ander kabelnet (ander id).
    if (old.boom.id != widget.boom.id) {
      _initVanBoom(widget.boom);
    }
  }

  void _initVanBoom(KabelBoom b) {
    _rxHandmatig = b.zbRxHandmatig;
    _zbR = b.zbROhm;
    _zbX = b.zbXOhm;
    _trafoHandmatig = b.transformatorHandmatig;
    _kva = b.transformatorKva;
    _ucc = b.transformatorUccPct;
    _stelsel = b.aardingsstelsel;
    _skOneindig = b.skNetOneindig;
    _skMva = b.skNetMva;
    _dbIndex = transformatorDatabase.indexWhere(
        (t) => t.vermogenKva == _kva && t.uccPct == _ucc);
    if (_dbIndex < 0) _dbIndex = 3;
  }

  void _bewaar() {
    final nieuw = widget.boom.copyWith(
      zbRxHandmatig: _rxHandmatig,
      zbROhm: _zbR,
      zbXOhm: _zbX,
      transformatorHandmatig: _trafoHandmatig,
      transformatorKva: _kva,
      transformatorUccPct: _ucc,
      aardingsstelsel: _stelsel,
      skNetOneindig: _skOneindig,
      skNetMva: _skMva,
    );
    context.read<BoomProvider>().updateBoomConfig(nieuw);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final boom = widget.boom;
    final zb = boom.zbOhm(400);

    return SectieCard(
      titel: l10n.sectBronimpedantie,
      icoon: Icons.transform,
      children: [
        // R + X handmatige invoer toggle
        SchakelaarRij(
          label: l10n.lblZbRxHandmatig,
          waarde: _rxHandmatig,
          onChanged: (v) {
            setState(() {
              _rxHandmatig = v;
              if (v) { _zbR = 0.010; _zbX = 0.038; }
            });
            _bewaar();
          },
        ),
        if (_rxHandmatig) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblZbR,
            eenheid: 'mΩ',
            waarde: _zbR * 1000,
            onChanged: (v) { setState(() => _zbR = v / 1000); _bewaar(); },
            min: 0.01,
            max: 10000,
            decimalen: 2,
          ),
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblZbX,
            eenheid: 'mΩ',
            waarde: _zbX * 1000,
            onChanged: (v) { setState(() => _zbX = v / 1000); _bewaar(); },
            min: 0.01,
            max: 10000,
            decimalen: 2,
          ),
        ] else ...[
          const SizedBox(height: 4),
          // Transformatorselectie toggle
          SchakelaarRij(
            label: l10n.lblTransformatorHandmatig,
            waarde: _trafoHandmatig,
            onChanged: (v) {
              setState(() {
                _trafoHandmatig = v;
                if (!v) {
                  _kva = transformatorDatabase[_dbIndex].vermogenKva;
                  _ucc = transformatorDatabase[_dbIndex].uccPct;
                }
              });
              _bewaar();
            },
          ),
          const SizedBox(height: 4),
          if (!_trafoHandmatig)
            DropdownRij<TransformatorSpec>(
              label: l10n.lblTransformatorSelectie,
              waarde: transformatorDatabase[_dbIndex],
              opties: transformatorDatabase,
              display: (t) => t.naam,
              onChanged: (t) {
                setState(() {
                  _dbIndex = transformatorDatabase.indexOf(t);
                  _kva = t.vermogenKva;
                  _ucc = t.uccPct;
                });
                _bewaar();
              },
            )
          else ...[
            GetalVeld(
              label: l10n.lblTransformatorKva,
              eenheid: 'kVA',
              waarde: _kva,
              onChanged: (v) { setState(() => _kva = v); _bewaar(); },
              min: 10,
              max: 10000,
              decimalen: 0,
            ),
            const SizedBox(height: 4),
            GetalVeld(
              label: l10n.lblTransformatorUcc,
              eenheid: '%',
              waarde: _ucc,
              onChanged: (v) { setState(() => _ucc = v); _bewaar(); },
              min: 0.5,
              max: 20,
              decimalen: 1,
            ),
          ],
        ],

        const SizedBox(height: 4),

        // Aardingsstelsel
        DropdownRij<Aardingsstelsel>(
          label: l10n.lblAardingsstelsel,
          waarde: _stelsel,
          opties: Aardingsstelsel.values,
          display: (s) => s.label,
          onChanged: (v) { setState(() => _stelsel = v); _bewaar(); },
        ),

        // NEN 1010 hint per stelsel
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 2, bottom: 4),
          child: Text(
            l10n.aardingsstelselHint(_stelsel.code),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _stelsel == Aardingsstelsel.it ||
                          _stelsel == Aardingsstelsel.tt
                      ? Colors.orange.shade800
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),

        // Netwerk kortsluitvermogen
        SchakelaarRij(
          label: l10n.lblSkNetOneindig,
          waarde: _skOneindig,
          onChanged: (v) { setState(() => _skOneindig = v); _bewaar(); },
        ),
        if (!_skOneindig) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblSkNetAangepast,
            eenheid: 'MVA',
            waarde: _skMva,
            onChanged: (v) { setState(() => _skMva = v); _bewaar(); },
            min: 0.1,
            max: 10000,
            decimalen: 1,
          ),
        ],

        // Zb en Ik_bron samenvatting
        if (zb > 0) ...[
          const Divider(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              l10n.zbBerekend((zb * 1000).toStringAsFixed(2)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 2),
            child: Text(
              l10n.ikBronInfo(boom.ik3fBron(400).toStringAsFixed(0)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}
