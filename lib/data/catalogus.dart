import '../models/enums.dart';
import '../models/kabel_spec.dart';

/// Volledige kabelcatalogus.
/// Stroomwaarden per IEC 60364-5-52 Tabel B.52.4/B.52.5, θ_amb = 30 °C.
/// Methode C: in buis of aanliggend aan wand.  Methode E: vrije lucht.
///
/// 1- en 2-aderige kabels: stroomwaarden voor 2 belaste aders.
/// 3-, 4- en 5-aderige kabels: stroomwaarden voor 3 belaste aders.
/// 1-aderige kabel: ≈5 % hogere Iz dan 2-aderig (geen naburige verwarmingsbron).
///
/// Sleutel: (Geleidermateriaal, Isolatiemateriaal, doorsnede_mm2, aantalAders)
final Map<(Geleidermateriaal, Isolatiemateriaal, double, int), KabelSpec>
    kabelCatalogus = _bouwCatalogus();

List<double> standaardDoorsnedes(Geleidermateriaal g) {
  if (g == Geleidermateriaal.aluminium) {
    return [16, 25, 35, 50, 70, 95, 120, 150, 185, 240, 300, 400];
  }
  return [1.5, 2.5, 4, 6, 10, 16, 25, 35, 50, 70, 95, 120, 150, 185, 240, 300, 400];
}

/// Beschikbare ader-aantallen per systeemtype.
List<int> adersOpties(Systeemtype s) => switch (s) {
      Systeemtype.ac3Fase  => [1, 3, 4, 5],
      Systeemtype.ac1Fase  => [1, 2, 3],
      Systeemtype.dc2Draad => [1, 2],
      Systeemtype.dcAarde  => [1],
    };

/// Standaard aantal aders voor een systeemtype.
int defaultAders(Systeemtype s) => switch (s) {
      Systeemtype.ac3Fase  => 5,
      Systeemtype.ac1Fase  => 3,
      Systeemtype.dc2Draad => 2,
      Systeemtype.dcAarde  => 1,
    };

/// Leesbaar label voor het ader-aantal.
String adersLabel(int n) => switch (n) {
      1 => '1-aderig  (singel)',
      2 => '2-aderig  (L + N)',
      3 => '3-aderig  (L + N + PE  /  3L)',
      4 => '4-aderig  (3L + N)',
      5 => '5-aderig  (3L + N + PE)',
      _ => '$n-aderig',
    };

