import 'package:flutter/material.dart';
import '../widgets/sectie_card.dart';
import '../l10n/app_localizations.dart';
import '../l10n/uitleg_localizations.dart';

/// Uitlegpagina — hoe worden alle berekeningen uitgevoerd?
class UitlegScreen extends StatelessWidget {
  const UitlegScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uitlegAppBarTitel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OverzichtSectie(),
            const SizedBox(height: 8),
            _StroombepaalSectie(),
            const SizedBox(height: 8),
            _CorrectiefactorenSectie(),
            const SizedBox(height: 8),
            _CyclischeSectie(),
            const SizedBox(height: 8),
            _HarmonischenSectie(),
            const SizedBox(height: 8),
            _KortsluitMinSectie(),
            const SizedBox(height: 8),
            _KabelkeuzeSectie(),
            const SizedBox(height: 8),
            _CatalogusWaardenSectie(),
            const SizedBox(height: 8),
            _ThermischeKernSectie(),
            const SizedBox(height: 8),
            _SpanningsvalSectie(),
            const SizedBox(height: 8),
            _TemperatuurSectie(),
            const SizedBox(height: 8),
            _KortsluitToetsSectie(),
            const SizedBox(height: 8),
            _MaxLengteSectie(),
            const SizedBox(height: 8),
            _EindoordeelSectie(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _Formule extends StatelessWidget {
  const _Formule(this.tekst, {this.uitleg});
  final String tekst;
  final String? uitleg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tekst,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (uitleg != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
              child: Text(
                uitleg!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
        ],
      ),
    );
  }
}

class _Noot extends StatelessWidget {
  const _Noot(this.tekst, {this.waarschuwing = false});
  final String tekst;
  final bool waarschuwing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kleur = waarschuwing
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;
    final tekstKleur = waarschuwing
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onPrimaryContainer;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kleur),
      ),
      child: Text(
        tekst,
        style: theme.textTheme.bodySmall?.copyWith(color: tekstKleur),
      ),
    );
  }
}

