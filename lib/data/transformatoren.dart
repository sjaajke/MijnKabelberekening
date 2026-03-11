import 'dart:math' as math;

/// Specificatie van een distributietransformator (10 kV / 0,4 kV).
/// Conform IEC 60076-5 en Nederlandse distributienetwerk-standaard.
class TransformatorSpec {
  final double vermogenKva;
  final double uccPct;

  const TransformatorSpec(this.vermogenKva, this.uccPct);

  /// Weergavenaam voor dropdown.
  String get naam =>
      '${vermogenKva.toInt()} kVA  —  Ucc = ${uccPct.toStringAsFixed(0)}%';

  /// Kortsluitimpedantie per fase, verwezen naar secundaire zijde (0,4 kV) [Ω].
  ///
  ///   Z_b = (u_cc / 100) × (U²_sec / S_n)
  ///
  /// Primaire impedantie wordt verwaarloosd (stijf netwerk / ∞ Sk).
  double zbOhm({double uSecV = 400.0}) =>
      (uccPct / 100.0) * (uSecV * uSecV) / (vermogenKva * 1000.0);
}

/// Standaard Nederlandse distributienet-transformatoren 10 kV / 0,4 kV.
///
/// Kortsluitspanningen (u_cc) conform IEC 60076-5 en Nederlandse netbeheerders:
///   - ≤ 400 kVA : u_cc = 4 %
///   - ≥ 630 kVA : u_cc = 6 %
const transformatorDatabase = [
  TransformatorSpec(50,   4.0),
  TransformatorSpec(100,  4.0),
  TransformatorSpec(160,  4.0),
  TransformatorSpec(250,  4.0),
  TransformatorSpec(400,  4.0),
  TransformatorSpec(630,  6.0),
  TransformatorSpec(800,  6.0),
  TransformatorSpec(1000, 6.0),
  TransformatorSpec(1250, 6.0),
  TransformatorSpec(1600, 6.0),
  TransformatorSpec(2000, 6.0),
];

/// Hulpfuncties voor bronimpedantieberekening.
class BronImpedantie {
  /// Driefasige kortsluitstroom aan bron [A].
  ///   I_k3f = U_LL / (√3 × Z_b)
  static double ik3f({required double zbOhm, required double uLlV}) =>
      uLlV / (math.sqrt(3) * zbOhm);

  /// Enkelfasige lus-kortsluitstroom aan bron [A] voor TN-stelsel.
  ///   I_k1f = U_LN / (2 × Z_b)   (fase + N/PE beide door transformator)
  static double ik1fBron({required double zbOhm, required double uLnV}) =>
      uLnV / (2.0 * zbOhm);

  /// Enkelfasige lus-kortsluitstroom aan kabeluiteinde [A].
  ///   I_k1f_eind = U_LN / (2×Z_b + Z_kabel_lus)
  static double ik1fEind({
    required double zbOhm,
    required double zKabelLusOhm,
    required double uLnV,
  }) =>
      uLnV / (2.0 * zbOhm + zKabelLusOhm);

  /// Kortsluitvermogen aan transformatorklemmen [MVA].
  ///   S_k = U_LL² / Z_b
  static double skMva({required double zbOhm, double uLlV = 400.0}) =>
      (uLlV * uLlV) / (zbOhm * 1e6);

  /// Netwerkimpedantie verwezen naar secundaire zijde [Ω] (bij eindig Sk_net).
  ///   Z_net = U_sec² / S_k_net
  static double zNetOhm({required double skNetMva, double uSecV = 400.0}) =>
      (uSecV * uSecV) / (skNetMva * 1e6);
}
