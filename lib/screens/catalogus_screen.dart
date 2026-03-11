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
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../data/catalogus.dart';
import '../models/enums.dart';
import '../models/kabel_spec.dart';
import '../state/custom_catalogus_provider.dart';
import 'kabel_toevoegen_dialog.dart';

class CatalogusScreen extends StatefulWidget {
  const CatalogusScreen({super.key});

  @override
  State<CatalogusScreen> createState() => _CatalogusScreenState();
}

class _CatalogusScreenState extends State<CatalogusScreen> {
  Geleidermateriaal _geleider = Geleidermateriaal.koper;
  Isolatiemateriaal _isolatie = Isolatiemateriaal.pvc;
  int _aders = 5;

  List<(KabelSpec, bool)> _rijen(CustomCatalogusProvider custom) {
    final standaard = standaardDoorsnedes(_geleider);
    final result = <(KabelSpec, bool)>[];

    for (final a in standaard) {
      final key = (_geleider, _isolatie, a, _aders);
      final k = kabelCatalogus[key];
      if (k != null) result.add((k, custom.isCustom(key)));
    }

    for (final k in custom.customKabels) {
      if (k.geleider == _geleider &&
          k.isolatie == _isolatie &&
          k.aantalAders == _aders &&
          !standaard.contains(k.doorsnedemm2)) {
        result.add((k, true));
      }
    }

    result.sort((a, b) => a.$1.doorsnedemm2.compareTo(b.$1.doorsnedemm2));
    return result;
  }

  Future<void> _toevoegen() async {
    final kabel = await showDialog<KabelSpec>(
      context: context,
      builder: (_) => const KabelToevoegenDialog(),
    );
    if (kabel != null && mounted) {
      context.read<CustomCatalogusProvider>().voegToe(kabel);
      setState(() {
        _geleider = kabel.geleider;
        _isolatie = kabel.isolatie;
        _aders = kabel.aantalAders;
      });
    }
  }

  Future<void> _verwijder(KabelSpec kabel) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dlgKabelVerwijderenTitel),
        content: Text(l10n.dlgKabelVerwijderenInhoud(kabel.naam)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.btnVerwijderen)),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<CustomCatalogusProvider>().verwijder(kabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final custom = context.watch<CustomCatalogusProvider>();
    final rijen = _rijen(custom);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sectCatalogus),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.ttKabelToevoegen,
            onPressed: _toevoegen,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Wrap(
              spacing: 24,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _FilterSegment<Geleidermateriaal>(
                  label: l10n.lblFilterGeleider,
                  waarden: Geleidermateriaal.values,
                  geselecteerd: _geleider,
                  naamVan: (g) => g.label,
                  onChanged: (g) => setState(() => _geleider = g),
                ),
                _FilterSegment<Isolatiemateriaal>(
                  label: l10n.lblFilterIsolatie,
                  waarden: const [Isolatiemateriaal.pvc, Isolatiemateriaal.xlpe],
                  geselecteerd: _isolatie,
                  naamVan: (i) => i.label,
                  onChanged: (i) => setState(() => _isolatie = i),
                ),
                _FilterSegment<int>(
                  label: l10n.lblFilterAders,
                  waarden: const [1, 2, 3, 4, 5],
                  geselecteerd: _aders,
                  naamVan: (n) => '$n×',
                  onChanged: (n) => setState(() => _aders = n),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              l10n.catalogusLegenda(_aders),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),

          if (custom.customKabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      border: Border.all(
                          color: theme.colorScheme.tertiary, width: 1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(l10n.lblEigenKabel,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: _buildTabel(theme, rijen, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabel(ThemeData theme, List<(KabelSpec, bool)> rijen, AppLocalizations l10n) {
    final heeftCustom =
        rijen.any((r) => r.$2) || context.read<CustomCatalogusProvider>().customKabels.isNotEmpty;

    return DataTable(
      columnSpacing: 28,
      dataRowMinHeight: 38,
      dataRowMaxHeight: 38,
      headingRowColor: WidgetStateProperty.all(
        theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      ),
      columns: [
        DataColumn(
          label: Tooltip(
            message: l10n.ttDoorsnede,
            child: const Text('A\n(mm²)'),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Tooltip(
            message: l10n.ttAders,
            child: Text(l10n.lblFilterAders),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Tooltip(
            message: l10n.ttRAc,
            child: const Text('R_ac 20°C\n(Ω/km)'),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Tooltip(
            message: l10n.ttX,
            child: const Text('X 50 Hz\n(Ω/km)'),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Tooltip(
            message: l10n.ttIzC,
            child: const Text('I_z C\n(A)'),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Tooltip(
            message: l10n.ttIzE,
            child: const Text('I_z E\n(A)'),
          ),
          numeric: true,
        ),
        DataColumn(
          label: Tooltip(
            message: l10n.ttBuiten,
            child: const Text('⌀ buiten\n(mm)'),
          ),
          numeric: true,
        ),
        if (heeftCustom)
          const DataColumn(label: SizedBox.shrink()),
      ],
      rows: rijen.map((r) {
        final (k, isCustom) = r;
        return DataRow(
          color: WidgetStateProperty.resolveWith((states) {
            if (isCustom) {
              return theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3);
            }
            return null;
          }),
          cells: [
            DataCell(Text(_fmtA(k.doorsnedemm2))),
            DataCell(Text('${k.aantalAders}×')),
            DataCell(Text(k.rAcPerKm20C.toStringAsPrecision(3))),
            DataCell(Text(k.xAcPerKm.toStringAsFixed(3))),
            DataCell(Text(k.izC.toStringAsFixed(0))),
            DataCell(Text(k.izE.toStringAsFixed(0))),
            DataCell(Text(k.buitendiameter.toStringAsFixed(1))),
            if (heeftCustom)
              DataCell(
                isCustom
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: l10n.ttBewerken,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _bewerken(k),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 18,
                                color: theme.colorScheme.error),
                            tooltip: l10n.ttVerwijderen,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _verwijder(k),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _bewerken(KabelSpec kabel) async {
    final nieuw = await showDialog<KabelSpec>(
      context: context,
      builder: (_) => KabelToevoegenDialog(bestaande: kabel),
    );
    if (nieuw != null && mounted) {
      context.read<CustomCatalogusProvider>().verwijder(kabel);
      context.read<CustomCatalogusProvider>().voegToe(nieuw);
    }
  }

  String _fmtA(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ── Filter helper ─────────────────────────────────────────────────────────────

class _FilterSegment<T> extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.waarden,
    required this.geselecteerd,
    required this.naamVan,
    required this.onChanged,
  });

  final String label;
  final List<T> waarden;
  final T geselecteerd;
  final String Function(T) naamVan;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 6),
        SegmentedButton<T>(
          segments: waarden
              .map((w) => ButtonSegment<T>(
                    value: w,
                    label: Text(naamVan(w)),
                  ))
              .toList(),
          selected: {geselecteerd},
          onSelectionChanged: (s) => onChanged(s.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