// ─────────────────────────────────────────────────────────────────────────────
Map<(Geleidermateriaal, Isolatiemateriaal, double, int), KabelSpec>
    _bouwCatalogus() {
  // (doorsnede mm², R_dc Ω/km @ 20°C, X Ω/km, buitendiameter 3-aderig mm)
  final cuData = [
    (1.5,   13.30,  0.090,  8.0),
    (2.5,    7.98,  0.085,  9.5),
    (4.0,    4.95,  0.080, 11.0),
    (6.0,    3.30,  0.079, 12.5),
    (10.0,   1.91,  0.075, 15.0),
    (16.0,   1.21,  0.073, 17.5),
    (25.0,   0.780, 0.071, 21.0),
    (35.0,   0.554, 0.070, 23.5),
    (50.0,   0.387, 0.069, 26.5),
    (70.0,   0.268, 0.067, 30.5),
    (95.0,   0.193, 0.066, 35.0),
    (120.0,  0.153, 0.065, 39.0),
    (150.0,  0.124, 0.065, 43.5),
    (185.0,  0.0991, 0.064, 48.5),
    (240.0,  0.0754, 0.063, 55.0),
    (300.0,  0.0601, 0.063, 61.0),
    (400.0,  0.0470, 0.062, 69.0),
  ];

  // Skin-effectcorrectie op R_dc voor AC (50 Hz)
  final skin = <double, double>{
    1.5: 1.00, 2.5: 1.00, 4.0: 1.00, 6.0: 1.00,
    10.0: 1.00, 16.0: 1.00, 25.0: 1.00, 35.0: 1.00,
    50.0: 1.00, 70.0: 1.01, 95.0: 1.01, 120.0: 1.01,
    150.0: 1.02, 185.0: 1.02, 240.0: 1.03, 300.0: 1.03, 400.0: 1.05,
  };

  // ── Cu PVC — IEC 60364-5-52 Tabel B.52.4, Methode C, 30 °C ──────────────
  // 3 belaste aders (3-fase, of 3+/4+/5-aderige kabels)
  final pvcC3 = <double, double>{
    1.5: 17.5, 2.5: 24.0, 4.0: 32.0, 6.0: 41.0, 10.0: 57.0,
    16.0: 76.0, 25.0: 101.0, 35.0: 125.0, 50.0: 151.0, 70.0: 192.0,
    95.0: 232.0, 120.0: 269.0, 150.0: 309.0, 185.0: 353.0,
    240.0: 415.0, 300.0: 477.0, 400.0: 562.0,
  };
  // 2 belaste aders (1-fase AC of DC, 1-/2-aderige kabels)
  final pvcC2 = <double, double>{
    1.5: 19.5, 2.5: 27.0, 4.0: 36.0, 6.0: 46.0, 10.0: 63.0,
    16.0: 85.0, 25.0: 112.0, 35.0: 138.0, 50.0: 168.0, 70.0: 213.0,
    95.0: 258.0, 120.0: 299.0, 150.0: 344.0, 185.0: 392.0,
    240.0: 461.0, 300.0: 530.0, 400.0: 625.0,
  };

  // ── Cu XLPE — IEC 60364-5-52 Tabel B.52.5, Methode C, 30 °C ─────────────
  final xlpeC3 = <double, double>{
    1.5: 22.0, 2.5: 30.0, 4.0: 40.0, 6.0: 51.0, 10.0: 70.0,
    16.0: 94.0, 25.0: 119.0, 35.0: 147.0, 50.0: 179.0, 70.0: 229.0,
    95.0: 278.0, 120.0: 322.0, 150.0: 371.0, 185.0: 424.0,
    240.0: 500.0, 300.0: 576.0, 400.0: 675.0,
  };
  final xlpeC2 = <double, double>{
    1.5: 24.0, 2.5: 33.0, 4.0: 45.0, 6.0: 58.0, 10.0: 80.0,
    16.0: 107.0, 25.0: 138.0, 35.0: 171.0, 50.0: 209.0, 70.0: 269.0,
    95.0: 328.0, 120.0: 382.0, 150.0: 441.0, 185.0: 506.0,
    240.0: 599.0, 300.0: 693.0, 400.0: 818.0,
  };

  // Buitendiameter schaalfactoren t.o.v. 3-aderig (typisch NYY/N2XH)
  const dFactor = {1: 0.62, 2: 0.82, 3: 1.00, 4: 1.12, 5: 1.20};

  final cat = <(Geleidermateriaal, Isolatiemateriaal, double, int), KabelSpec>{};

  for (final (a, rDc, x, d3) in cuData) {
    final rAc = rDc * (skin[a] ?? 1.0);
    final iz3pvc  = pvcC3[a]  ?? 0.0;
    final iz2pvc  = pvcC2[a]  ?? 0.0;
    final iz3xlpe = xlpeC3[a] ?? 0.0;
    final iz2xlpe = xlpeC2[a] ?? 0.0;

    for (final n in [1, 2, 3, 4, 5]) {
      final df = dFactor[n]!;
      // 1-aderig: 5% extra omdat er geen naburige verwarmingsbron is (geldt voor 1-fase/DC)
      final izPvc  = n == 1 ? iz2pvc  * 1.05 : (n <= 2 ? iz2pvc  : iz3pvc);
      final izXlpe = n == 1 ? iz2xlpe * 1.05 : (n <= 2 ? iz2xlpe : iz3xlpe);
      // izC3/izE3: Iz voor singel in 3-fase circuit (3 belaste aders, IEC 60364-5-52 tabel B.52.4/B.52.5)
      final iz3Pvc  = n == 1 ? iz3pvc  : 0.0;
      final iz3Xlpe = n == 1 ? iz3xlpe : 0.0;

      cat[(Geleidermateriaal.koper, Isolatiemateriaal.pvc, a, n)] = KabelSpec(
        naam: '${_fa(a)} mm² Cu PVC $n×',
        doorsnedemm2: a,
        aantalAders: n,
        geleider: Geleidermateriaal.koper,
        isolatie: Isolatiemateriaal.pvc,
        buitendiameter: d3 * df,
        rAcPerKm20C: rAc,
        xAcPerKm: x,
        izC: izPvc.roundToDouble(),
        izE: (izPvc * 1.25).roundToDouble(),
        izC3: iz3Pvc.roundToDouble(),
        izE3: (iz3Pvc * 1.25).roundToDouble(),
      );
      cat[(Geleidermateriaal.koper, Isolatiemateriaal.xlpe, a, n)] = KabelSpec(
        naam: '${_fa(a)} mm² Cu XLPE $n×',
        doorsnedemm2: a,
        aantalAders: n,
        geleider: Geleidermateriaal.koper,
        isolatie: Isolatiemateriaal.xlpe,
        buitendiameter: d3 * 1.05 * df,
        rAcPerKm20C: rAc,
        xAcPerKm: x,
        izC: izXlpe.roundToDouble(),
        izE: (izXlpe * 1.30).roundToDouble(),
        izC3: iz3Xlpe.roundToDouble(),
        izE3: (iz3Xlpe * 1.30).roundToDouble(),
      );
    }
  }

  // ── Aluminium (IEC 60228, beschikbaar vanaf 16 mm²) ──────────────────────
  final alData = [
    (16.0,  1.91,   0.073, 19.0),
    (25.0,  1.20,   0.071, 22.5),
    (35.0,  0.868,  0.070, 25.0),
    (50.0,  0.641,  0.069, 28.5),
    (70.0,  0.443,  0.067, 32.5),
    (95.0,  0.320,  0.066, 37.5),
    (120.0, 0.253,  0.065, 42.0),
    (150.0, 0.206,  0.065, 46.5),
    (185.0, 0.164,  0.064, 51.5),
    (240.0, 0.125,  0.063, 59.0),
    (300.0, 0.100,  0.063, 65.5),
    (400.0, 0.0778, 0.062, 74.0),
  ];
  // 3 belaste aders
  final alPvcC3 = <double, double>{
    16.0: 59.0, 25.0: 79.0, 35.0: 97.0, 50.0: 118.0,
    70.0: 150.0, 95.0: 182.0, 120.0: 210.0, 150.0: 241.0,
    185.0: 276.0, 240.0: 325.0, 300.0: 373.0, 400.0: 434.0,
  };
  final alXlpeC3 = <double, double>{
    16.0: 75.0, 25.0: 97.0, 35.0: 120.0, 50.0: 145.0,
    70.0: 185.0, 95.0: 225.0, 120.0: 261.0, 150.0: 300.0,
    185.0: 344.0, 240.0: 405.0, 300.0: 466.0, 400.0: 546.0,
  };
  // 2 belaste aders (Al ≈ Cu × 0.78 voor PVC, ≈ Cu × 0.80 voor XLPE)
  final alPvcC2 = <double, double>{
    16.0:  66.0, 25.0:  87.0, 35.0: 107.0, 50.0: 131.0,
    70.0: 166.0, 95.0: 201.0, 120.0: 233.0, 150.0: 268.0,
    185.0: 305.0, 240.0: 359.0, 300.0: 413.0, 400.0: 487.0,
  };
  final alXlpeC2 = <double, double>{
    16.0:  86.0, 25.0: 110.0, 35.0: 137.0, 50.0: 167.0,
    70.0: 215.0, 95.0: 262.0, 120.0: 306.0, 150.0: 353.0,
    185.0: 405.0, 240.0: 479.0, 300.0: 554.0, 400.0: 654.0,
  };

  for (final (a, rDc, x, d3) in alData) {
    for (final n in [1, 2, 3, 4, 5]) {
      final df = dFactor[n]!;
      final izPvc  = n == 1 ? (alPvcC2[a]  ?? 0.0) * 1.05 : (n <= 2 ? alPvcC2[a]  ?? 0.0 : alPvcC3[a]  ?? 0.0);
      final izXlpe = n == 1 ? (alXlpeC2[a] ?? 0.0) * 1.05 : (n <= 2 ? alXlpeC2[a] ?? 0.0 : alXlpeC3[a] ?? 0.0);
      final iz3Pvc  = n == 1 ? alPvcC3[a]  ?? 0.0 : 0.0;
      final iz3Xlpe = n == 1 ? alXlpeC3[a] ?? 0.0 : 0.0;

      cat[(Geleidermateriaal.aluminium, Isolatiemateriaal.pvc, a, n)] = KabelSpec(
        naam: '${_fa(a)} mm² Al PVC $n×',
        doorsnedemm2: a,
        aantalAders: n,
        geleider: Geleidermateriaal.aluminium,
        isolatie: Isolatiemateriaal.pvc,
        buitendiameter: d3 * df,
        rAcPerKm20C: rDc,
        xAcPerKm: x,
        izC: izPvc.roundToDouble(),
        izE: (izPvc * 1.25).roundToDouble(),
        izC3: iz3Pvc.roundToDouble(),
        izE3: (iz3Pvc * 1.25).roundToDouble(),
      );
      cat[(Geleidermateriaal.aluminium, Isolatiemateriaal.xlpe, a, n)] = KabelSpec(
        naam: '${_fa(a)} mm² Al XLPE $n×',
        doorsnedemm2: a,
        aantalAders: n,
        geleider: Geleidermateriaal.aluminium,
        isolatie: Isolatiemateriaal.xlpe,
        buitendiameter: d3 * 1.05 * df,
        rAcPerKm20C: rDc,
        xAcPerKm: x,
        izC: izXlpe.roundToDouble(),
        izE: (izXlpe * 1.30).roundToDouble(),
        izC3: iz3Xlpe.roundToDouble(),
        izE3: (iz3Xlpe * 1.30).roundToDouble(),
      );
    }
  }
  return cat;
}

/// Doorsnede-formatter: "1.5" of "25" (geen onnodige decimaal).
String _fa(double a) => a % 1 == 0 ? '${a.toInt()}' : '$a';
