import 'dart:math';
import '../models/enums.dart';
import '../models/invoer.dart';
import '../models/kabel_spec.dart';
import '../data/materiaal_data.dart';

/// Spanningsvalberekeningen voor AC en DC.
///
/// 1-fase AC:  ΔU = 2·I·L·(R·cosφ + X·sinφ)   [factor 2 voor retour!]
/// 3-fase AC:  ΔU = √3·I·L·(R·cosφ + X·sinφ)
/// DC 2-draad: ΔU = 2·I·R_DC·L
/// DC aardret: ΔU = I·R_DC·L
class Spanningsval {
  Spanningsval._();

  /// Corrigeert AC-weerstand van 20°C naar bedrijfstemperatuur.
  static double _rOpTemp(double rPerKm20C, Geleidermateriaal gel, double t) {
    final prop = geleiderEigenschappen[gel]!;
    return rPerKm20C * (1 + prop.alpha20 * (t - 20)) / 1000.0; // → Ω/m
  }

  /// Berekent (ΔU_volt, ΔU_procent) voor het gegeven systeem.
  /// [iOverride] vervangt invoer.effectieveStroom (gebruik voor parallel kabels: I/n).
  static (double, double) bereken(Invoer invoer, KabelSpec kabel,
      {double? iOverride}) {
    final I = iOverride ?? invoer.effectieveStroom;
    final L = invoer.lengteM;
    final tMax = isolatieEigenschappen[kabel.isolatie]!.maxTempContinu;

    var deltaU = 0.0;

    switch (invoer.systeem) {
      case Systeemtype.ac1Fase:
        final R = _rOpTemp(kabel.rAcPerKm20C, kabel.geleider, tMax);
        final X = kabel.xAcPerKm / 1000.0;
        final sinPhi = sqrt(max(0.0, 1 - invoer.cosPhi * invoer.cosPhi));
        deltaU = 2.0 * I * L * (R * invoer.cosPhi + X * sinPhi);

      case Systeemtype.ac3Fase:
        final R = _rOpTemp(kabel.rAcPerKm20C, kabel.geleider, tMax);
        final X = kabel.xAcPerKm / 1000.0;
        final sinPhi = sqrt(max(0.0, 1 - invoer.cosPhi * invoer.cosPhi));
        deltaU = sqrt(3) * I * L * (R * invoer.cosPhi + X * sinPhi);

      case Systeemtype.dc2Draad:
        final prop = geleiderEigenschappen[kabel.geleider]!;
        final rDcM = prop.rDc(kabel.doorsnedemm2, 1.0, t: tMax);
        deltaU = 2.0 * I * rDcM * L;

      case Systeemtype.dcAarde:
        final prop = geleiderEigenschappen[kabel.geleider]!;
        final rDcM = prop.rDc(kabel.doorsnedemm2, 1.0, t: tMax);
        deltaU = I * rDcM * L;
    }

    final pct = invoer.spanningV > 0 ? 100.0 * deltaU / invoer.spanningV : 0.0;
    return (deltaU, pct);
  }
}
