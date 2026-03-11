import 'package:flutter/material.dart';
import '../berekening/correctiefactoren.dart';
import '../l10n/app_localizations.dart';
import '../widgets/sectie_card.dart';

class CorrectiefactorenScreen extends StatelessWidget {
  const CorrectiefactorenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.navCorrectiefactoren}  —  IEC 60364-5-52'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bron(context, l10n.uitlegCorrectiefactoren),
            const SizedBox(height: 8),
            _TemperatuurSectie(l10n: l10n),
            const SizedBox(height: 8),
            _BundelingSectie(l10n: l10n),
            const SizedBox(height: 8),
            _StapelingSectie(l10n: l10n),
            const SizedBox(height: 8),
            _BodemweerstandSectie(l10n: l10n),
            const SizedBox(height: 8),
            _CyclischeSectie(l10n: l10n),
            const SizedBox(height: 8),
            _HarmonischenSectie(l10n: l10n),
          ],
        ),
      ),
    );
  }

  Widget _bron(BuildContext context, String tekst) => Text(
        tekst,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.outline),
      );
}

// ── Temperatuurcorrectiefactor ────────────────────────────────────────────────

class _TemperatuurSectie extends StatelessWidget {
  const _TemperatuurSectie({required this.l10n});
  final AppLocalizations l10n;

  static const _tempsPVC = [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
  static const _tempsXLPE = [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.sectTempFactor,
      icoon: Icons.thermostat,
      children: [
        Text(
          'f_T = √[(θ_max − θ_omg) / (θ_max − 30)]   (θ_ref = 30 °C)',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 28,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 34,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: [
              DataColumn(
                label: Tooltip(
                  message: l10n.ttOmgevingstemp,
                  child: const Text('θ_omg\n(°C)'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttPVC,
                  child: const Text('PVC\n70 °C'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttXLPE,
                  child: const Text('XLPE\n90 °C'),
                ),
                numeric: true,
              ),
            ],
            rows: _buildRows(theme),
          ),
        ),
      ],
    );
  }

  List<DataRow> _buildRows(ThemeData theme) {
    final alleTemps = {
      ..._tempsPVC,
      ..._tempsXLPE,
    }.toList()..sort();

    return alleTemps.map((t) {
      final fPVC = _tempsPVC.contains(t)
          ? Correctiefactoren.fTemperatuur(t.toDouble(), 70)
          : null;
      final fXLPE = _tempsXLPE.contains(t)
          ? Correctiefactoren.fTemperatuur(t.toDouble(), 90)
          : null;

      final isRef = t == 30;
      final stijl = isRef
          ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
          : null;

      return DataRow(
        cells: [
          DataCell(Text('$t', style: stijl)),
          DataCell(Text(
            fPVC != null ? fPVC.toStringAsFixed(3) : '—',
            style: stijl ?? _kleurStijl(fPVC, theme),
          )),
          DataCell(Text(
            fXLPE != null ? fXLPE.toStringAsFixed(3) : '—',
            style: stijl ?? _kleurStijl(fXLPE, theme),
          )),
        ],
      );
    }).toList();
  }

  TextStyle? _kleurStijl(double? f, ThemeData theme) {
    if (f == null) return null;
    if (f < 0.80) return TextStyle(color: theme.colorScheme.error);
    if (f > 1.05) return TextStyle(color: theme.colorScheme.primary);
    return null;
  }
}

// ── Horizontale bundeling ─────────────────────────────────────────────────────

class _BundelingSectie extends StatelessWidget {
  const _BundelingSectie({required this.l10n});
  final AppLocalizations l10n;