class _Rij extends StatelessWidget {
  const _Rij(this.links, this.rechts);
  final String links;
  final String rechts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(links,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          ),
          Expanded(
            child: Text(rechts, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ── Sectie 0: Overzicht ────────────────────────────────────────────────────────

class _OverzichtSectie extends StatelessWidget {
  const _OverzichtSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final stappen = [
      ('1', l10n.overzichtValideer, l10n.overzichtValideerSub),
      ('2', l10n.overzichtCF, l10n.overzichtCFSub),
      ('2a', l10n.overzichtCyclisch, l10n.overzichtCyclischSub),
      ('2b', l10n.overzichtHarm, l10n.overzichtHarmSub),
      ('3', l10n.overzichtMinDoorsnede, l10n.overzichtMinDoorsnedeFormule),
      ('4', l10n.overzichtKabelkeuze, l10n.overzichtKabelkeuzeSub),
      ('5', l10n.overzichtSpanningsval, l10n.overzichtSpanningsvalSub),
      ('6', l10n.overzichtTemp, l10n.overzichtTempSub),
      ('7', l10n.overzichtKortsluit, l10n.overzichtKortsluitFormule),
      ('7b', l10n.overzichtMaxLengte, l10n.overzichtMaxLengteSub),
      ('8', l10n.overzichtEindoordeel, l10n.overzichtEindoordeelSub),
    ];

    return SectieCard(
      titel: l10n.overzichtTitel,
      icoon: Icons.account_tree_outlined,
      children: stappen.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  s.$1,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Text(s.$2,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.$3,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Sectie 1: Stroom bepalen ───────────────────────────────────────────────────

class _StroombepaalSectie extends StatelessWidget {
  const _StroombepaalSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.stroomTitel,
      icoon: Icons.electric_bolt,
      children: [
        Text(l10n.stroomIntro),
        const SizedBox(height: 8),
        _Formule(
          l10n.stroomAC1,
          uitleg: l10n.stroomAC1Sub,
        ),
        _Formule(
          l10n.stroomDC,
          uitleg: l10n.stroomDCSub,
        ),
        _Formule(
          l10n.stroomDirect,
          uitleg: l10n.stroomDirectSub,
        ),
        const SizedBox(height: 4),
        _Rij(l10n.stroomParallel, l10n.stroomParallelFormule),
        _Noot(l10n.stroomParallelSub),
      ],
    );
  }
}

// ── Sectie 2: Correctiefactoren ────────────────────────────────────────────────

class _CorrectiefactorenSectie extends StatelessWidget {
  const _CorrectiefactorenSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.cfTitel,
      icoon: Icons.tune,
      children: [
        Text(l10n.cfIntro),
        const SizedBox(height: 10),
        _Formule(l10n.cfFormule),
        const SizedBox(height: 8),
        Text(l10n.cfTempTitel),
        _Formule(
          l10n.cfTempFormule,
          uitleg: l10n.cfTempSub,
        ),
        _Noot(l10n.cfTempNote, waarschuwing: true),
        const SizedBox(height: 8),
        Text(l10n.cfBundelTitel),
        _Formule(
          l10n.cfBundelFormule,
          uitleg: l10n.cfBundelSub,
        ),
        const SizedBox(height: 8),
        Text(l10n.cfGrondTitel),
        _Formule(
          l10n.cfGrondFormule,
          uitleg: l10n.cfGrondSub,
        ),
        const SizedBox(height: 8),
        Text(l10n.cfZonTitel),
        _Formule(
          l10n.cfZonFormule,
          uitleg: l10n.cfZonSub,
        ),
      ],
    );
  }
}

// ── Sectie 2a: Cyclische belastingsfactor ─────────────────────────────────────

class _CyclischeSectie extends StatelessWidget {
  const _CyclischeSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.cyclischTitel,
      icoon: Icons.bar_chart,
      children: [
        Text(l10n.cyclischIntro),
        const SizedBox(height: 8),
        const _Formule(
          'I_z = I_z0 · f_base · M',
          uitleg: 'f_base = f_T · f_bundel · f_grond  (IEC 60364-5-52)  ·  M ≥ 1,0',
        ),
        const SizedBox(height: 10),
        Text(l10n.cyclischFormuleTitel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        _Formule(
          l10n.cyclischFormulaM,
          uitleg: l10n.cyclischFormuleSub,
        ),
        const SizedBox(height: 8),
        Text(l10n.cyclischTherTitel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.cyclischTherFormule,
          uitleg: l10n.cyclischTherSub,
        ),
        const SizedBox(height: 8),
        Text(l10n.cyclischDiffTitel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        DataTable(
          columnSpacing: 24,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 28,
          headingRowHeight: 34,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          ),
          columns: [
            DataColumn(label: Text(l10n.cyclischColXi)),
            DataColumn(label: Text(l10n.cyclischColDelta), numeric: true),
          ],
          rows: const [
            DataRow(cells: [DataCell(Text('0,5')), DataCell(Text('1,0'))]),
            DataRow(cells: [DataCell(Text('1,0')), DataCell(Text('0,5'))]),
            DataRow(cells: [DataCell(Text('1,5')), DataCell(Text('0,4'))]),
            DataRow(cells: [DataCell(Text('2,0')), DataCell(Text('0,3'))]),
            DataRow(cells: [DataCell(Text('2,5')), DataCell(Text('0,25'))]),
          ],
        ),
        const SizedBox(height: 10),
        Text(l10n.cyclischT4Titel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.cyclischT4Aanliggend,
          uitleg: l10n.cyclischT4AanliggendSub,
        ),
        _Formule(
          l10n.cyclischT4Gespreid,
          uitleg: l10n.cyclischT4GespreidSub,
        ),
        _Noot(l10n.cyclischSlot),
      ],
    );
  }
}

// ── Sectie 2b: Hogere harmonischen ────────────────────────────────────────────

class _HarmonischenSectie extends StatelessWidget {
  const _HarmonischenSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.harmTitel,
      icoon: Icons.waves,
      children: [
        Text(l10n.harmIntro),
        const SizedBox(height: 10),
        Text(l10n.harmNulTitel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.harmNulFormule,
          uitleg: l10n.harmNulSub,
        ),
        const SizedBox(height: 10),
        Text(l10n.harmTabelTitel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        DataTable(
          columnSpacing: 20,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
          headingRowHeight: 36,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          ),
          columns: [
            DataColumn(label: Text(l10n.harmColH3)),
            DataColumn(label: Text(l10n.harmColGrondslag)),
            const DataColumn(label: Text('f_harm'), numeric: true),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text(l10n.harmCol0_15)),
              DataCell(Text(l10n.harmColFasestroom)),
              const DataCell(Text('1,00')),
            ]),
            DataRow(cells: [
              const DataCell(Text('15 – 33 %')),
              DataCell(Text(l10n.harmColFasestroom)),
              const DataCell(Text('0,86')),
            ]),
            DataRow(cells: [
              const DataCell(Text('33 – 45 %')),
              DataCell(Text(l10n.harmColNulstroom)),
              const DataCell(Text('0,86')),
            ]),
            DataRow(cells: [
              const DataCell(Text('> 45 %')),
              DataCell(Text(l10n.harmColNulstroom)),
              const DataCell(Text('1,00')),
            ]),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Kabelkeuze met harmonischencorrectie:',
            // This text is a section subheading not directly in uitleg_localizations,
            // so we keep the hardcoded Dutch — but harmKeuzeFormule covers the formula.
            ),
        const SizedBox(height: 4),
        _Formule(
          l10n.harmKeuzeFormule,
          uitleg: l10n.harmKeuzeSub,
        ),
        const SizedBox(height: 6),
        _Rij('h₃ = 15–33%:', l10n.harmZone1.replaceAll('\n', ' ')),
        _Rij('h₃ = 33–45%:', l10n.harmZone2.replaceAll('\n', ' ')),
        _Rij('h₃ > 45%:', l10n.harmZone3.replaceAll('\n', ' ')),
        _Noot(l10n.harmToepassingsgebied),
      ],
    );
  }
}

