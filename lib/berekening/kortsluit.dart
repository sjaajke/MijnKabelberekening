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
import '../data/materiaal_data.dart';

/// Thermische kortsluittoets per IEC 60949.
///
/// A_min = I_k · √t / k     [mm²]
/// ΔT    = (I_k² · t) / (k² · A²)
class Kortsluit {
  Kortsluit._();

  static double kWaarde(Geleidermateriaal g, Isolatiemateriaal i) =>
      kWaarden[(g, i)] ?? 115;

  /// Minimale doorsnede vanuit kortsluitstroom.
  static double minDoorsnede(
    double iK,
    double tS,
    Geleidermateriaal g,
    Isolatiemateriaal i,
  ) {
    final k = kWaarde(g, i);
    return k > 0 ? iK * sqrt(tS) / k : double.infinity;
  }

  /// Adiabatische temperatuurstijging.
  static double tempStijging(
    double iK,
    double tS,
    double doorsnedemm2,
    Geleidermateriaal g,
    Isolatiemateriaal i,
  ) {
    final k = kWaarde(g, i);
    if (doorsnedemm2 <= 0 || k <= 0) return double.infinity;
    return (iK * iK * tS) / (k * k * doorsnedemm2 * doorsnedemm2);
  }
}
