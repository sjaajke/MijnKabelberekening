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
import '../l10n/app_localizations.dart';
import '../state/berekening_provider.dart';
import '../state/projecten_provider.dart';
import '../models/enums.dart';
import '../models/resultaten.dart';
import '../data/materiaal_data.dart';
import '../berekening/rapport.dart';
import '../widgets/sectie_card.dart';
import '../widgets/invoer_rij.dart';

class ResultatenScreen extends StatelessWidget {
  const ResultatenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final res = context.watch<BerekeningProvider>().resultaten;
    final l10n = context.l10n;

    if (res == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calculate_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.resultatenLeeg,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _eindoordeel(context, res, l10n),
          if (res.kabel != null) ...[
            _kabelGegevens(context, res, l10n),
            _correctiefactoren(context, res, l10n),
            _belastbaarheid(context, res, l10n),
            if (res.bundelPositieWorst != null) _bundelPosities(context, res, l10n),
            _spanningsval(context, res, l10n),
            _temperatuur(context, res, l10n),
            if (res.okKortsluit != null) _kortsluit(context, res, l10n),
            if (res.okMaxLengte != null) _maxLengte(context, res, l10n),
            if (res.zbOhm != null) _bronimpedantie(context, res, l10n),
          ],
          if (res.fouten.isNotEmpty) _foutMeldingen(context, res, l10n),
          if (res.waarschuwingen.isNotEmpty) _waarschuwingen(context, res, l10n),
          _opslaanKnop(context, l10n),
          _kopieerKnop(context, res, l10n),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── OPSLAAN IN PROJECT ─────────────────────────────────────────────────────
  Widget _opslaanKnop(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.bookmark_add_outlined),
        label: Text(l10n.berekeningSlaOp),
        onPressed: () => _toonOpslaanDialog(context, l10n),
      ),
    );
  }

  Future<void> _toonOpslaanDialog(
      BuildContext context, AppLocalizations l10n) async {
    final projectenProvider = context.read<ProjectenProvider>();
    final berekeningProvider = context.read<BerekeningProvider>();
    final projecten = projectenProvider.projecten;

    if (projecten.isEmpty) {
      // Geen projecten: vraag eerst een project aan te maken
      final projectNaam = await showDialog<String>(
        context: context,
        builder: (ctx) => _NieuwProjectEnOpslaanDialog(l10n: l10n),
      );
      if (projectNaam == null || !context.mounted) return;
      await projectenProvider.maakProject(projectNaam);
      if (!context.mounted) return;
      // Nu opnieuw het dialoog tonen met het nieuwe project
      await _toonOpslaanDialog(context, l10n);
      return;
    }

    final resultaat = await showDialog<({String projectId, String naam})>(
      context: context,
      builder: (ctx) => _OpslaanInProjectDialog(
        l10n: l10n,
        projecten: projecten,
      ),
    );
    if (resultaat == null || !context.mounted) return;

    final invoer = berekeningProvider.invoer;
    await projectenProvider.voegBerekeningToe(
        resultaat.projectId, resultaat.naam, invoer);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.berekeningSlaOp),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── EINDOORDEEL ────────────────────────────────────────────────────────────
  Widget _eindoordeel(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final ok = r.voldoet;
    final cs = Theme.of(ctx).colorScheme;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final kleur = ok
        ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
        : cs.onErrorContainer;
    final bg = ok
        ? (isDark ? Colors.green.shade900 : Colors.green.shade50)
        : cs.errorContainer;
    return Card(
      color: bg,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.cancel, color: kleur, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ok ? l10n.eindVoldoet : l10n.eindGefaald,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: kleur, fontSize: 15)),
              if (r.kabel != null) ...[
                Text(
                  r.nParallel > 1
                      ? '${r.nParallel} × ${r.kabel!.naam}'
                      : r.kabel!.naam,
                  style: const TextStyle(fontSize: 13),
                ),
                if (r.nParallel > 1)
                  Text(
                    l10n.iPerKabelLabel(r.iPerKabel.toStringAsFixed(1)),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  // ── KABELGEGEVENS ─────────────────────────────────────────────────────────
  Widget _kabelGegevens(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final k = r.kabel!;
    final ip = isolatieEigenschappen[k.isolatie]!;
    final inv = ctx.read<BerekeningProvider>().invoer;
    final isSingelAC = inv.aantalAders == 1 && inv.systeem.isAC;
    final totaalSingels = isSingelAC ? r.nParallel * inv.geleidersPerKring : 0;
    final gpk = inv.geleidersPerKring;
    final is3Fase = inv.systeem == Systeemtype.ac3Fase;

    String singelConfigLabel() {
      if (is3Fase) {
        return switch (gpk) {
          3 => '$gpk geleiders per kring  (L1 + L2 + L3)',
          4 => '$gpk geleiders per kring  (L1 + L2 + L3 + N)',
          _ => '$gpk geleiders per kring  (L1 + L2 + L3 + N + PE)',
        };
      }
      return gpk == 2
          ? '$gpk geleiders per kring  (L + N)'
          : '$gpk geleiders per kring  (L + N + PE)';
    }

    return SectieCard(
      titel: l10n.sectGeselecteerdeKabel,
      icoon: Icons.cable,
      children: [
        ResultaatRij(label: l10n.lblType, waarde: k.naam, vet: true),
        if (isSingelAC) ...[
          ResultaatRij(
              label: l10n.lblSingelConfig,
              waarde: singelConfigLabel(),
              vet: true),
          ResultaatRij(
              label: l10n.lblTotaalSingels,
              waarde: '$totaalSingels ${l10n.eenheidStuks}'
                  '${r.nParallel > 1 ? "  (${r.nParallel}× parallel)" : ""}'),
        ],
        ResultaatRij(label: l10n.lblDoorsnede, waarde: '${k.doorsnedemm2} mm²'),
        ResultaatRij(label: l10n.lblGeleider, waarde: k.geleider.label),
        ResultaatRij(
            label: l10n.lblIsolatie,
            waarde: '${k.isolatie.label}  (max ${ip.maxTempContinu.toInt()} °C)'),
        ResultaatRij(
            label: l10n.lblBuitendiameter,
            waarde: '${k.buitendiameter.toStringAsFixed(1)} mm'),
        if (inv.bundel != null && inv.bundel!.totaalKabels > 1) ...[
          ResultaatRij(
              label: 'Hart-op-hart (aanliggend)',
              waarde: l10n.hartOpHartAanliggend(k.buitendiameter.toStringAsFixed(0))),
          ResultaatRij(
              label: 'Hart-op-hart (2×d)',
              waarde: l10n.hartOpHart2xd((2 * k.buitendiameter).toStringAsFixed(0))),
        ],
        ResultaatRij(
            label: 'R_AC @ 20°C',
            waarde: '${k.rAcPerKm20C.toStringAsFixed(4)} Ω/km'),
        ResultaatRij(
            label: 'X @ 50 Hz',
            waarde: '${k.xAcPerKm.toStringAsFixed(4)} Ω/km'),
      ],
    );
  }

  // ── CORRECTIEFACTOREN ─────────────────────────────────────────────────────
  Widget _correctiefactoren(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    return SectieCard(
      titel: l10n.sectCorrectiefactoren,
      icoon: Icons.tune,
      children: [
        ResultaatRij(
            label: l10n.lblThetaEff,
            waarde: '${r.tEffectief.toStringAsFixed(1)} °C'
                '${r.tEffectief > 30 ? l10n.inclZonlicht : ""}'),
        ResultaatRij(
            label: 'f_T  (temperatuur)',
            waarde: r.fT.toStringAsFixed(4),
            vet: true),
        ResultaatRij(
            label: 'f_legging  (${ctx.read<BerekeningProvider>().invoer.legging.code})',
            waarde: r.fLegging.toStringAsFixed(4)),
        ResultaatRij(
            label: 'f_bundel',
            waarde: r.fBundel.toStringAsFixed(4)),
        if (r.bundelPositieWorst != null) ...[
          ResultaatRij(
              label: '  f_h (${r.fHorizontaal.toStringAsFixed(3)})',
              waarde: 'horizontaal (tabel B.52.20)'),
          ResultaatRij(
              label: '  f_v (${r.fVerticaal.toStringAsFixed(3)})',
              waarde: 'stapeling (tabel B.52.21)'),
          ResultaatRij(
              label: l10n.lblMaatgevendeKabel,
              waarde:
                  'positie (${r.bundelPositieWorst!.$1}, ${r.bundelPositieWorst!.$2})  — ${l10n.centrumBundel}'),
        ],
        ResultaatRij(label: 'f_grond', waarde: r.fGrond.toStringAsFixed(4)),
        if (r.fCyclisch != 1.0)
          ResultaatRij(
              label: 'M  (cyclisch, IEC 60583-1)',
              waarde: r.fCyclisch.toStringAsFixed(4),
              vet: true),
        if (r.iNeutraal > 0) ...[
          ResultaatRij(
              label: 'f_harm  (NEN 1010 Bijl. 52.E.1)',
              waarde: r.fHarmonisch.toStringAsFixed(4),
              vet: true),
          ResultaatRij(
              label: '  I_N  (nulpuntsstroom)',
              waarde: '${r.iNeutraal.toStringAsFixed(1)} A'),
          ResultaatRij(
              label: '  Grondslag kabelkeuze',
              waarde: r.harmonischOpNul
                  ? l10n.grondslagNulpuntsstroom
                  : l10n.grondslagFasestroom),
        ],
        if (r.deltaTWindK != null) ...[
          ResultaatRij(
            label: 'ΔT_wind  (windkoeling)',
            waarde: '${r.deltaTWindK! >= 0 ? "+" : ""}${r.deltaTWindK!.toStringAsFixed(1)} K',
            kleur: r.deltaTWindK! < 0 ? Colors.green.shade700 : Colors.orange.shade800,
            vet: true,
          ),
          ResultaatRij(
            label: l10n.lblThetaEff,
            waarde: '${r.tEffectief.toStringAsFixed(1)} °C  (incl. wind)',
          ),
        ],
        if (r.dtZonPvLaagK != null)
          ResultaatRij(
            label: 'ΔT_zon  (PV-laagpositie, IEC 60364)',
            waarde: '+${r.dtZonPvLaagK!.toStringAsFixed(1)} K',
            kleur: r.dtZonPvLaagK! > 10 ? Colors.orange.shade800 : Colors.blue.shade700,
            vet: true,
          ),
        const Divider(height: 10),
        ResultaatRij(
            label: 'f_TOTAAL',
            waarde: r.fTotaal.toStringAsFixed(4),
            vet: true),
      ],
    );
  }

  // ── BELASTBAARHEID ────────────────────────────────────────────────────────
  Widget _belastbaarheid(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final ok = r.margeStroomPct >= 0;
    return SectieCard(
      titel: l10n.sectBelastbaarheid,
      icoon: Icons.electric_bolt,
      children: [
        if (r.nParallel > 1) ...[
          ResultaatRij(
              label: l10n.lblConfiguratie,
              waarde: l10n.kabelsParallel(r.nParallel),
              vet: true),
          ResultaatRij(
              label: l10n.lblITotaal,
              waarde: '${r.iGevraagd.toStringAsFixed(1)} A'),
          ResultaatRij(
              label: 'I per kabel',
              waarde: '${r.iPerKabel.toStringAsFixed(2)} A'),
          const Divider(height: 10),
        ],
        ResultaatRij(
            label: 'I_z0 (tabel, 30°C)',
            waarde: '${r.iz0.toStringAsFixed(1)} A${l10n.perKabelSuffix}'),
        ResultaatRij(
            label: 'I_z  (gecorrigeerd)',
            waarde: '${r.iz.toStringAsFixed(1)} A${l10n.perKabelSuffix}',
            vet: true),
        if (r.harmonischOpNul)
          ResultaatRij(
              label: l10n.lblINMaatgevend,
              waarde: '${r.iNeutraal.toStringAsFixed(1)} A${l10n.perKabelSuffix}',
              vet: true)
        else if (r.nParallel == 1)
          ResultaatRij(
              label: l10n.lblIGevraagd,
              waarde: '${r.iGevraagd.toStringAsFixed(2)} A'),
        if (r.harmonischOpNul && r.nParallel == 1)
          ResultaatRij(
              label: l10n.lblIFase,
              waarde: '${r.iPerKabel.toStringAsFixed(2)} A'),
        ResultaatRij(
            label: l10n.lblVeiligheidsmarge,
            waarde: '${r.margeStroomPct >= 0 ? "+" : ""}${r.margeStroomPct.toStringAsFixed(1)}%',
            kleur: ok ? Colors.green.shade700 : Colors.red.shade700,
            vet: true),
      ],
    );
  }

  // ── BUNDEL POSITIEVERGELIJKING ────────────────────────────────────────────
  Widget _bundelPosities(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final theme = Theme.of(ctx);
    final zon = r.bundelZonGesplitst;
    final hasDiff = (r.fBundelRand - r.fBundel).abs() > 0.001;

    String margeStr(double m) =>
        '${m >= 0 ? "+" : ""}${m.toStringAsFixed(1)} %';
    Color margeKleur(double m) =>
        m >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    // Labelbreedte iets smaller bij 4 kolommen zodat kolommen genoeg ruimte hebben
    final double labelW = zon ? 100 : 120;

    Widget kop(String tekst) => Expanded(
          child: Text(tekst,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        );

    Widget cel(String tekst, {Color? kleur, bool vet = false}) => Expanded(
          child: Text(tekst,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: kleur,
                  fontWeight: vet ? FontWeight.bold : FontWeight.normal)),
        );

    // 2-koloms rij (zonder zon-splitsing)
    Widget rij2(String label, String k1, String k2,
        {Color? kleur1, Color? kleur2, bool vet = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(width: labelW,
              child: Text(label, style: TextStyle(fontSize: 13,
                  fontWeight: vet ? FontWeight.bold : FontWeight.normal))),
          cel(k1, kleur: kleur1, vet: vet),
          cel(k2, kleur: kleur2, vet: vet),
        ]),
      );
    }

    // 4-koloms rij (met zon-splitsing)
    Widget rij4(String label, String k1, String k2, String k3, String k4,
        {Color? kleur1, Color? kleur2, Color? kleur3, Color? kleur4,
         bool vet = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(width: labelW,
              child: Text(label, style: TextStyle(fontSize: 13,
                  fontWeight: vet ? FontWeight.bold : FontWeight.normal))),
          cel(k1, kleur: kleur1, vet: vet),
          cel(k2, kleur: kleur2, vet: vet),
          cel(k3, kleur: kleur3, vet: vet),
          cel(k4, kleur: kleur4, vet: vet),
        ]),
      );
    }

    Color? tempKleur(double t) =>
        t > r.maxTempC ? Colors.red.shade700 : null;

    return SectieCard(
      titel: l10n.sectBundelPosities,
      icoon: Icons.grid_view,
      children: [
        // Kolomkoppen
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            SizedBox(width: labelW),
            if (zon) ...[
              kop(l10n.colCentrumZon),
              kop(l10n.colBovensteC),
              kop(l10n.colBovensteHoek),
              kop(l10n.colLagereHoek),
            ] else ...[
              kop(l10n.colCentrum),
              kop(l10n.colHoek),
            ],
          ]),
        ),
        const Divider(height: 6),

        if (zon) ...[
          rij4('f_bundel',
              r.fBundel.toStringAsFixed(3),
              r.fBundelBovensteC!.toStringAsFixed(3),
              r.fBundelRand.toStringAsFixed(3),
              r.fBundelRand.toStringAsFixed(3)),
          rij4('I_z (A)',
              r.iz.toStringAsFixed(1),
              r.izBovensteC!.toStringAsFixed(1),
              r.izRand.toStringAsFixed(1),
              r.izLagereHoek!.toStringAsFixed(1),
              vet: true),
          rij4(l10n.rowMarge,
              margeStr(r.margeStroomPct),
              margeStr(r.margeBovensteC!),
              margeStr(r.margeStroomPctRand),
              margeStr(r.margeLagereHoek!),
              kleur1: margeKleur(r.margeStroomPct),
              kleur2: margeKleur(r.margeBovensteC!),
              kleur3: margeKleur(r.margeStroomPctRand),
              kleur4: margeKleur(r.margeLagereHoek!),
              vet: true),
          rij4(l10n.rowTGeleider,
              r.geleiderTempCWarm.toStringAsFixed(1),
              r.geleiderTempBovensteC!.toStringAsFixed(1),
              r.geleiderTempCKoud.toStringAsFixed(1),
              r.geleiderTempLagereHoek!.toStringAsFixed(1),
              kleur1: tempKleur(r.geleiderTempCWarm),
              kleur2: tempKleur(r.geleiderTempBovensteC!),
              kleur3: tempKleur(r.geleiderTempCKoud),
              kleur4: tempKleur(r.geleiderTempLagereHoek!)),
        ] else ...[
          rij2('f_bundel',
              r.fBundel.toStringAsFixed(3),
              r.fBundelRand.toStringAsFixed(3)),
          rij2('I_z (A)',
              r.iz.toStringAsFixed(1),
              r.izRand.toStringAsFixed(1),
              vet: true),
          rij2(l10n.rowMarge,
              margeStr(r.margeStroomPct),
              margeStr(r.margeStroomPctRand),
              kleur1: margeKleur(r.margeStroomPct),
              kleur2: margeKleur(r.margeStroomPctRand),
              vet: true),
          rij2(l10n.rowTGeleider,
              r.geleiderTempCWarm.toStringAsFixed(1),
              r.geleiderTempCKoud.toStringAsFixed(1),
              kleur1: tempKleur(r.geleiderTempCWarm),
              kleur2: tempKleur(r.geleiderTempCKoud)),
        ],

        if (!hasDiff)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l10n.bundelGelijkwaardig,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          ),
        if (zon)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.bundelZonSplitsNote,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l10n.bundelTempIndicatief,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
        ),
      ],
    );
  }

  // ── SPANNINGSVAL ──────────────────────────────────────────────────────────
  Widget _spanningsval(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    return SectieCard(
      titel: l10n.sectSpanningsval,
      icoon: Icons.show_chart,
      children: [
        ResultaatRij(
            label: l10n.lblDeltaUAbs,
            waarde: '${r.deltaUV.toStringAsFixed(3)} V'),
        ResultaatRij(
            label: l10n.lblDeltaUPct,
            waarde: '${r.deltaUPct.toStringAsFixed(3)}%',
            vet: true),
        ResultaatRij(
            label: l10n.lblStatus,
            waarde: r.okSpanning ? l10n.statusVoldoet : l10n.statusOverschreden,
            kleur: r.okSpanning
                ? Colors.green.shade700
                : Colors.red.shade700,
            vet: true),
      ],
    );
  }

  // ── TEMPERATUUR ───────────────────────────────────────────────────────────
  Widget _temperatuur(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final marge = r.maxTempC - r.geleiderTempC;
    return SectieCard(
      titel: l10n.sectTemperatuur,
      icoon: Icons.thermostat,
      children: [
        ResultaatRij(
            label: l10n.lblI2RVerlies,
            waarde: '${r.i2rVerliesWPerM.toStringAsFixed(4)} W/m'),
        ResultaatRij(
            label: l10n.lblTempStijging,
            waarde: '${r.tempStijgingK.toStringAsFixed(2)} K'),
        ResultaatRij(
            label: l10n.lblGeleidertemp,
            waarde: '${r.geleiderTempC.toStringAsFixed(1)} °C',
            vet: true),
        ResultaatRij(
            label: l10n.lblMaximum,
            waarde: '${r.maxTempC.toStringAsFixed(0)} °C'),
        ResultaatRij(
            label: l10n.lblMarge,
            waarde: '${marge >= 0 ? "+" : ""}${marge.toStringAsFixed(1)} K',
            kleur: r.okTemp ? Colors.green.shade700 : Colors.orange.shade700),
      ],
    );
  }

  // ── KORTSLUIT ─────────────────────────────────────────────────────────────
  Widget _kortsluit(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final ok = r.okKortsluit == true;
    final ip = isolatieEigenschappen[r.kabel!.isolatie]!;
    return SectieCard(
      titel: l10n.sectKortsluitvastheid,
      icoon: Icons.flash_on,
      children: [
        ResultaatRij(
            label: 'Min. doorsnede  A = I_k·√t/k',
            waarde: '${r.doorsnedeMinKortsluit.toStringAsFixed(2)} mm²'),
        ResultaatRij(
            label: l10n.lblTempStijging,
            waarde: '${r.deltaTKortsluitK.toStringAsFixed(1)} K'),
        ResultaatRij(
            label: l10n.lblEindtemperatuur,
            waarde: '${r.eindtempKortsluitC.toStringAsFixed(1)} °C',
            vet: true),
        ResultaatRij(
            label: l10n.lblMaxToegestaan,
            waarde: '${ip.maxTempKortsluit.toStringAsFixed(0)} °C'),
        ResultaatRij(
            label: l10n.lblStatus,
            waarde: ok ? l10n.statusVoldoetKort : l10n.statusFaalt,
            kleur: ok ? Colors.green.shade700 : Colors.red.shade700,
            vet: true),
      ],
    );
  }

  // ── MAX LEIDINGLENGTE ─────────────────────────────────────────────────────
  Widget _maxLengte(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final ok = r.okMaxLengte == true;
    return SectieCard(
      titel: l10n.sectMaxLengte,
      icoon: Icons.straighten,
      children: [
        ResultaatRij(
            label: l10n.lblMaxLengteResultaat,
            waarde: '${r.maxLengteM!.toStringAsFixed(1)} m',
            vet: true),
        if (r.ikEind != null)
          ResultaatRij(
              label: l10n.lblIkEind,
              waarde: '${r.ikEind!.toStringAsFixed(0)} A'),
        ResultaatRij(
            label: l10n.lblStatus,
            waarde: ok ? l10n.maxLengteOk : l10n.maxLengteFout,
            kleur: ok ? Colors.green.shade700 : Colors.red.shade700,
            vet: true),
      ],
    );
  }

  // ── BRONIMPEDANTIE ────────────────────────────────────────────────────────
  Widget _bronimpedantie(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final inv = ctx.read<BerekeningProvider>().invoer;
    final zb = r.zbOhm!;
    final zbNet = r.zbNetOhm;
    final zbLus = 2.0 * zb; // loop: fase + N/PE beide door transformator

    String fmt(double ohm) {
      if (ohm < 1.0) return '${(ohm * 1000).toStringAsFixed(2)} mΩ';
      return '${ohm.toStringAsFixed(4)} Ω';
    }

    String fmtA(double a) => a >= 1000
        ? '${(a / 1000).toStringAsFixed(2)} kA'
        : '${a.toStringAsFixed(0)} A';

    Widget rij(String label, String waarde, {bool vet = false, Color? kleur}) =>
        ResultaatRij(label: label, waarde: waarde, vet: vet, kleur: kleur);

    final stelsel = inv.aardingsstelsel;
    final isWaarschuwingsStelsel =
        stelsel == Aardingsstelsel.it || stelsel == Aardingsstelsel.tt;

    return SectieCard(
      titel: l10n.sectBronimpedantieResultaat,
      icoon: Icons.transform,
      children: [
        // Brongegevens: transformator of handmatige Z_upstream
        if (inv.zUpstreamHandmatigMohm != null) ...[
          ResultaatRij(
            label: l10n.lblZUpstreamResultaat,
            waarde: '${inv.zUpstreamHandmatigMohm!.toStringAsFixed(2)} mΩ',
            vet: true,
          ),
        ] else ...[
          ResultaatRij(
            label: l10n.lblTransformatorKva,
            waarde: '${inv.transformatorKva.toInt()} kVA'
                '  (u_cc = ${inv.transformatorUccPct.toStringAsFixed(0)}%)',
          ),
        ],
        ResultaatRij(
          label: l10n.lblAardingsstelsel,
          waarde: stelsel.code,
          kleur: isWaarschuwingsStelsel ? Colors.orange.shade800 : null,
          vet: isWaarschuwingsStelsel,
        ),
        const Divider(height: 10),

        // Impedanties
        if (inv.zUpstreamHandmatigMohm == null) ...[
          rij(l10n.lblZbPerFase, fmt(zb), vet: true),
          if (zbNet != null) rij(l10n.lblZbNet, fmt(zbNet)),
          if (zbNet != null) rij(l10n.lblZbTotaal, fmt(zb), vet: true),
        ],
        rij('Z_bron  (2 × Z_b, lus)', fmt(zbLus)),
        const Divider(height: 10),

        // Kortsluitstromen aan bron
        if (r.ik3fBronA != null)
          rij(l10n.lblIk3fBron, fmtA(r.ik3fBronA!)),
        if (r.ik1fBronA != null)
          rij(l10n.lblIk1fBron, fmtA(r.ik1fBronA!), vet: true),
        const Divider(height: 10),

        // Kabellusimpedantie + eindstroom
        if (r.zKabelLusOhm != null) ...[
          rij(l10n.lblZKabelLus, fmt(r.zKabelLusOhm!)),
          rij(l10n.lblZTotaalLus, fmt(zbLus + r.zKabelLusOhm!), vet: true),
        ],
        if (r.ik1fEindA != null) ...[
          rij(
            l10n.lblIk1fEind,
            fmtA(r.ik1fEindA!),
            vet: true,
            kleur: r.ik1fEindA! < 100 ? Colors.orange.shade800 : null,
          ),
          if (r.ik1fEindA! < 100)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isNL(l10n)
                    ? '⚠  I_k < 100 A aan kabeluiteinde — controleer beveiligingsaanspreking.'
                    : '⚠  I_k < 100 A at cable end — verify protection activation.',
                style: TextStyle(
                    fontSize: 12, color: Colors.orange.shade800),
              ),
            ),
        ],

        // Formule
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            inv.zUpstreamHandmatigMohm != null
                ? (isNL(l10n)
                    ? 'I_k1f = U_fase / (Z_upstream + Z_kabel_lus)  |  Z_upstream handmatig opgegeven'
                    : 'I_k1f = U_phase / (Z_upstream + Z_cable_loop)  |  Z_upstream entered manually')
                : inv.skNetOneindig
                    ? l10n.bronimpedantieFormule
                    : l10n.bronimpedantieFormuleNet,
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  bool isNL(AppLocalizations l10n) => l10n.isNL;

  // ── FOUTEN ────────────────────────────────────────────────────────────────
  Widget _foutMeldingen(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final cs = Theme.of(ctx).colorScheme;
    return Card(
        color: cs.errorContainer,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.error_outline, color: cs.onErrorContainer, size: 18),
                const SizedBox(width: 6),
                Text(l10n.lblFouten,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: cs.onErrorContainer)),
              ]),
              const SizedBox(height: 6),
              for (final f in r.fouten)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(f, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
  }

  Widget _waarschuwingen(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final bg = isDark ? Colors.orange.shade900 : Colors.orange.shade50;
    final fg = isDark ? Colors.orange.shade200 : Colors.orange.shade800;
    return Card(
        color: bg,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.warning_amber_outlined, color: fg, size: 18),
                const SizedBox(width: 6),
                Text(l10n.lblWaarschuwingen,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fg)),
              ]),
              const SizedBox(height: 6),
              for (final w in r.waarschuwingen)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠ '),
                      Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
  }

  // ── KOPIEER ───────────────────────────────────────────────────────────────
  Widget _kopieerKnop(BuildContext ctx, Resultaten r, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.copy),
        label: Text(l10n.btnRapportKopieren),
        onPressed: () {
          final inv = ctx.read<BerekeningProvider>().invoer;
          final tekst = berekeningRapportTekst(inv, r, l10n);
          Clipboard.setData(ClipboardData(text: tekst));
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(l10n.snackRapportGekopieerd)),
          );
        },
      ),
    );
  }

}

