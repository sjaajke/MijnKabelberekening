import 'dart:math' as math;
import '../models/enums.dart';
import '../models/invoer.dart';
import '../models/kabel_spec.dart';
import '../models/resultaten.dart';
import '../data/catalogus.dart';
import '../data/materiaal_data.dart';
import '../data/transformatoren.dart';
import 'correctiefactoren.dart';
import 'cyclisch.dart';
import 'spanningsval.dart';
import 'thermisch.dart';
import 'kortsluit.dart';

/// Orkestreert de volledige kabelberekening.
///
/// Workflow:
///   1. Valideer invoer
///   2. Bepaal correctiefactoren
///   3. Bepaal min. doorsnede vanuit kortsluit
///   4. Zoek kleinste geschikte kabel (iteratief)
///   5. Bereken spanningsval
///   6. Bereken temperatuurstijging
///   7. Kortsluittoets
///   8. Eindoordeel
class KabelOntwerper {
  final Invoer invoer;

  KabelOntwerper(this.invoer);

  Resultaten bereken() {
    final fouten = <String>[];
    final waarschuwingen = <String>[];

    // 1. Valideer
    final I = invoer.effectieveStroom;          // totale stroom
    final n = (invoer.nParallel >= 1) ? invoer.nParallel : 1;
    final catAders = invoer.aantalAders;        // altijd het werkelijke adertal
    // Singel in 3-fase circuit: gebruik izC3/izE3 (3 belaste aders) i.p.v. izC/izE (2 belaste aders)
    final singelIn3Fase = invoer.aantalAders == 1 && invoer.systeem == Systeemtype.ac3Fase;
    final iPerKabel = I / n;                    // stroom per kabel
    if (n > 1 && !invoer.systeem.isAC) {
      waarschuwingen.add(
        'Parallel kabels is alleen van toepassing bij AC-systemen. '
        'nParallel genegeerd (n=1 gebruikt).',
      );
    }
    if (I <= 0) {
      fouten.add('Stroom/vermogen moet > 0 zijn.');
      return Resultaten(fouten: fouten, iGevraagd: I);
    }
    if (invoer.spanningV <= 0) {
      fouten.add('Spanning moet > 0 V zijn.');
      return Resultaten(fouten: fouten, iGevraagd: I);
    }
    if (invoer.lengteM <= 0) {
      fouten.add('Kabellengte moet > 0 m zijn.');
      return Resultaten(fouten: fouten, iGevraagd: I);
    }

    // 2. Correctiefactoren
    final isolProp = isolatieEigenschappen[invoer.isolatie]!;
    final tOmgBase = invoer.isGrondkabel ? invoer.grondtempC : invoer.omgevingstempC;
    // Zonstralings-toeslag alleen voor bovengrondse leggingen (IEC 60364-5-52 / NEN 1010)
    final tOmg = tOmgBase + (invoer.isGrondkabel ? 0.0 : invoer.zonlichtToeslagK);
    final fT = Correctiefactoren.fTemperatuur(
      tOmg,
      isolProp.maxTempContinu,
      tReferentie: isolProp.refTempTabel,
    );

    double fH = 1.0, fV = 1.0, fBundel = 1.0;
    (int, int)? bundelPos;

    if (invoer.bundel != null && invoer.bundel!.totaalKabels > 1) {
      fH = Correctiefactoren.fHorizontaalBundeling(invoer.bundel!.nHorizontaal);
      fV = Correctiefactoren.fVerticalStapeling(invoer.bundel!.nVerticaal);
      fBundel = fH * fV;
      bundelPos = invoer.bundel!.slechtstePositie;
    }

    final fGrond = invoer.isGrondkabel
        ? Correctiefactoren.fBodemweerstand(invoer.lambdaGrond)
        : 1.0;

    final fLegging = Correctiefactoren.fLegging(invoer.legging, invoer.isolatie);

    // fBase: gecombineerde IEC 60364-5-52 correctiefactor (zonder cyclisch en harmonischen)
    final fBase = fT * fLegging * fBundel * fGrond;

    if (fBase <= 0) {
      fouten.add(
        'Gecombineerde correctiefactor ≤ 0 '
        '(f_T=${ fT.toStringAsFixed(3)}). Omgevingstemperatuur te hoog?',
      );
      return Resultaten(
        fouten: fouten,
        iGevraagd: I,
        tEffectief: tOmg,
        fT: fT, fLegging: fLegging,
        fBundel: fBundel, fGrond: fGrond, fTotaal: fBase,
        fHorizontaal: fH, fVerticaal: fV,
      );
    }

    // 2b. Harmonischencorrectie (NEN 1010 Bijlage 52.E.1)
    // Alleen van toepassing bij ac3Fase met 4 of 5 aders en h3 > 0.
    var fHarmonisch = 1.0;
    var iDesign = iPerKabel;  // maatgevende stroom voor kabelkeuze
    var iNeutraal = 0.0;
    var harmonischOpNul = false;
    if (invoer.harmonischenActief) {
      final harm = Correctiefactoren.fHarmonischen(iPerKabel, invoer.derdeHarmonischePct);
      fHarmonisch = harm.fHarm;
      iDesign = harm.iDesign;
      iNeutraal = harm.iNeutraal;
      harmonischOpNul = harm.iDesign == harm.iNeutraal;
      if (harmonischOpNul) {
        waarschuwingen.add(
          '3e harmonische ${invoer.derdeHarmonischePct.toStringAsFixed(0)}% > 33%: '
          'nulpuntsstroom I_N=${iNeutraal.toStringAsFixed(1)} A is maatgevend '
          '(NEN 1010 Bijlage 52.E.1).',
        );
      }
    }

    // 3. Min. doorsnede kortsluit (per kabel: I_k / n bij gelijke impedantie)
    double doorsnedeMinKs = 0.0;
    if (invoer.kortsluitstroomA > 0) {
      final tS = invoer.kortsluitduurMs / 1000.0;
      final ikPerKabel = invoer.kortsluitstroomA / n;
      doorsnedeMinKs = Kortsluit.minDoorsnede(
        ikPerKabel, tS, invoer.geleider, invoer.isolatie,
      );
    }

    // 4. Selecteer kabel (automatisch of geforceerd)
    // De cyclische factor M wordt per kandidaat-kabel berekend omdat M afhankelijk
    // is van de kabeldiameter en het Joule-verlies W = I²·R van die kabel.
    final isolPropTMax = isolatieEigenschappen[invoer.isolatie]!.maxTempContinu;
    final doCyclisch = invoer.isGrondkabel && invoer.cyclischProfiel != null;

    double mVoorKabel(KabelSpec k) {
      if (!doCyclisch) return 1.0;
      final rM = Thermisch.rDcOpTemp(k);
      final w = iPerKabel * iPerKabel * rM; // W/m bij Tmax
      final deM = k.buitendiameter / 1000.0; // meter
      final dp1 = invoer.cyclischHartOpHartMm > 0
          ? invoer.cyclischHartOpHartMm / 1000.0
          : deM; // aanliggend: hart-op-hart = diameter
      return CyclischeFactor.bereken(
        profiel: invoer.cyclischProfiel!,
        de: deM,
        L: invoer.diepteM,
        xi: invoer.lambdaGrond,
        tMax: isolPropTMax,
        tGr: invoer.grondtempC,
        W: w,
        N: invoer.cyclischNKringen,
        dp1: dp1,
        aanliggend: invoer.cyclischAanliggend,
      );
    }

    KabelSpec? kabel;
    var iz0 = 0.0;
    var iz = 0.0;
    var fCyclisch = 1.0;

    final geforceerd = invoer.forceerDoorsnedemm2 != null;

    if (geforceerd) {
      // Geforceerde doorsnede: gebruik opgegeven waarde, toets alle criteria
      final A = invoer.forceerDoorsnedemm2!;
      final k = kabelCatalogus[(invoer.geleider, invoer.isolatie, A, catAders)];
      if (k == null) {
        fouten.add(
          'Doorsnede $A mm² niet beschikbaar voor '
          '${invoer.geleider.label} ${invoer.isolatie.label}.',
        );
        return Resultaten(
          fouten: fouten,
          iGevraagd: I,
          tEffectief: tOmg,
          fT: fT, fLegging: fLegging,
          fBundel: fBundel, fGrond: fGrond, fTotaal: fBase,
          fHorizontaal: fH, fVerticaal: fV,
          doorsnedeMinKortsluit: doorsnedeMinKs,
          bundelPositieWorst: bundelPos,
        );
      }
      kabel = k;
      fCyclisch = mVoorKabel(k);
      iz0 = singelIn3Fase ? k.izC3 : k.izC;
      iz = iz0 * fBase * fCyclisch * fHarmonisch;
      if (iz < iDesign) {
        final grondslag = harmonischOpNul ? 'I_N' : 'I_per_kabel';
        fouten.add(
          'Geforceerde doorsnede onderdimensioneerd: '
          'I_z=${iz.toStringAsFixed(1)} A < $grondslag=${iDesign.toStringAsFixed(1)} A'
          '${n > 1 ? " (I_totaal=${I.toStringAsFixed(1)} A / $n)" : ""}.',
        );
      }
      if (A < doorsnedeMinKs) {
        fouten.add(
          'Geforceerde doorsnede $A mm² < kortsluit-minimum '
          '${doorsnedeMinKs.toStringAsFixed(2)} mm².',
        );
      }
    } else {
      // Automatisch: kleinste doorsnede die aan alle eisen voldoet
      final doorsnedes = standaardDoorsnedes(invoer.geleider);
      var gevonden = false;

      for (final A in doorsnedes) {
        final k = kabelCatalogus[(invoer.geleider, invoer.isolatie, A, catAders)];
        if (k == null) continue;

        iz0 = singelIn3Fase ? k.izC3 : k.izC;
        if (iz0 <= 0) continue;

        final m = mVoorKabel(k);
        iz = iz0 * fBase * m * fHarmonisch;

        if (iz < iDesign) continue;

        if (A < doorsnedeMinKs) {
          waarschuwingen.add(
            '$A mm² voldoet aan stroomeis maar niet aan kortsluit-eis '
            '(min. ${doorsnedeMinKs.toStringAsFixed(2)} mm²).',
          );
          continue;
        }

        kabel = k;
        fCyclisch = m;
        gevonden = true;
        break;
      }

      if (!gevonden) {
        final grondslag = harmonischOpNul
            ? 'I_N=${iDesign.toStringAsFixed(1)} A (nulpuntsstroom)'
            : 'I_per_kabel=${iDesign.toStringAsFixed(1)} A';
        fouten.add(
          'Geen geschikte kabel gevonden voor '
          '$grondslag '
          '(I_totaal=${I.toStringAsFixed(1)} A / $n) '
          'met f_totaal=${(fBase * fHarmonisch).toStringAsFixed(3)}.',
        );
        return Resultaten(
          fouten: fouten,
          waarschuwingen: waarschuwingen,
          iGevraagd: I,
          tEffectief: tOmg,
          fT: fT, fLegging: fLegging,
          fBundel: fBundel, fGrond: fGrond, fTotaal: fBase * fHarmonisch,
          fHarmonisch: fHarmonisch, harmonischOpNul: harmonischOpNul,
          iNeutraal: iNeutraal,
          fHorizontaal: fH, fVerticaal: fV,
          doorsnedeMinKortsluit: doorsnedeMinKs,
          bundelPositieWorst: bundelPos,
        );
      }
    }

    // fTotaal = alle factoren gecombineerd (IEC 60364 × cyclisch × harmonischen)
    final fTotaal = fBase * fCyclisch * fHarmonisch;
    final marge = iz > 0 ? (iz / iDesign - 1) * 100 : 0.0;

    // 5. Spanningsval (per kabel: I/n door één kabel = zelfde ΔU als parallel geheel)
    final (deltaUV, deltaUPct) = Spanningsval.bereken(invoer, kabel!,
        iOverride: iPerKabel);
    final okSpanning = deltaUPct <= invoer.maxSpanningsvalPct;
    if (!okSpanning) {
      fouten.add(
        'Spanningsval ${deltaUPct.toStringAsFixed(2)}% > '
        '${invoer.maxSpanningsvalPct.toStringAsFixed(2)}%.',
      );
    }

    // 6. Temperatuur (per kabel: I/n per kabel)
    final tMax = isolProp.maxTempContinu;
    final rPerM = Thermisch.rDcOpTemp(kabel);
    final pPerM = Thermisch.i2rVerlies(iPerKabel, rPerM);
    final double deltaT;
    if (invoer.isGrondkabel) {
      deltaT = Thermisch.tempStijgingGrond(
        pPerM, kabel.buitendiameter,
        diepteM: invoer.diepteM,
        lambdaGrond: invoer.lambdaGrond,
      );
    } else {
      deltaT = Thermisch.tempStijgingLucht(pPerM, kabel.buitendiameter);
    }
    final geleiderTemp = tOmg + deltaT;
    final okTemp = geleiderTemp <= tMax;
    if (!okTemp) {
      waarschuwingen.add(
        'Geleidertemp. ${geleiderTemp.toStringAsFixed(1)} °C > '
        'max ${tMax.toStringAsFixed(0)} °C (vereenvoudigd model).',
      );
    }

    // 7. Kortsluittoets (per kabel: I_k / n)
    double deltaTKs = 0;
    double eindtempKs = 0;
    bool? okKs;
    final effectieveIk = invoer.effectieveKortsluitstroomA;
    if (effectieveIk > 0) {
      final tS = invoer.kortsluitduurMs / 1000.0;
      final ikPerKabel = effectieveIk / n;
      deltaTKs = Kortsluit.tempStijging(
        ikPerKabel, tS, kabel.doorsnedemm2,
        kabel.geleider, kabel.isolatie,
      );
      eindtempKs = tMax + deltaTKs;
      okKs = eindtempKs <= isolProp.maxTempKortsluit;
      if (okKs == false) {
        fouten.add(
          'Kortsluittoets: eindtemp ${eindtempKs.toStringAsFixed(1)} °C > '
          'max ${isolProp.maxTempKortsluit.toStringAsFixed(0)} °C.',
        );
      }
    }

    // 7c. Maximale leidinglengte (NEN 1010 / IEC/TS 61200-53)
    double? maxLengteM;
    double? ikEind;
    bool? okMaxLengte;
    final ia = invoer.beveiligingIa;
    if (ia != null && ia > 0) {
      // Fase-naar-nul spanning (TN-systeem)
      final uc = invoer.systeem == Systeemtype.ac3Fase
          ? invoer.spanningV / math.sqrt(3)
          : invoer.spanningV;
      // Lus-weerstand per meter per NEN 1010 / IEC/TS 61200-53:
      //   R20 uit kabelcatalogus (IEC 60228 waarden), gecorrigeerd naar
      //   gemiddelde fouttemperatuur θgem = (θmax + θks) / 2.
      //   Reactantiecorrectie voor doorsneden ≥ 150 mm² (NEN 1010 bijlage 53.F).
      final gProp = geleiderEigenschappen[invoer.geleider]!;
      final tGem = (tMax + isolProp.maxTempKortsluit) / 2;
      final tempFactor = 1 + gProp.alpha20 * (tGem - 20);
      final s = kabel.doorsnedemm2;
      final reactFactor = s >= 300 ? 1.30
          : s >= 240 ? 1.25
          : s >= 185 ? 1.20
          : s >= 150 ? 1.15
          : 1.00;
      final r20PerM = iec60228R20PerM(invoer.geleider, kabel.doorsnedemm2); // NEN-EN-IEC 60228:2005 Tabel 1
      final rLoopPerM = 2 * r20PerM * tempFactor * reactFactor / n;
      if (rLoopPerM > 0) {
        // Bron-Ik voor formulekeuze §5.1 vs §5.2: alleen uit bronimpedantie.
        // kortsluitstroomA bevat Ia (thermische toets) — niet de bron-kortsluitstroom.
        final ik = invoer.bronimpedantieActief ? invoer.ikBronBerekendA : 0.0;
        if (ik > 0 && ik > ia) {
          // Bekende bronimpedantie (IEC/TS 61200-53 §5.2)
          maxLengteM = uc * (ik - ia) / (ik * ia * rLoopPerM);
          ikEind = uc / (uc / ik + rLoopPerM * invoer.lengteM);
        } else if (ik <= 0) {
          // Bronimpedantie onbekend: Ze = 0 (IEC/TS 61200-53 §5.1)
          maxLengteM = uc / (ia * rLoopPerM);
          ikEind = uc / (rLoopPerM * invoer.lengteM);
        } else {
          // ik > 0 maar ik ≤ ia: beveiliging spreekt zelfs zonder kabel niet aan
          maxLengteM = 0;
          ikEind = uc / (uc / ik + rLoopPerM * invoer.lengteM);
        }
        okMaxLengte = invoer.lengteM <= maxLengteM;
        if (okMaxLengte == false) {
          fouten.add(
            'Leidinglengte ${invoer.lengteM.toStringAsFixed(1)} m > '
            'maximale lengte ${maxLengteM.toStringAsFixed(1)} m '
            '(I_a=${ia.toStringAsFixed(1)} A).',
          );
        }
      }
    }

    // 7d. Bronimpedantie resultaten + NEN 1010 stelsel-waarschuwingen
    double? zbOhmResult;
    double? zbNetOhmResult;
    double? ik3fBronResult;
    double? ik1fBronResult;
    double? zKabelLusResult;
    double? ik1fEindResult;

    if (invoer.bronimpedantieActief) {
      final zb = invoer.zbOhm;
      if (zb > 0) {
        zbOhmResult = zb;
        if (!invoer.skNetOneindig && invoer.skNetMva > 0) {
          zbNetOhmResult = BronImpedantie.zNetOhm(skNetMva: invoer.skNetMva,
              uSecV: invoer.spanningV);
        }
        ik3fBronResult = BronImpedantie.ik3f(zbOhm: zb, uLlV: invoer.spanningV);
        ik1fBronResult = invoer.ikBronBerekendA;

        // Lusimpedantie kabel bij gegeven lengte (zelfde methode als stap 7c)
        final gPropB = geleiderEigenschappen[invoer.geleider]!;
        final tGemB = (tMax + isolProp.maxTempKortsluit) / 2;
        final tempFactorB = 1 + gPropB.alpha20 * (tGemB - 20);
        final sB = kabel.doorsnedemm2;
        final reactFactorB = sB >= 300 ? 1.30
            : sB >= 240 ? 1.25
            : sB >= 185 ? 1.20
            : sB >= 150 ? 1.15
            : 1.00;
        final r20PerMB = iec60228R20PerM(invoer.geleider, kabel.doorsnedemm2);
        final rLoopPerMB = 2 * r20PerMB * tempFactorB * reactFactorB / n;
        final zKabelLus = rLoopPerMB * invoer.lengteM;
        zKabelLusResult = zKabelLus;
        ik1fEindResult = BronImpedantie.ik1fEind(
          zbOhm: zb,
          zKabelLusOhm: zKabelLus,
          uLnV: invoer.uFaseV,
        );
      }

      // NEN 1010 aardingsstelsel-waarschuwingen
      switch (invoer.aardingsstelsel) {
        case Aardingsstelsel.it:
          waarschuwingen.add(
            'IT-stelsel: aardfoutdetectie/-bewaking vereist (NEN 1010 §2.4.7). '
            'De I_k waarden gelden voor de tweede aardingsfout.',
          );
        case Aardingsstelsel.tt:
          waarschuwingen.add(
            'TT-stelsel: foutbescherming via RCD (aardlekschakelaar) vereist '
            '(NEN 1010 §4.1.2.2). I_k-berekening is indicatief.',
          );
        case Aardingsstelsel.tnC:
          waarschuwingen.add(
            'TN-C: PEN-geleider niet toegestaan bij A < 10 mm² Cu of '
            'A < 16 mm² Al (NEN 1010 §5.4.2).',
          );
        default:
          break;
      }
    }

    // 7b. Bundel: warmste (centrum) vs koudste (hoek) positie
    double fBundelRand = fBundel;
    double izRand = iz;
    double margeRand = marge;
    double tWarm = geleiderTemp;
    double tKoud = geleiderTemp;

    if (invoer.bundel != null && invoer.bundel!.totaalKabels > 1) {
      final nH = invoer.bundel!.nHorizontaal;
      final nV = invoer.bundel!.nVerticaal;
      // Hoekpositie: max 1 horizontale buur en 1 verticale buur
      final fHRand = nH <= 1 ? 1.0 : Correctiefactoren.fHorizontaalBundeling(2);
      final fVRand = nV <= 1 ? 1.0 : Correctiefactoren.fVerticalStapeling(2);
      fBundelRand = fHRand * fVRand;
      izRand = iz0 * fT * fLegging * fBundelRand * fGrond * fCyclisch * fHarmonisch;
      margeRand = izRand > 0 ? (izRand / iDesign - 1) * 100 : 0.0;
      // Effectieve omgevingstemperatuur per positie (IEC correctiefactor omgekeerd):
      //   fBundel = √[(T_max−T_eff)/(T_max−T_omg)]  →  T_eff = T_max − (T_max−T_omg)·fBundel²
      final tEffWarm = tMax - (tMax - tOmg) * fBundel * fBundel;
      final tEffKoud  = tMax - (tMax - tOmg) * fBundelRand * fBundelRand;
      tWarm = tEffWarm + deltaT;
      tKoud = tEffKoud + deltaT;
    }

    // 8. Eindoordeel
    final voldoet = fouten.isEmpty;

    return Resultaten(
      kabel: kabel,
      doorsnedeMinKortsluit: doorsnedeMinKs,
      iGevraagd: I,
      tEffectief: tOmg,
      fT: fT, fLegging: fLegging, fBundel: fBundel, fGrond: fGrond,
      fCyclisch: fCyclisch, fHarmonisch: fHarmonisch,
      harmonischOpNul: harmonischOpNul, iNeutraal: iNeutraal,
      fTotaal: fTotaal,
      fHorizontaal: fH, fVerticaal: fV,
      nParallel: n, iPerKabel: iPerKabel,
      iz0: iz0, iz: iz, margeStroomPct: marge,
      bundelPositieWorst: bundelPos,
      fBundelRand: fBundelRand, izRand: izRand, margeStroomPctRand: margeRand,
      geleiderTempCWarm: tWarm, geleiderTempCKoud: tKoud,
      deltaUV: deltaUV, deltaUPct: deltaUPct, okSpanning: okSpanning,
      i2rVerliesWPerM: pPerM, tempStijgingK: deltaT,
      geleiderTempC: geleiderTemp, maxTempC: tMax, okTemp: okTemp,
      deltaTKortsluitK: deltaTKs, eindtempKortsluitC: eindtempKs,
      okKortsluit: okKs,
      maxLengteM: maxLengteM,
      ikEind: ikEind,
      okMaxLengte: okMaxLengte,
      zbOhm: zbOhmResult,
      zbNetOhm: zbNetOhmResult,
      ik3fBronA: ik3fBronResult,
      ik1fBronA: ik1fBronResult,
      zKabelLusOhm: zKabelLusResult,
      ik1fEindA: ik1fEindResult,
      voldoet: voldoet,
      fouten: fouten,
      waarschuwingen: waarschuwingen,
    );
  }
}