// ── Sectie 3: Min. doorsnede kortsluit ────────────────────────────────────────

class _KortsluitMinSectie extends StatelessWidget {
  const _KortsluitMinSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.ksMinTitel,
      icoon: Icons.flash_on,
      children: [
        Text(l10n.ksMinIntro),
        const SizedBox(height: 8),
        _Formule(
          l10n.ksMinFormule,
          uitleg: l10n.ksMinSub,
        ),
        const SizedBox(height: 10),
        Text(l10n.ksMinKWaarden,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 4),
        DataTable(
          columnSpacing: 32,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
          headingRowHeight: 36,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          ),
          columns: [
            DataColumn(label: Text(l10n.ksMinColGeleider)),
            DataColumn(label: Text(l10n.ksMinColIsolatie)),
            const DataColumn(label: Text('k'), numeric: true),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('Cu')),
              DataCell(Text('PVC (70°C)')),
              DataCell(Text('115')),
            ]),
            DataRow(cells: [
              DataCell(Text('Cu')),
              DataCell(Text('XLPE/EPR (90°C)')),
              DataCell(Text('143')),
            ]),
            DataRow(cells: [
              DataCell(Text('Al')),
              DataCell(Text('PVC (70°C)')),
              DataCell(Text('76')),
            ]),
            DataRow(cells: [
              DataCell(Text('Al')),
              DataCell(Text('XLPE/EPR (90°C)')),
              DataCell(Text('94')),
            ]),
          ],
        ),
        _Noot(l10n.ksMinSlot),
      ],
    );
  }
}

// ── Sectie 4: Kabelkeuze ──────────────────────────────────────────────────────