// ── Dialogen voor opslaan in project ──────────────────────────────────────────

class _OpslaanInProjectDialog extends StatefulWidget {
  const _OpslaanInProjectDialog({required this.l10n, required this.projecten});
  final AppLocalizations l10n;
  final List<dynamic> projecten; // List<Project>

  @override
  State<_OpslaanInProjectDialog> createState() =>
      _OpslaanInProjectDialogState();
}

class _OpslaanInProjectDialogState extends State<_OpslaanInProjectDialog> {
  late String _projectId;
  final _naamCtr = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectId = (widget.projecten.first as dynamic).id as String;
  }

  @override
  void dispose() {
    _naamCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.berekeningSlaOp),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _projectId,
            decoration: InputDecoration(
              labelText: l10n.projectKiezen,
              border: const OutlineInputBorder(),
            ),
            items: widget.projecten
                .map((p) => DropdownMenuItem<String>(
                      value: (p as dynamic).id as String,
                      child: Text((p as dynamic).naam as String),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _projectId = v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _naamCtr,
            decoration: InputDecoration(
              labelText: l10n.berekeningNaam,
              hintText: l10n.berekeningNaamHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnAnnuleren),
        ),
        FilledButton(
          onPressed: () {
            final naam = _naamCtr.text.trim();
            if (naam.isEmpty) return;
            Navigator.pop(context, (projectId: _projectId, naam: naam));
          },
          child: Text(l10n.btnOpslaan),
        ),
      ],
    );
  }
}

class _NieuwProjectEnOpslaanDialog extends StatelessWidget {
  const _NieuwProjectEnOpslaanDialog({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ctr = TextEditingController();
    return AlertDialog(
      title: Text(l10n.projectNieuw),
      content: TextField(
        controller: ctr,
        decoration: InputDecoration(
          labelText: l10n.projectNaam,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnAnnuleren),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ctr.text),
          child: Text(l10n.btnToevoegen),
        ),
      ],
    );
  }
}
