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

import 'dart:math';
import '../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../models/invoer.dart';
import '../models/resultaten.dart';
import '../data/materiaal_data.dart';
import '../data/catalogus.dart' show adersLabel;

String berekeningRapportTekst(Invoer inv, Resultaten r, AppLocalizations l10n) {
  final buf = StringBuffer();
  final nu = DateTime.now();
  final datum =
      '${nu.day.toString().padLeft(2, '0')}-${nu.month.toString().padLeft(2, '0')}-${nu.year}'
      '  ${nu.hour.toString().padLeft(2, '0')}:${nu.minute.toString().padLeft(2, '0')}';

  void lijn([int n = 64]) => buf.writeln('─' * n);
  void titel(String t) { buf.writeln(); lijn(); buf.writeln(t); lijn(); }
  void rij(String label, String waarde) =>
      buf.writeln('${label.padRight(26)}$waarde');

  buf.writeln(l10n.rapportTitel);
  buf.writeln(l10n.rapportNorm);
  buf.writeln('${l10n.rapportDatum}: $datum');
  buf.writeln('=' * 64);

  // ── 1. INVOER ──────────────────────────────────────────────────
  titel(l10n.rapportInvoer);
  rij('Systeemtype', inv.systeem.label);
  rij('Spanning', '${inv.spanningV.toStringAsFixed(0)} V');
  if (inv.vermogenW != null && inv.vermogenW! > 0) {
    rij('Vermogen', '${inv.vermogenW!.toStringAsFixed(0)} W');
    rij('Eff. stroom (berekend)', '${inv.effectieveStroom.toStringAsFixed(2)} A');
  } else {
    rij('Stroom', '${inv.stroomA.toStringAsFixed(2)} A');
  }
  if (inv.systeem.isAC) rij('Cos φ', inv.cosPhi.toStringAsFixed(3));
  rij('Kabellengte', '${inv.lengteM.toStringAsFixed(1)} m');
  rij('Geleider', inv.geleider.label);
  rij('Isolatie', inv.isolatie.label);
  rij('Aantal aders', adersLabel(inv.aantalAders));
  if (inv.aantalAders == 1 && inv.systeem.isAC) {
    final gpkR = inv.geleidersPerKring;
    final is3F = inv.systeem == Systeemtype.ac3Fase;
    final gpkLabel = is3F
        ? switch (gpkR) {
            3 => '$gpkR  (L1 + L2 + L3)',
            4 => '$gpkR  (L1 + L2 + L3 + N)',
            _ => '$gpkR  (L1 + L2 + L3 + N + PE)',
          }
        : (gpkR == 2 ? '$gpkR  (L + N)' : '$gpkR  (L + N + PE)');
    rij('Geleiders per kring', gpkLabel);
  }
  rij('Leggingswijze', inv.legging.label);
  if (inv.isGrondkabel) {
    rij('Legdiepte', '${inv.diepteM.toStringAsFixed(2)} m');
    rij('Grondtemperatuur', '${inv.grondtempC.toStringAsFixed(0)} °C');
    rij('Bodemweerstand λ', '${inv.lambdaGrond.toStringAsFixed(2)} K·m/W');
    if (inv.cyclischProfiel != null) {
      rij('Cyclisch profiel', l10n.rapportCyclischIngeschakeld(
          inv.cyclischNKringen, inv.cyclischAanliggend));
    }
  } else {
    rij('Omgevingstemperatuur', '${inv.omgevingstempC.toStringAsFixed(0)} °C');
    if (inv.pvLaagActief) {
      const laagNamen = {
        PvLaagPositie.topLaag:    'bovenste laag',
        PvLaagPositie.tweedeLaag: '2e laag',
        PvLaagPositie.middenLaag: 'middenlaag',
        PvLaagPositie.onderLaag:  'onderste laag',
      };
      rij('PV-laagpositie ΔT_zon',
          '+${inv.deltaTZonPvLaag.toStringAsFixed(0)} K'
          '  (${laagNamen[inv.pvLaagPositie]}  — IEC 60364-5-52)');
    } else if (inv.zonlichtToeslagK > 0) {
      rij('Zonlichttoeslag', '+${inv.zonlichtToeslagK.toStringAsFixed(0)} K  (NEN 1010)');
    }
    if (inv.windkoelingActief) {
      final dtW = inv.deltaTWindKoeling;
      rij('Windkoeling ΔT_wind',
          '${dtW >= 0 ? "+" : ""}${dtW.toStringAsFixed(1)} K'
          '  (${inv.windsnelheid.label}'
          '${inv.gootMetDeksel ? ", met deksel" : ""})');
    }
  }
  if (inv.nParallel > 1) {
    rij('Parallel kabels', '${inv.nParallel} ${l10n.rapportParallelKabels}');
  }
  rij('Max. spanningsval', '${inv.maxSpanningsvalPct.toStringAsFixed(1)} %');
  if (inv.kortsluitstroomA > 0) {
    rij('Kortsluitstroom I_k', '${inv.kortsluitstroomA.toStringAsFixed(0)} A');
    rij('Kortsluitduur', '${inv.kortsluitduurMs.toStringAsFixed(0)} ms');
  } else {
    rij('Kortsluittoets', l10n.rapportKortsluitNiet);
  }
  if (inv.harmonischenActief) {
    final iN = 3.0 * (inv.derdeHarmonischePct / 100.0) * inv.effectieveStroom;
    rij('3e harmonische', '${inv.derdeHarmonischePct.toStringAsFixed(0)} %  van fasestroom');
    rij('Nulpuntsstroom I_N', '${iN.toStringAsFixed(1)} A'
        '  = 3 × ${(inv.derdeHarmonischePct / 100).toStringAsFixed(2)} × ${inv.effectieveStroom.toStringAsFixed(1)} A');
  }
  if (inv.forceerDoorsnedemm2 != null) {
    rij('Geforceerde doorsnede', '${inv.forceerDoorsnedemm2} mm²');
  }
  if (inv.bundel != null) {
    rij('Bundeling', '${inv.bundel!.nHorizontaal} naast × ${inv.bundel!.nVerticaal} hoog'
        '  (${inv.bundel!.totaalKabels} kabels)');
  }

  if (r.kabel == null) {
    titel('RESULTAAT');
    buf.writeln(l10n.rapportGeenKabel);
  } else {
    final k = r.kabel!;
    final ip = isolatieEigenschappen[k.isolatie]!;

    titel(l10n.rapportKabel);
    rij('Type', k.naam);
    rij('Doorsnede', '${k.doorsnedemm2} mm²');
    rij('Geleider', k.geleider.label);
    rij('Isolatie', '${k.isolatie.label}'
        '  (max. ${ip.maxTempContinu.toInt()} °C continu'
        ', ${ip.maxTempKortsluit.toInt()} °C KS)');
    rij('Aantal aders', '${k.aantalAders}×');
    if (inv.aantalAders == 1 && inv.systeem.isAC) {
      final gpkK = inv.geleidersPerKring;
      final totaalK = r.nParallel * gpkK;
      final is3FK = inv.systeem == Systeemtype.ac3Fase;
      final gpkLabelK = is3FK
          ? switch (gpkK) {
              3 => '$gpkK geleiders per kring  (L1 + L2 + L3)',
              4 => '$gpkK geleiders per kring  (L1 + L2 + L3 + N)',
              _ => '$gpkK geleiders per kring  (L1 + L2 + L3 + N + PE)',
            }
          : (gpkK == 2 ? '$gpkK geleiders per kring  (L + N)' : '$gpkK geleiders per kring  (L + N + PE)');
      rij('Singel-configuratie', gpkLabelK);
      rij('Totaal singels',
          '$totaalK stuks${r.nParallel > 1 ? "  (${r.nParallel}× parallel × $gpkK)" : ""}');
    }
    rij('Buitendiameter', '${k.buitendiameter.toStringAsFixed(1)} mm');
    rij('R_AC @ 20°C', '${k.rAcPerKm20C.toStringAsFixed(4)} Ω/km');
    rij('X @ 50 Hz', '${k.xAcPerKm.toStringAsFixed(4)} Ω/km');

    titel(l10n.rapportCF);
    final tMax = ip.maxTempContinu;
    final tRef = ip.refTempTabel;
    // θ_eff opbouw: toon uitsplitsing als zon of wind actief is
    if (!inv.isGrondkabel && (inv.pvLaagActief || inv.zonlichtToeslagK > 0 || inv.windkoelingActief)) {
      final tBase = inv.omgevingstempC;
      final dtZonR = inv.pvLaagActief ? inv.deltaTZonPvLaag : inv.zonlichtToeslagK;
      final dtWindR = inv.windkoelingActief ? inv.deltaTWindKoeling : 0.0;
      final delen = <String>['${tBase.toStringAsFixed(1)} °C'];
      if (dtZonR > 0) delen.add('+${dtZonR.toStringAsFixed(1)} K (zon)');
      if (dtWindR != 0) delen.add('${dtWindR >= 0 ? "+" : ""}${dtWindR.toStringAsFixed(1)} K (wind)');
      rij('θ_eff (omgeving)', '${r.tEffectief.toStringAsFixed(1)} °C  = ${delen.join(" ")}');
    } else {
      rij('θ_eff (omgeving)', '${r.tEffectief.toStringAsFixed(1)} °C');
    }
    rij('f_T  (temperatuur)', '${r.fT.toStringAsFixed(4)}'
        '  = √[(${tMax.toInt()}−${r.tEffectief.toStringAsFixed(1)})/(${tMax.toInt()}−${tRef.toInt()})]');
    if (r.bundelPositieWorst != null) {
      rij('f_bundel', '${r.fBundel.toStringAsFixed(4)}  = f_h × f_v');
      rij('  f_h (horizontaal)', '${r.fHorizontaal.toStringAsFixed(4)}  (IEC tabel B.52.20)');
      rij('  f_v (stapeling)', '${r.fVerticaal.toStringAsFixed(4)}  (IEC tabel B.52.21)');
      rij('  Maatg. positie', '(${r.bundelPositieWorst!.$1}, ${r.bundelPositieWorst!.$2})  — centrum bundel');
    } else {
      rij('f_bundel', '${r.fBundel.toStringAsFixed(4)}  [geen bundeling]');
    }
    rij('f_grond', '${r.fGrond.toStringAsFixed(4)}'
        '${inv.isGrondkabel ? "  (λ=${inv.lambdaGrond.toStringAsFixed(2)} K·m/W)" : "  [bovengronds]"}');
    if (r.fCyclisch != 1.0) {
      rij('M  (cyclisch)', '${r.fCyclisch.toStringAsFixed(4)}  (NEN IEC 60583-1:2002)');
    }
    if (r.iNeutraal > 0) {
      rij('f_harm  (harmonischen)', '${r.fHarmonisch.toStringAsFixed(4)}  (NEN 1010 Bijlage 52.E.1)');
      rij('  Grondslag', r.harmonischOpNul
          ? '${l10n.rapportNulpuntsstroom}${r.iNeutraal.toStringAsFixed(1)} A'
          : l10n.rapportFasestroom);
    }
    final fTotaalFormule = [
      'f_T × f_bundel × f_grond',
      if (r.fCyclisch != 1.0) ' × M',
      if (r.iNeutraal > 0) ' × f_harm',
    ].join();
    rij('f_TOTAAL', '${r.fTotaal.toStringAsFixed(4)}  = $fTotaalFormule');

    final int sOffset = (inv.cyclischProfiel != null ? 1 : 0) +
        (inv.harmonischenActief ? 1 : 0);

    if (inv.cyclischProfiel != null) {
      titel(l10n.rapportCyclischNr(4));
      buf.writeln('Formule: M = 1 / √( Σ Yᵢ·ΔθR(i)  +  μ·(1 − θR(6)) )');
      rij('Aantal kringen N', '${inv.cyclischNKringen}');
      rij('Ligging kringen', inv.cyclischAanliggend
          ? 'Aanliggend (touching)'
          : 'Gespreid (spaced)');
      if (inv.cyclischNKringen > 1 && inv.cyclischHartOpHartMm > 0) {
        rij('Hart-op-hart', '${inv.cyclischHartOpHartMm.toStringAsFixed(0)} mm');
      } else if (inv.cyclischNKringen > 1) {
        rij('Hart-op-hart', l10n.rapportAanliggendKabeldiameter);
      }
      rij('Legdiepte L', '${inv.diepteM.toStringAsFixed(2)} m');
      rij('Grondtemperatuur Tgr', '${inv.grondtempC.toStringAsFixed(0)} °C');
      rij('Thermische weerstand ξ', '${inv.lambdaGrond.toStringAsFixed(2)} K·m/W');
      buf.writeln();
      buf.writeln('Belastingsprofiel I/Imax per uur:');
      final p = inv.cyclischProfiel!;
      for (int rw = 0; rw < 4; rw++) {
        final start = rw * 6;
        final label = '  Uur ${start.toString().padLeft(2)}–${(start + 5).toString().padLeft(2)}';
        final vals = List.generate(6, (c) {
          final v = p[start + c];
          return v.toStringAsFixed(2).padLeft(5);
        }).join('  ');
        buf.writeln('$label:  $vals');
      }
      buf.writeln();
      final mu = p.fold(0.0, (s, v) => s + v * v) / 24;
      final maxI = p.reduce((a, b) => a > b ? a : b);
      rij('μ  (gem. Yi = (I/Imax)²)', mu.toStringAsFixed(4));
      rij('Piekwaarde I/Imax', maxI.toStringAsFixed(2));
      rij('Cyclische factor M', r.fCyclisch.toStringAsFixed(4));
      rij('Toelichting', l10n.rapportMHogerBelasting);
    }

    if (inv.harmonischenActief) {
      final sHarm = (inv.cyclischProfiel != null ? 5 : 4);
      titel(l10n.rapportHarmNr(sHarm));
      buf.writeln('Tabel E.52.1: correctiefactoren voor 4- of 5-aderige 3-fase kabels');
      buf.writeln('  h3 (%)    Grondslag        f_harm');
      buf.writeln('  0–15      fasestroom        1,00');
      buf.writeln('  15–33     fasestroom        0,86');
      buf.writeln('  33–45     nulpuntsstroom    0,86');
      buf.writeln('  > 45      nulpuntsstroom    1,00');
      buf.writeln();
      rij('3e harmonische h3', '${inv.derdeHarmonischePct.toStringAsFixed(0)} %');
      rij('f_harm', r.fHarmonisch.toStringAsFixed(4));
      rij('I_N = 3 × h3 × I_fase', '${r.iNeutraal.toStringAsFixed(1)} A');
      rij('Grondslag kabelkeuze', r.harmonischOpNul
          ? 'nulpuntsstroom  (h3 > 33%)'
          : 'fasestroom  (h3 ≤ 33%)');
    }

    titel(l10n.rapportBelNrVan(4 + sOffset, ''));
    if (r.nParallel > 1) {
      rij('Configuratie', '${r.nParallel} kabels parallel per fase');
      rij('I_totaal', '${r.iGevraagd.toStringAsFixed(2)} A');
      rij('I per kabel', '${r.iPerKabel.toStringAsFixed(2)} A'
          '  = ${r.iGevraagd.toStringAsFixed(2)} / ${r.nParallel}');
    }
    final methode = inv.legging.isVrijeLucht ? 'E (vrije lucht)' : 'C (in buis/wand)';
    rij('I_z0  (tabel, 30°C)', '${r.iz0.toStringAsFixed(1)} A  per kabel  [methode $methode]');
    rij('I_z  (gecorrigeerd)', '${r.iz.toStringAsFixed(1)} A  = ${r.iz0.toStringAsFixed(1)} × ${r.fTotaal.toStringAsFixed(4)}');
    final iGrondslag = r.harmonischOpNul ? r.iNeutraal : r.iPerKabel;
    final grondslagLabel = r.harmonischOpNul ? 'I_N  (maatgevend)' : 'I_gevraagd';
    rij(grondslagLabel, '${iGrondslag.toStringAsFixed(2)} A  per kabel');
    if (r.harmonischOpNul) {
      rij('I_fase', '${r.iPerKabel.toStringAsFixed(2)} A  per kabel');
    }
    rij('Veiligheidsmarge', '${r.margeStroomPct >= 0 ? "+" : ""}${r.margeStroomPct.toStringAsFixed(1)} %'
        '  = (${r.iz.toStringAsFixed(1)}/${iGrondslag.toStringAsFixed(2)} − 1) × 100');

    // Bundel positievergelijking
    if (r.bundelPositieWorst != null) {
      titel('BUNDEL: POSITIEVERGELIJKING');
      if (r.bundelZonGesplitst) {
        // 4 kolommen: centrum (geen zon) | bov.laag centrum ☀ | bov.laag hoek ☀ | lag.lagen hoek
        String k(String s) => s.padLeft(13);
        buf.writeln('${''.padRight(26)}${k("Cent.bundel")}${k("Bov.laag ctr")}${k("Bov.laag hoek")}${k("Lag.lag.hoek")}');
        buf.writeln('${''.padRight(26)}${k("(geen zon)")}${k("(volle zon ☀)")}${k("(volle zon ☀)")}${k("(geen zon)")}');
        buf.writeln('─' * 64);
        buf.writeln('${"f_bundel".padRight(26)}${k(r.fBundel.toStringAsFixed(3))}${k(r.fBundelBovensteC!.toStringAsFixed(3))}${k(r.fBundelRand.toStringAsFixed(3))}${k(r.fBundelRand.toStringAsFixed(3))}');
        buf.writeln('${"I_z (A)".padRight(26)}${k(r.iz.toStringAsFixed(1))}${k(r.izBovensteC!.toStringAsFixed(1))}${k(r.izRand.toStringAsFixed(1))}${k(r.izLagereHoek!.toStringAsFixed(1))}');
        buf.writeln('${"Marge (%)".padRight(26)}${k((r.margeStroomPct >= 0 ? "+" : "") + r.margeStroomPct.toStringAsFixed(1) + " %")}${k((r.margeBovensteC! >= 0 ? "+" : "") + r.margeBovensteC!.toStringAsFixed(1) + " %")}${k((r.margeStroomPctRand >= 0 ? "+" : "") + r.margeStroomPctRand.toStringAsFixed(1) + " %")}${k((r.margeLagereHoek! >= 0 ? "+" : "") + r.margeLagereHoek!.toStringAsFixed(1) + " %")}');
        buf.writeln('${"T geleider (°C)".padRight(26)}${k(r.geleiderTempCWarm.toStringAsFixed(1))}${k(r.geleiderTempBovensteC!.toStringAsFixed(1))}${k(r.geleiderTempCKoud.toStringAsFixed(1))}${k(r.geleiderTempLagereHoek!.toStringAsFixed(1))}');
        buf.writeln();
        buf.writeln('Zon uitsluitend op bovenste laag; lagere lagen afgeschermd.');
        buf.writeln('fV_top = fV(2): bovenste laag heeft alleen laag direct eronder als thermische buur.');
      } else {
        // 2 kolommen: centrum | hoek
        String k(String s) => s.padLeft(16);
        buf.writeln('${"".padRight(26)}${k("Centrum")}${k("Hoek")}');
        buf.writeln('─' * 64);
        buf.writeln('${"f_bundel".padRight(26)}${k(r.fBundel.toStringAsFixed(3))}${k(r.fBundelRand.toStringAsFixed(3))}');
        buf.writeln('${"I_z (A)".padRight(26)}${k(r.iz.toStringAsFixed(1))}${k(r.izRand.toStringAsFixed(1))}');
        buf.writeln('${"Marge (%)".padRight(26)}${k((r.margeStroomPct >= 0 ? "+" : "") + r.margeStroomPct.toStringAsFixed(1) + " %")}${k((r.margeStroomPctRand >= 0 ? "+" : "") + r.margeStroomPctRand.toStringAsFixed(1) + " %")}');
        buf.writeln('${"T geleider (°C)".padRight(26)}${k(r.geleiderTempCWarm.toStringAsFixed(1))}${k(r.geleiderTempCKoud.toStringAsFixed(1))}');
      }
    }

    titel(l10n.rapportSVNr(5 + sOffset));
    final gelProp = geleiderEigenschappen[k.geleider]!;
    final rAt = k.rAcPerKm20C * (1 + gelProp.alpha20 * (tMax - 20)) / 1000;
    final xM = k.xAcPerKm / 1000;
    switch (inv.systeem) {
      case Systeemtype.ac1Fase:
        final sinPhi = sqrt(max(0.0, 1 - inv.cosPhi * inv.cosPhi));
        buf.writeln('Formule:  ΔU = 2 · I · L · (R·cosφ + X·sinφ)');
        rij('R_AC @ ${tMax.toInt()}°C', '${rAt.toStringAsFixed(6)} Ω/m');
        rij('X', '${xM.toStringAsFixed(6)} Ω/m');
        rij('sin φ', sinPhi.toStringAsFixed(4));
        buf.writeln('ΔU = 2 × ${r.iPerKabel.toStringAsFixed(2)} × ${inv.lengteM.toStringAsFixed(1)}'
            ' × (${rAt.toStringAsFixed(6)}×${inv.cosPhi.toStringAsFixed(3)} + ${xM.toStringAsFixed(6)}×${sinPhi.toStringAsFixed(4)})');
      case Systeemtype.ac3Fase:
        final sinPhi = sqrt(max(0.0, 1 - inv.cosPhi * inv.cosPhi));
        buf.writeln('Formule:  ΔU = √3 · I · L · (R·cosφ + X·sinφ)');
        rij('R_AC @ ${tMax.toInt()}°C', '${rAt.toStringAsFixed(6)} Ω/m');
        rij('X', '${xM.toStringAsFixed(6)} Ω/m');
        rij('sin φ', sinPhi.toStringAsFixed(4));
        buf.writeln('ΔU = √3 × ${r.iPerKabel.toStringAsFixed(2)} × ${inv.lengteM.toStringAsFixed(1)}'
            ' × (${rAt.toStringAsFixed(6)}×${inv.cosPhi.toStringAsFixed(3)} + ${xM.toStringAsFixed(6)}×${sinPhi.toStringAsFixed(4)})');
      case Systeemtype.dc2Draad:
        final rDc = gelProp.rDc(k.doorsnedemm2, 1.0, t: tMax);
        buf.writeln('Formule:  ΔU = 2 · I · R_DC · L');
        rij('R_DC @ ${tMax.toInt()}°C', '${rDc.toStringAsFixed(6)} Ω/m');
        buf.writeln('ΔU = 2 × ${r.iPerKabel.toStringAsFixed(2)} × ${rDc.toStringAsFixed(6)} × ${inv.lengteM.toStringAsFixed(1)}');
      case Systeemtype.dcAarde:
        final rDc = gelProp.rDc(k.doorsnedemm2, 1.0, t: tMax);
        buf.writeln('Formule:  ΔU = I · R_DC · L  (aardretour)');
        rij('R_DC @ ${tMax.toInt()}°C', '${rDc.toStringAsFixed(6)} Ω/m');
        buf.writeln('ΔU = ${r.iPerKabel.toStringAsFixed(2)} × ${rDc.toStringAsFixed(6)} × ${inv.lengteM.toStringAsFixed(1)}');
    }
    rij('ΔU (absoluut)', '${r.deltaUV.toStringAsFixed(4)} V');
    rij('ΔU (procent)', '${r.deltaUPct.toStringAsFixed(3)} %');
    rij('Max. toegestaan', '${inv.maxSpanningsvalPct.toStringAsFixed(1)} %');
    rij('Status', r.okSpanning ? l10n.rapportVoldoet : l10n.rapportOverschreden);

    titel(l10n.rapportTempNr(6 + sOffset));
    final rDcM = gelProp.rDc(k.doorsnedemm2, 1.0, t: tMax);
    rij('R_DC @ ${tMax.toInt()}°C', '${rDcM.toStringAsFixed(6)} Ω/m');
    rij('I²R-verlies', '${r.i2rVerliesWPerM.toStringAsFixed(4)} W/m');
    if (inv.isGrondkabel) {
      buf.writeln('Formule:  ΔT = P · (λ/2π) · ln(4u/d)  [IEC 60287-2-1]');
      rij('Diepte', '${inv.diepteM.toStringAsFixed(2)} m');
      rij('Buitendiameter', '${k.buitendiameter.toStringAsFixed(1)} mm');
    } else {
      buf.writeln('Formule:  ΔT = P / (π · D · h_conv)  [h_conv = 10 W/(m²·K)]');
      rij('Buitendiameter', '${k.buitendiameter.toStringAsFixed(1)} mm');
    }
    rij('Temperatuurstijging ΔT', '${r.tempStijgingK.toStringAsFixed(2)} K');
    rij('Omgevingstemperatuur', '${r.tEffectief.toStringAsFixed(1)} °C');
    rij('Geleidertemperatuur', '${r.geleiderTempC.toStringAsFixed(1)} °C');
    rij('Maximum toegestaan', '${r.maxTempC.toStringAsFixed(0)} °C');
    rij('Marge', '${(r.maxTempC - r.geleiderTempC) >= 0 ? "+" : ""}${(r.maxTempC - r.geleiderTempC).toStringAsFixed(1)} K');
    rij('Status', r.okTemp ? l10n.rapportVoldoet : l10n.rapportWaarschuwingTemp);

    if (r.okKortsluit != null) {
      titel(l10n.rapportKSNr(7 + sOffset));
      final kVal = kWaarden[(k.geleider, k.isolatie)] ?? 0.0;
      final tS = inv.kortsluitduurMs / 1000.0;
      final ikPK = inv.kortsluitstroomA / r.nParallel;
      buf.writeln('Formule min. doorsnede:  A_min = I_k · √t / k');
      rij('I_k (per kabel)', '${ikPK.toStringAsFixed(0)} A'
          '${r.nParallel > 1 ? "  = ${inv.kortsluitstroomA.toStringAsFixed(0)}/${r.nParallel}" : ""}');
      rij('t (kortsluitduur)', '${tS.toStringAsFixed(3)} s  (${inv.kortsluitduurMs.toStringAsFixed(0)} ms)');
      rij('k (materiaalconstante)', '$kVal  [${k.geleider.label} ${k.isolatie.label}]');
      rij('A_min', '${r.doorsnedeMinKortsluit.toStringAsFixed(2)} mm²');
      rij('Toegepaste doorsnede', '${k.doorsnedemm2} mm²');
      buf.writeln();
      buf.writeln('Formule eindtemperatuur:  ΔT = (I_k/A)² · t / c  →  T_eind = T_max + ΔT');
      rij('Temperatuurstijging ΔT', '${r.deltaTKortsluitK.toStringAsFixed(1)} K');
      rij('Starttemperatuur (T_max)', '${ip.maxTempContinu.toInt()} °C');
      rij('Eindtemperatuur', '${r.eindtempKortsluitC.toStringAsFixed(1)} °C');
      rij('Max. toegestaan', '${ip.maxTempKortsluit.toInt()} °C');
      rij('Status', r.okKortsluit! ? l10n.rapportVoldoet : l10n.rapportFaalt);
    }

    if (r.okMaxLengte != null) {
      titel(l10n.rapportMaxLengte);
      final ia = inv.beveiligingIa;
      if (inv.beveiligingType != null) {
        rij('Beveiligingstype', inv.beveiligingType!.label);
      }
      if (ia != null) rij('Activeringsstroom I_a', '${ia.toStringAsFixed(1)} A');
      rij('Maximale leidinglengte', '${r.maxLengteM!.toStringAsFixed(1)} m');
      if (r.ikEind != null) rij('I_k aan kabeluiteinde', '${r.ikEind!.toStringAsFixed(0)} A');
      rij('Opgegeven lengte', '${inv.lengteM.toStringAsFixed(1)} m');
      rij('Status', r.okMaxLengte! ? l10n.rapportVoldoet : l10n.rapportFaalt);
    }
  }

  buf.writeln();
  buf.writeln('=' * 64);
  buf.writeln(r.voldoet ? l10n.rapportEindVoldoet : l10n.rapportEindGefaald);
  buf.writeln('=' * 64);
  if (r.fouten.isNotEmpty) {
    buf.writeln('\n${l10n.rapportFouten}');
    for (final f in r.fouten) { buf.writeln('  • $f'); }
  }
  if (r.waarschuwingen.isNotEmpty) {
    buf.writeln('\n${l10n.rapportWaarschuwingen}');
    for (final w in r.waarschuwingen) { buf.writeln('  ⚠ $w'); }
  }
  buf.writeln('\n${l10n.rapportFooter}');
  return buf.toString();
}