class _KabelkeuzeSectie extends StatelessWidget {
  const _KabelkeuzeSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.kabelkeuzeTitel,
      icoon: Icons.search,
      children: [
        Text(l10n.kabelkeuzeIntro),
        const SizedBox(height: 8),
        _Formule(
          l10n.kabelkeuzeFormule,
          uitleg: l10n.kabelkeuzeSub,
        ),
        const SizedBox(height: 6),
        _Rij(l10n.kabelkeuzeAutomatisch, l10n.kabelkeuzeAutomatischSub),
        _Rij(l10n.kabelkeuzeGeforceerd, l10n.kabelkeuzeGeforceerrdSub),
        _Rij(l10n.kabelkeuzeSingel, l10n.kabelkeuzeSingelSub),
        const SizedBox(height: 4),
        _Noot(l10n.kabelkeuzeKortsluitSub),
      ],
    );
  }
}

// ── Sectie 4b: Cataloguswaarden ───────────────────────────────────────────────

class _CatalogusWaardenSectie extends StatelessWidget {
  const _CatalogusWaardenSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.catalogusTitel,
      icoon: Icons.table_chart_outlined,
      children: [
        Text(l10n.catalogusIntro),
        const SizedBox(height: 14),

        // ── R_AC ──────────────────────────────────────────────────────────────
        Text(l10n.catalogusRacTitel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(l10n.catalogusRacIntro),
        _Formule(
          l10n.catalogusRacFormule,
          uitleg: l10n.catalogusRacSub,
        ),
        Text(l10n.catalogusRacSkin),
        _Formule(
          l10n.catalogusRacSkinFormule,
          uitleg: l10n.catalogusRacSkinSub,
        ),
        _Noot(l10n.catalogusRacSlot),
        const SizedBox(height: 12),

        // ── I_z C en I_z E ────────────────────────────────────────────────────
        Text(l10n.catalogusIzTitel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(l10n.catalogusIzIntro),
        const SizedBox(height: 6),
        const _Rij('Methode C:', 'In buis of aanliggend aan wand / plafond'),
        const _Rij('Methode E:', 'In vrije lucht, op 1 × D van oppervlak'),
        const _Rij('2 belaste aders:', '1- en 2-aderige kabels (1-fase AC of DC)'),
        const _Rij('3 belaste aders:', '3-, 4- en 5-aderige kabels (3-fase AC)'),
        const SizedBox(height: 6),
        const Text(
          'I_z E wordt niet direct afgelezen maar afgeleid van I_z C met een '
          'vaste vermenigvuldigingsfactor die de betere koeling in vrije lucht weergeeft:',
        ),
        const _Formule(
          'I_z E (PVC)  = I_z C · 1,25',
          uitleg: 'PVC-isolatie, methode E ≈ 25 % hoger dan methode C',
        ),
        const _Formule(
          'I_z E (XLPE) = I_z C · 1,30',
          uitleg: 'XLPE-isolatie, methode E ≈ 30 % hoger dan methode C',
        ),
        const _Rij(
          '1-aderig singel:',
          'Dezelfde kabel in 3-fase circuit gebruikt I_zC3 / I_zE3 '
          '(3 belaste aders). Afgeleid van de 3-fase tabelwaarden.',
        ),
        _Noot(l10n.catalogusIzSingelBonus),
        const SizedBox(height: 12),

        // ── Buitendiameter ────────────────────────────────────────────────────
        Text(l10n.catalogusDiamTitel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(l10n.catalogusDiamIntro),
        const SizedBox(height: 6),
        DataTable(
          columnSpacing: 32,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
          headingRowHeight: 36,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          ),
          columns: [
            DataColumn(label: Text(l10n.catalogusDiamColAders), numeric: true),
            DataColumn(label: Text(l10n.catalogusDiamColFactor), numeric: true),
            DataColumn(label: Text(l10n.catalogusDiamColToel)),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('1×')),
              DataCell(Text('0,62')),
              DataCell(Text('Singel — ronde kabel, kleinste omtrek')),
            ]),
            DataRow(cells: [
              DataCell(Text('2×')),
              DataCell(Text('0,82')),
              DataCell(Text('Twee-aderig plat of rond')),
            ]),
            DataRow(cells: [
              DataCell(Text('3×')),
              DataCell(Text('1,00')),
              DataCell(Text('Basiswaarde (3-aderig)')),
            ]),
            DataRow(cells: [
              DataCell(Text('4×')),
              DataCell(Text('1,12')),
              DataCell(Text('3L + N, grotere omtrek')),
            ]),
            DataRow(cells: [
              DataCell(Text('5×')),
              DataCell(Text('1,20')),
              DataCell(Text('3L + N + PE, grootste omtrek')),
            ]),
          ],
        ),
        const SizedBox(height: 6),
        _Formule(
          l10n.catalogusDiamSlot,
          uitleg: l10n.catalogusDiamSlotSub,
        ),
        _Noot(l10n.catalogusDiamNote, waarschuwing: true),
      ],
    );
  }
}

