import 'enums.dart';

/// Kabelspecificatie uit catalogus.
/// Stroomwaarden gelden voor θ_amb = 30°C.
/// Belaste aders: 1–2 aderige kabels → 2 belaste aders; ≥3 aderige → 3 belaste aders.
class KabelSpec {
  final String naam;
  final double doorsnedemm2;
  final int aantalAders;       // fysiek aantal aders: 1, 2, 3, 4 of 5
  final Geleidermateriaal geleider;
  final Isolatiemateriaal isolatie;
  final double buitendiameter; // mm
  final double rAcPerKm20C;   // Ω/km per fase @ 20°C (AC, incl. skin)
  final double xAcPerKm;      // Ω/km per fase @ 50 Hz
  final double izC;           // A — methode C, 30°C
  final double izE;           // A — methode E (vrije lucht), 30°C
  /// Iz voor 1-aderig singel in 3-fase circuit (3 belaste aders).
  /// Alleen zinvol voor aantalAders == 1; 0 voor overige adertallen.
  final double izC3;          // A — methode C, 3 belaste aders, 30°C
  final double izE3;          // A — methode E, 3 belaste aders, 30°C

  const KabelSpec({
    required this.naam,
    required this.doorsnedemm2,
    required this.aantalAders,
    required this.geleider,
    required this.isolatie,
    required this.buitendiameter,
    required this.rAcPerKm20C,
    required this.xAcPerKm,
    required this.izC,
    required this.izE,
    this.izC3 = 0,
    this.izE3 = 0,
  });

  factory KabelSpec.fromJson(Map<String, dynamic> j) => KabelSpec(
        naam: j['naam'] as String,
        doorsnedemm2: (j['doorsnedemm2'] as num).toDouble(),
        aantalAders: j['aantalAders'] as int,
        geleider: Geleidermateriaal.values
            .firstWhere((g) => g.name == j['geleider']),
        isolatie: Isolatiemateriaal.values
            .firstWhere((i) => i.name == j['isolatie']),
        buitendiameter: (j['buitendiameter'] as num).toDouble(),
        rAcPerKm20C: (j['rAcPerKm20C'] as num).toDouble(),
        xAcPerKm: (j['xAcPerKm'] as num).toDouble(),
        izC: (j['izC'] as num).toDouble(),
        izE: (j['izE'] as num).toDouble(),
        izC3: (j['izC3'] as num?)?.toDouble() ?? 0,
        izE3: (j['izE3'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'naam': naam,
        'doorsnedemm2': doorsnedemm2,
        'aantalAders': aantalAders,
        'geleider': geleider.name,
        'isolatie': isolatie.name,
        'buitendiameter': buitendiameter,
        'rAcPerKm20C': rAcPerKm20C,
        'xAcPerKm': xAcPerKm,
        'izC': izC,
        'izE': izE,
        'izC3': izC3,
        'izE3': izE3,
      };
}
