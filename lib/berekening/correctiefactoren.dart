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
import '../models/enums.dart';

/// Correctiefactoren voor toelaatbare stroom.
/// Alle factoren per IEC 60364-5-52.
///
/// Toelaatbare stroom: I_z = I_z0 · f_T · f_bundel · f_grond
class Correctiefactoren {
  Correctiefactoren._();

  /// Temperatuurcorrectiefactor — IEC 60364-5-52 §523.2
  ///
  /// FORMULE (WORTEL, niet lineair!):
  ///   f_T = √[(θ_max − θ_amb) / (θ_max − θ_ref)]
  ///
  /// Bij PVC (70°C, ref 30°C):
  ///   θ_amb=20°C → 1.118  |  θ_amb=40°C → 0.866  |  θ_amb=50°C → 0.707
  static double fTemperatuur(
    double tOmgeving,
    double tMaxIsolatie, {
    double tReferentie = 30.0,
  }) {
    final teller = tMaxIsolatie - tOmgeving;
    final noemer = tMaxIsolatie - tReferentie;
    if (noemer <= 0 || teller <= 0) return 0.0;
    return sqrt(teller / noemer);
  }

  /// Reductie voor n kabels naast elkaar in één laag.
  /// IEC 60364-5-52 Tabel B.52.20
  static double fHorizontaalBundeling(int nKabels) {
    const tabel = {
      1: 1.00, 2: 0.80, 3: 0.70, 4: 0.65, 5: 0.60,
      6: 0.57, 7: 0.54, 8: 0.52, 9: 0.50,
      12: 0.45, 16: 0.41, 20: 0.38,
    };
    if (nKabels <= 1) return 1.00;
    if (tabel.containsKey(nKabels)) return tabel[nKabels]!;

    // Interpoleer tussen bekende waarden
    final sleutels = tabel.keys.toList()..sort();
    for (int i = 0; i < sleutels.length - 1; i++) {
      final a = sleutels[i];
      final b = sleutels[i + 1];
      if (nKabels > a && nKabels < b) {
        final frac = (nKabels - a) / (b - a);
        return tabel[a]! + frac * (tabel[b]! - tabel[a]!);
      }
    }
    return 0.38; // conservatief voor n ≥ 20
  }

  /// Aanvullende reductiefactor voor gestapelde lagen.
  /// IEC 60364-5-52 Tabel B.52.21
  static double fVerticalStapeling(int nLagen) {
    const tabel = {
      1: 1.00, 2: 0.87, 3: 0.79, 4: 0.72,
      5: 0.66, 6: 0.61, 7: 0.57, 8: 0.53,
      9: 0.50, 10: 0.47,
    };
    if (nLagen <= 1) return 1.00;
    if (tabel.containsKey(nLagen)) return tabel[nLagen]!;
    if (nLagen > 10) return max(0.40, 0.47 * exp(-0.05 * (nLagen - 10)));

    final sleutels = tabel.keys.toList()..sort();
    for (int i = 0; i < sleutels.length - 1; i++) {
      final a = sleutels[i];
      final b = sleutels[i + 1];
      if (nLagen > a && nLagen < b) {
        final frac = (nLagen - a) / (b - a);
        return tabel[a]! + frac * (tabel[b]! - tabel[a]!);
      }
    }
    return 0.47;
  }

  /// Correctiefactor voor leggingswijze t.o.v. referentie Methode C.
  /// IEC 60364-5-52 Tabel B.52.4 (gemiddelde factoren over typische doorsneden).
  ///
  /// Methoden A1/A2/B1/B2: vaste factoren (kabeltemperatuur omgeving bepaalt).
  /// Methoden E/F/G (vrije lucht): 1.25 voor PVC, 1.30 voor XLPE (=verhouding
  /// izE/izC in catalogus, consistent met B.52.4 voor vrije-lucht condities).
  /// Methoden C/D1/D2: 1.00 (catalogus-referentie; D1/D2: fGrond regelt grond).
  static double fLegging(Leggingswijze l, Isolatiemateriaal isolatie) =>
      switch (l) {
        Leggingswijze.a1 => 0.70,
        Leggingswijze.a2 => 0.72,
        Leggingswijze.b1 => 0.82,
        Leggingswijze.b2 => 0.87,
        Leggingswijze.c  => 1.00,
        Leggingswijze.d1 || Leggingswijze.d2 => 1.00,
        // E, F, G: vrije-lucht; factor uit catalogus (izE = izC × 1.25/1.30)
        Leggingswijze.e || Leggingswijze.f || Leggingswijze.g =>
          isolatie == Isolatiemateriaal.pvc ? 1.25 : 1.30,
      };

  /// Correctiefactor hogere harmonischen — NEN 1010 Bijlage 52.E.1 / IEC 60364-5-52 Tabel E.52.1.
  ///
  /// Alleen toepasbaar bij 3-fase AC, 4- of 5-aderige kabels (4 belaste aders: 3L + N).
  ///
  /// Bij dominante 3e harmonische geldt: I_N = 3 × I_h3 = 3 × (h3/100) × I_fase
  ///
  /// | h3 (%)  | Grondslag   | f_harm |
  /// |---------|-------------|--------|
  /// | 0 – 15  | fasestroom  | 1,00   |
  /// | 15 – 33 | fasestroom  | 0,86   |
  /// | 33 – 45 | nulpuntsstroom | 0,86 |
  /// | > 45    | nulpuntsstroom | 1,00 |
  ///
  /// Returns record (fHarm, iDesign, iNeutraal):
  ///   fHarm     — correctiefactor op tabelwaarde (0.86 of 1.0)
  ///   iDesign   — maatgevende stroom voor kabelkeuze (fase of nulpuntsstroom)
  ///   iNeutraal — nulpuntsstroom I_N = 3 × (h3/100) × iFase
  static ({double fHarm, double iDesign, double iNeutraal}) fHarmonischen(
    double iFase,
    double derdeHarmonischePct,
  ) {
    final h3 = derdeHarmonischePct / 100.0;
    final iNeutraal = 3.0 * h3 * iFase;
    if (derdeHarmonischePct <= 15) {
      return (fHarm: 1.00, iDesign: iFase, iNeutraal: iNeutraal);
    } else if (derdeHarmonischePct <= 33) {
      return (fHarm: 0.86, iDesign: iFase, iNeutraal: iNeutraal);
    } else if (derdeHarmonischePct <= 45) {
      return (fHarm: 0.86, iDesign: iNeutraal, iNeutraal: iNeutraal);
    } else {
      return (fHarm: 1.00, iDesign: iNeutraal, iNeutraal: iNeutraal);
    }
  }

  /// Correctie bodemthermische weerstand voor grondkabels.
  /// IEC 60364-5-52 Tabel B.52.16.
  /// λ in K·m/W (typisch 0.5–2.5)
  static double fBodemweerstand(double lambdaGrond) {
    const lambdas = [0.5, 0.7, 1.0, 1.5, 2.0, 2.5];
    const factoren = [1.28, 1.13, 1.00, 0.86, 0.76, 0.68];
    if (lambdaGrond <= 0.5) return 1.28;
    if (lambdaGrond >= 2.5) return 0.68;
    for (int i = 0; i < lambdas.length - 1; i++) {
      if (lambdaGrond >= lambdas[i] && lambdaGrond <= lambdas[i + 1]) {
        final frac = (lambdaGrond - lambdas[i]) / (lambdas[i + 1] - lambdas[i]);
        return factoren[i] + frac * (factoren[i + 1] - factoren[i]);
      }
    }
    return 1.00;
  }
}