// ── Sectie 4c: Thermische kern (IEC 60287) ────────────────────────────────────

class _ThermischeKernSectie extends StatelessWidget {
  const _ThermischeKernSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.thermTitel,
      icoon: Icons.thermostat_outlined,
      children: [
        Text(l10n.thermIntro),
        const SizedBox(height: 14),

        // ── 1. Toelaatbare stroom ─────────────────────────────────────────────
        Text(l10n.thermStroom1Titel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(l10n.thermStroom1Intro),
        _Formule(
          l10n.thermFormule1,
          uitleg: l10n.thermFormule1Sub,
        ),
        const SizedBox(height: 6),
        const _Rij('Δθ  [K]',
            'θ_max (PVC 70°C / XLPE 90°C) − θ_amb (referentie 30°C)'),
        const _Rij('T₁  [K·m/W]',
            'Tussen geleider en mantel (isolatie)'),
        const _Rij('T₂  [K·m/W]',
            'Opvulling tussen mantel en bewapening'),
        const _Rij('T₃  [K·m/W]',
            'Buitenmantel (outer serving)'),
        const _Rij('T₄  [K·m/W]',
            'Kabeloppervlak → omgeving (grond of lucht, zie §3 hieronder)'),
        _Noot(l10n.thermTVereenv),
        const SizedBox(height: 14),

        // ── 2. AC-weerstand ───────────────────────────────────────────────────
        Text(l10n.thermAC2Titel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(l10n.thermAC2Intro),
        _Formule(
          l10n.thermAC2Formule,
          uitleg: l10n.thermAC2Sub,
        ),
        const SizedBox(height: 8),
        Text(l10n.thermSkinTitel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const _Formule(
          'xs² = 8πf · ks / (R_20 · 10⁷)',
          uitleg: 'f = frequentie [Hz]  ·  ks = 1,00 (rond massief)  ·  '
              'ks = 0,435 (sectorvormig)  ·  R_20 in [Ω/m]',
        ),
        _Formule(
          'ys = xs⁴ / (192 + 0,8·xs⁴)',
          uitleg: l10n.thermSkinSub,
        ),
        const SizedBox(height: 8),
        Text(l10n.thermNabijTitel,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const _Formule(
          'xp² = 8πf · kp / (R_20 · 10⁷)',
          uitleg: 'kp = 0,80 (rond massief)  ·  kp = 0,37 (sectorvormig)',
        ),
        _Formule(
          'yp = [xp⁴/(192+0,8·xp⁴)] · (dc/s)² · [0,312·(dc/s)² + 1,18/(xp⁴/(192+0,8·xp⁴)+0,27)]',
          uitleg: l10n.thermNabijSub,
        ),
        DataTable(
          columnSpacing: 24,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 28,
          headingRowHeight: 34,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          ),
          columns: const [
            DataColumn(label: Text('A (mm²)'), numeric: true),
            DataColumn(label: Text('ys (Cu, 50 Hz)'), numeric: true),
            DataColumn(label: Text('1 + ys + yp'), numeric: true),
          ],
          rows: const [
            DataRow(cells: [DataCell(Text('≤ 50')), DataCell(Text('≈ 0')), DataCell(Text('≈ 1,00'))]),
            DataRow(cells: [DataCell(Text('70')), DataCell(Text('0,003')), DataCell(Text('≈ 1,01'))]),
            DataRow(cells: [DataCell(Text('120')), DataCell(Text('0,009')), DataCell(Text('≈ 1,01'))]),
            DataRow(cells: [DataCell(Text('185')), DataCell(Text('0,021')), DataCell(Text('≈ 1,03'))]),
            DataRow(cells: [DataCell(Text('300')), DataCell(Text('0,054')), DataCell(Text('≈ 1,06'))]),
            DataRow(cells: [DataCell(Text('400')), DataCell(Text('0,100')), DataCell(Text('≈ 1,12'))]),
          ],
        ),
        const SizedBox(height: 14),

        // ── 3. T4 – thermische weerstand naar omgeving ────────────────────────
        Text(l10n.thermT43Titel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(l10n.thermT4Grond,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.thermT4GrondFormule,
          uitleg: l10n.thermT4GrondSub,
        ),
        const _Rij('ρs referentie:', '1,0 K·m/W (standaard zandgrond IEC 60287)'),
        const _Rij('ρs droge grond:', '2,0–3,0 K·m/W → T₄ groter → I lager'),
        const _Rij('ρs natte grond:', '0,5–0,7 K·m/W → T₄ kleiner → I hoger'),
        const _Rij('Standaard diepte:', '0,70 m (NEN 1010 / IEC 60364)'),
        const SizedBox(height: 8),
        Text(l10n.thermT4Lucht,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.thermT4LuchtFormule,
          uitleg: l10n.thermT4LuchtSub,
        ),
        _Noot(l10n.thermT4Note, waarschuwing: true),
        const SizedBox(height: 14),

        // ── 4. Verband met doorsnede ──────────────────────────────────────────
        Text(l10n.thermA4Titel,
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        const Text('Voor een ronde enkelvoudige isolatielaag geldt:'),
        _Formule(
          l10n.thermT1Formule,
          uitleg: l10n.thermT1Sub,
        ),
        Text(l10n.thermA4Uitleg),
        _Formule(
          l10n.thermA4Formule,
          uitleg: l10n.thermA4Slot,
        ),
        _Noot(l10n.thermNote),
      ],
    );
  }
}

// ── Sectie 5: Spanningsval ────────────────────────────────────────────────────

class _SpanningsvalSectie extends StatelessWidget {
  const _SpanningsvalSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.svTitel,
      icoon: Icons.show_chart,
      children: [
        Text(l10n.svIntro),
        const SizedBox(height: 8),
        const _Formule(
          'AC 1-fase:   ΔU = 2 · I · L · (R·cosφ + X·sinφ)',
          uitleg: 'Factor 2: heengeleider + retour (N of PE)',
        ),
        const _Formule(
          'AC 3-fase:   ΔU = √3 · I · L · (R·cosφ + X·sinφ)',
          uitleg: 'Factor √3 voor lijn-naar-lijn spanning',
        ),
        const _Formule(
          'DC 2-draad:  ΔU = 2 · I · R_DC · L',
          uitleg: 'Factor 2: + en − geleider; reactantie X = 0',
        ),
        const _Formule(
          'DC aardret:  ΔU = I · R_DC · L',
          uitleg: 'Aardretourcircuit: slechts één geleider telt',
        ),
        const SizedBox(height: 6),
        const _Rij('R bij bedrijfsT:', 'R(T) = R_20 · [1 + α₂₀ · (T_max − 20)] / 1000  [Ω/m]'),
        const _Rij('α₂₀ Cu:', '0,00393 K⁻¹'),
        const _Rij('α₂₀ Al:', '0,00403 K⁻¹'),
        const _Rij('% spanningsval:', 'ΔU% = 100 · ΔU / U_nominaal'),
        _Noot(l10n.svParallel),
      ],
    );
  }
}

// ── Sectie 6: Temperatuurstijging ─────────────────────────────────────────────

class _TemperatuurSectie extends StatelessWidget {
  const _TemperatuurSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.tempStijgingTitel,
      icoon: Icons.thermostat,
      children: [
        Text(l10n.tempStijgingIntro),
        const SizedBox(height: 8),
        _Formule(
          l10n.tempStijgingFormuleVerlies,
          uitleg: l10n.tempStijgingFormuleVerliesSub,
        ),
        const SizedBox(height: 6),
        Text(l10n.tempStijgingBovengronds),
        const _Formule(
          'ΔT = P / (π · D · h_conv)',
          uitleg: 'h_conv ≈ 10 W/(m²·K)  ·  D = buitendiameter kabel [m]',
        ),
        const SizedBox(height: 6),
        Text(l10n.tempStijgingGrond),
        _Formule(
          'T_aard = (λ_grond / 2π) · ln(4u/D)',
          uitleg: l10n.tempStijgingGrondSub,
        ),
        const _Formule('ΔT = P · T_aard   [K]'),
        _Rij(
          l10n.tempStijgingGeleider.contains('\n')
              ? l10n.tempStijgingGeleider.split('\n').first
              : l10n.tempStijgingGeleider,
          l10n.tempStijgingGeleider.contains('\n')
              ? l10n.tempStijgingGeleider.split('\n').last
              : '',
        ),
        _Noot(l10n.tempStijgingNote, waarschuwing: true),
      ],
    );
  }
}

