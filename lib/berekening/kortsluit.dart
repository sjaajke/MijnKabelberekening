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