  static const _nWaarden = [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16, 20];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.sectBundelingFactor,
      icoon: Icons.cable,
      children: [
        Text(
          l10n.uitlegBundeling,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 32,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 34,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: [
              DataColumn(
                label: Tooltip(
                  message: l10n.ttNKabels,
                  child: const Text('n kabels'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttReductiefactor,
                  child: const Text('f_bundel'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttEffectief,
                  child: const Text('% van I_z0'),
                ),
                numeric: true,
              ),
            ],
            rows: _nWaarden.map((n) {
              final f = Correctiefactoren.fHorizontaalBundeling(n);
              final isEen = n == 1;
              final stijl = isEen
                  ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                  : null;
              return DataRow(cells: [
                DataCell(Text('$n', style: stijl)),
                DataCell(Text(f.toStringAsFixed(2), style: stijl)),
                DataCell(Text('${(f * 100).toStringAsFixed(0)} %', style: stijl)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Verticale stapeling ───────────────────────────────────────────────────────

class _StapelingSectie extends StatelessWidget {
  const _StapelingSectie({required this.l10n});
  final AppLocalizations l10n;

  static const _lagen = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.sectStapelingFactor,
      icoon: Icons.layers,
      children: [
        Text(
          l10n.uitlegStapeling,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 32,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 34,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: [
              DataColumn(
                label: Tooltip(
                  message: l10n.ttNLagen,
                  child: const Text('n lagen'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttReductiefactorStapel,
                  child: const Text('f_stapel'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: const Text('% van I_z0'),
                numeric: true,
              ),
            ],
            rows: _lagen.map((n) {
              final f = Correctiefactoren.fVerticalStapeling(n);
              final isEen = n == 1;
              final stijl = isEen
                  ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                  : null;
              return DataRow(cells: [
                DataCell(Text('$n', style: stijl)),
                DataCell(Text(f.toStringAsFixed(2), style: stijl)),
                DataCell(Text('${(f * 100).toStringAsFixed(0)} %', style: stijl)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Bodemthermische weerstand ─────────────────────────────────────────────────

class _BodemweerstandSectie extends StatelessWidget {
  const _BodemweerstandSectie({required this.l10n});
  final AppLocalizations l10n;

  static const _lambdas = [0.5, 0.7, 1.0, 1.2, 1.5, 2.0, 2.5];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.sectBodemweerstand,
      icoon: Icons.terrain,
      children: [
        Text(
          l10n.uitlegBodem,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 32,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 34,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: [
              DataColumn(
                label: Tooltip(
                  message: l10n.ttLambda,
                  child: const Text('λ grond\n(K·m/W)'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttFgrond,
                  child: const Text('f_grond'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(l10n.ttGrondsoort),
              ),
            ],
            rows: _lambdas.map((lam) {
              final f = Correctiefactoren.fBodemweerstand(lam);
              final isRef = lam == 1.0;
              final stijl = isRef
                  ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                  : null;
              return DataRow(cells: [
                DataCell(Text(lam.toStringAsFixed(1), style: stijl)),
                DataCell(Text(f.toStringAsFixed(2), style: stijl)),
                DataCell(Text(l10n.grondsoortLabel(lam), style: stijl)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Cyclische belastingsfactor ─────────────────────────────────────────────────

class _CyclischeSectie extends StatelessWidget {
  const _CyclischeSectie({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.sectCyclischFactor,
      icoon: Icons.bar_chart,
      children: [
        Text(
          l10n.uitlegCyclisch,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 10),
        Text(
          'M = 1 / √[ Σᵢ₌₁⁶ Yᵢ·ΔθR(i)  +  μ·(1 − θR(6)) ]',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.lblInvoerparameters, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        ...[
          (l10n.cyclischBelastingsprofiel, '24 ${l10n.cyclischBelastingsprofiel.toLowerCase()}  I/Imax  (0,0 – 1,0)'),
          (l10n.cyclischLegdiepte, l10n.cyclischAfstandKabelhart),
          (l10n.cyclischBodemweerstand, l10n.cyclischBodemweerstandEenheid),
          (l10n.cyclischKabeldiameter, l10n.cyclischKabeldiameterEenheid),
          (l10n.cyclischJoule, l10n.cyclischJouleEenheid),
          (l10n.cyclischNKringen, l10n.cyclischNKringenEenheid),
          (l10n.cyclischLigging, l10n.cyclischLiggingEenheid),
        ].map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 148,
                    child: Text(r.$1,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ),
                  Expanded(child: Text(r.$2, style: theme.textTheme.bodySmall)),
                ],
              ),
            )),
        const SizedBox(height: 10),
        Text(l10n.cyclischTypischeTitel, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 28,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 30,
            headingRowHeight: 34,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: [
              DataColumn(label: Text(l10n.cyclischColProfiel)),
              const DataColumn(label: Text('Piek\nI/Imax'), numeric: true),
              const DataColumn(label: Text('μ\n(gem. Yi)'), numeric: true),
              const DataColumn(label: Text('M\n(indicatief)'), numeric: true),
            ],
            rows: [
              _mRij(theme, 'Continu (1,0)', 1.00, 1.000, 1.00, l10n),
              _mRij(theme, 'IEC dagprofiel', 1.00, 0.378, 1.12, l10n),
              _mRij(theme, 'Nacht-piek', 1.00, 0.250, 1.18, l10n),
              _mRij(theme, 'Laag (0,5 max)', 0.50, 0.094, 1.41, l10n),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(l10n.cyclischMworden, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  DataRow _mRij(ThemeData theme, String naam, double piek, double mu, double m, AppLocalizations l10n) {
    final isRef = naam.startsWith('Continu');
    final stijl = isRef
        ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
        : null;
    return DataRow(cells: [
      DataCell(Text(l10n.cyclischProfielNaam(naam), style: stijl)),
      DataCell(Text(piek.toStringAsFixed(2), style: stijl)),
      DataCell(Text(mu.toStringAsFixed(3), style: stijl)),
      DataCell(Text(m.toStringAsFixed(2), style: stijl)),
    ]);
  }
}

// ── Harmonischencorrectie ──────────────────────────────────────────────────────

class _HarmonischenSectie extends StatelessWidget {
  const _HarmonischenSectie({required this.l10n});
  final AppLocalizations l10n;

  static const _h3Waarden = [0, 10, 15, 20, 25, 30, 33, 35, 40, 45, 50, 60, 75, 100];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.sectHarmonischenFactor,
      icoon: Icons.waves,
      children: [
        Text(
          l10n.uitlegHarmonischen,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 34,
            headingRowHeight: 38,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: [
              DataColumn(
                label: Tooltip(
                  message: l10n.ttH3,
                  child: const Text('h₃\n(%)'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttFharm,
                  child: const Text('f_harm'),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttGrondslag,
                  child: Text(l10n.ttGrondslag.split(' ').first),
                ),
              ),
              DataColumn(
                label: Tooltip(
                  message: l10n.ttINFase,
                  child: const Text('I_N / I_fase'),
                ),
                numeric: true,
              ),
            ],
            rows: _h3Waarden.map((h3) {
              final res = Correctiefactoren.fHarmonischen(1.0, h3.toDouble());
              final opNul = res.iDesign == res.iNeutraal;
              final grondslag = opNul ? l10n.harmNulpuntsstroom2 : l10n.harmFasestroom2;
              final iNRatio = 3.0 * h3 / 100.0;

              final isZone1 = h3 <= 15;
              final isOvergang = h3 == 33 || h3 == 45;
              final stijl = isZone1
                  ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                  : isOvergang
                      ? TextStyle(color: theme.colorScheme.tertiary)
                      : opNul
                          ? TextStyle(color: theme.colorScheme.error)
                          : null;

              return DataRow(cells: [
                DataCell(Text('$h3', style: stijl)),
                DataCell(Text(res.fHarm.toStringAsFixed(2), style: stijl)),
                DataCell(Text(grondslag, style: stijl)),
                DataCell(Text(
                  iNRatio > 0 ? iNRatio.toStringAsFixed(2) : '—',
                  style: stijl,
                )),
              ]);
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        _legenda(theme),
      ],
    );
  }

  Widget _legenda(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _legendaItem(theme, theme.colorScheme.primary, l10n.legendH3Zone1),
        _legendaItem(theme, null, l10n.legendH3Zone2),
        _legendaItem(theme, theme.colorScheme.tertiary, l10n.legendH3Grens),
        _legendaItem(theme, theme.colorScheme.error, l10n.legendH3NulNul),
      ],
    );
  }

  Widget _legendaItem(ThemeData theme, Color? kleur, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: (kleur ?? theme.colorScheme.onSurface).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