// ── Sectie 7: Kortsluittoets ──────────────────────────────────────────────────

class _KortsluitToetsSectie extends StatelessWidget {
  const _KortsluitToetsSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.ksToetsTitel,
      icoon: Icons.warning_amber_rounded,
      children: [
        Text(l10n.ksToetsIntro),
        const SizedBox(height: 8),
        _Formule(
          l10n.ksToetsFormule,
          uitleg: l10n.ksToetsSub,
        ),
        _Formule(l10n.ksToetsEind),
        const SizedBox(height: 6),
        const _Rij('PVC:    T_max,ks =', '160 °C'),
        const _Rij('XLPE/EPR: T_max,ks =', '250 °C'),
        _Noot(l10n.ksToetsParallel),
      ],
    );
  }
}

// ── Sectie 7b: Max. leidinglengte ─────────────────────────────────────────────

class _MaxLengteSectie extends StatelessWidget {
  const _MaxLengteSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SectieCard(
      titel: l10n.maxLengteTitel,
      icoon: Icons.straighten,
      children: [
        Text(l10n.maxLengteIntro),
        const SizedBox(height: 12),

        Text(l10n.maxLengteSpanning,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const _Rij('AC 3-fase:', 'U_c = U_nom / √3   (fase-naar-nul)'),
        const _Rij('AC 1-fase / DC:', 'U_c = U_nom'),
        const SizedBox(height: 12),

        Text(l10n.maxLengteLusweerstand,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.maxLengteLusFormule,
          uitleg: l10n.maxLengteLusFormuleSub,
        ),
        const SizedBox(height: 12),

        Text(l10n.maxLengteFormuleTitel,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        _Formule(
          l10n.maxLengteFormulaZonderIk,
          uitleg: l10n.maxLengteFormulaZonderIkSub,
        ),
        _Formule(
          l10n.maxLengteFormulaMetIk,
          uitleg: l10n.maxLengteFormulaMetIkSub,
        ),
        _Formule(
          l10n.maxLengteFormulaIkEind,
          uitleg: l10n.maxLengteFormulaIkEindSub,
        ),
        const SizedBox(height: 12),

        Text(l10n.maxLengteIaLabel,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        // MCB-tabel
        DataTable(
          columnSpacing: 24,
          dataRowMinHeight: 28,
          dataRowMaxHeight: 28,
          headingRowHeight: 34,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          ),
          columns: const [
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('I_a')),
          ],
          rows: const [
            DataRow(cells: [DataCell(Text('MCB type B')), DataCell(Text('5 × In'))]),
            DataRow(cells: [DataCell(Text('MCB type C')), DataCell(Text('10 × In'))]),
            DataRow(cells: [DataCell(Text('MCB type D')), DataCell(Text('20 × In'))]),
            DataRow(cells: [DataCell(Text('Handmatig')), DataCell(Text('direct opgeven'))]),
          ],
        ),
        const SizedBox(height: 12),
        Text(l10n.maxLengteGgTitel,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(l10n.maxLengteGgIntro,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 6),
        // gG-tabel
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            dataRowMinHeight: 28,
            dataRowMaxHeight: 28,
            headingRowHeight: 36,
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            ),
            columns: const [
              DataColumn(label: Text('In (A)'), numeric: true),
              DataColumn(label: Text('t ≤ 0,2 s'), numeric: true),
              DataColumn(label: Text('t ≤ 0,4 s'), numeric: true),
              DataColumn(label: Text('t ≤ 1 s'),   numeric: true),
              DataColumn(label: Text('t ≤ 5 s'),   numeric: true),
            ],
            rows: const [
              DataRow(cells: [DataCell(Text('10')),  DataCell(Text('130')), DataCell(Text('80')),  DataCell(Text('46')),  DataCell(Text('22'))]),
              DataRow(cells: [DataCell(Text('16')),  DataCell(Text('175')), DataCell(Text('110')), DataCell(Text('65')),  DataCell(Text('32'))]),
              DataRow(cells: [DataCell(Text('20')),  DataCell(Text('250')), DataCell(Text('155')), DataCell(Text('90')),  DataCell(Text('45'))]),
              DataRow(cells: [DataCell(Text('25')),  DataCell(Text('320')), DataCell(Text('195')), DataCell(Text('115')), DataCell(Text('57'))]),
              DataRow(cells: [DataCell(Text('32')),  DataCell(Text('420')), DataCell(Text('265')), DataCell(Text('150')), DataCell(Text('75'))]),
              DataRow(cells: [DataCell(Text('40')),  DataCell(Text('530')), DataCell(Text('330')), DataCell(Text('190')), DataCell(Text('95'))]),
              DataRow(cells: [DataCell(Text('50')),  DataCell(Text('675')), DataCell(Text('430')), DataCell(Text('250')), DataCell(Text('125'))]),
              DataRow(cells: [DataCell(Text('63')),  DataCell(Text('860')), DataCell(Text('540')), DataCell(Text('315')), DataCell(Text('160'))]),
              DataRow(cells: [DataCell(Text('80')), DataCell(Text('1150')), DataCell(Text('720')), DataCell(Text('420')), DataCell(Text('215'))]),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(l10n.maxLengteGgEenheid,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 8),
        _Noot(l10n.maxLengteNorm),
      ],
    );
  }
}

// ── Sectie 8: Eindoordeel ─────────────────────────────────────────────────────

class _EindoordeelSectie extends StatelessWidget {
  const _EindoordeelSectie();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final checks = [
      ('I_z ≥ I/n', 'Kabel draagt de belastingsstroom'),
      ('A ≥ A_min,ks', 'Doorsnede voldoet aan kortsluiteis (stap 3)'),
      ('ΔU% ≤ max%', 'Spanningsval binnen de grens'),
      ('T_gel ≤ T_max', 'Geleider blijft koel genoeg (indicatief)'),
      ('T_eind,ks ≤ T_max,ks', 'Kortsluittemperatuur acceptabel'),
      ('L ≤ L_max', 'Leidinglengte binnen kortsluitbeveiligingsgrens (optioneel)'),
    ];

    return SectieCard(
      titel: l10n.eindoordeelTitel,
      icoon: Icons.check_circle_outline,
      children: [
        Text(l10n.eindoordeelIntro),
        const SizedBox(height: 10),
        ...checks.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 180,
                    child: Text(c.$1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Expanded(
                    child: Text(c.$2,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
        _Noot(l10n.eindoordeelNormen),
      ],
    );
  }
}
