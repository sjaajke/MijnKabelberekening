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
import '../models/kabel_spec.dart';
import '../data/materiaal_data.dart';

/// Vereenvoudigd thermisch model (IEC 60287 benadering).
class Thermisch {
  Thermisch._();

  static double i2rVerlies(double I, double rPerM) => I * I * rPerM;

  /// Temperatuurstijging in lucht via vrije convectie.
  /// h_conv ≈ 10 W/(m²·K), omtrek = π·D
  static double tempStijgingLucht(double pPerM, double buitendiameterMm) {
    final D = buitendiameterMm / 1000.0;
    if (D <= 0) return 0.0;
    return pPerM / (pi * D * 10.0);
  }

  /// Temperatuurstijging in grond (IEC 60287-2-1 vereenvoudigd).
  /// T_aard = (λ/2π)·ln(4u/d)
  static double tempStijgingGrond(
    double pPerM,
    double buitendiameterMm, {
    double diepteM = 0.70,
    double lambdaGrond = 1.0,
  }) {
    final D = buitendiameterMm / 1000.0;
    if (D <= 0 || diepteM <= 0) return 0.0;
    final u = 2 * diepteM;
    final tGrond = (lambdaGrond / (2 * pi)) * log(4 * u / D);
    return pPerM * tGrond;
  }

  /// Berekent R_dc per meter bij bedrijfstemperatuur.
  static double rDcOpTemp(KabelSpec kabel) {
    final tMax = isolatieEigenschappen[kabel.isolatie]!.maxTempContinu;
    return geleiderEigenschappen[kabel.geleider]!
        .rDc(kabel.doorsnedemm2, 1.0, t: tMax);
  }
}
