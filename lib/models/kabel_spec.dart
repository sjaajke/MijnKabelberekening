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

import 'enums.dart';

/// Kabelspecificatie uit catalogus.
/// Methode C/E stroomwaarden: θ_ref = 30°C (in lucht).
/// Methode D1/D2 stroomwaarden: θ_ref = 20°C (in grond) — NEN 1010 tabel 52.B.2–52.B.5.
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
  final double izC;           // A — methode C, θ_ref=30°C
  final double izE;           // A — methode E (vrije lucht), θ_ref=30°C
  /// Iz voor 1-aderig singel in 3-fase circuit (3 belaste aders).
  /// Alleen zinvol voor aantalAders == 1; 0 voor overige adertallen.
  final double izC3;          // A — methode C, 3 belaste aders, θ_ref=30°C
  final double izE3;          // A — methode E, 3 belaste aders, θ_ref=30°C

  // Grondlegging — NEN 1010 tabel 52.B.2/52.B.3 (2 aders) en 52.B.4/52.B.5 (3 aders)
  // θ_ref = 20°C, λ_grond = 1,0 K·m/W (referentie bodemweerstand)
  final double izD1;          // A — methode D1 (in buis ingegraven)
  final double izD2;          // A — methode D2 (direct ingegraven)
  /// Singel in 3-fase circuit voor D1/D2 (3 belaste aders).
  final double izD13;         // A — methode D1, singel in 3-fase, θ_ref=20°C
  final double izD23;         // A — methode D2, singel in 3-fase, θ_ref=20°C

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
    this.izD1 = 0,
    this.izD2 = 0,
    this.izD13 = 0,
    this.izD23 = 0,
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
        izD1:  (j['izD1']  as num?)?.toDouble() ?? 0,
        izD2:  (j['izD2']  as num?)?.toDouble() ?? 0,
        izD13: (j['izD13'] as num?)?.toDouble() ?? 0,
        izD23: (j['izD23'] as num?)?.toDouble() ?? 0,
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
        'izD1': izD1,
        'izD2': izD2,
        'izD13': izD13,
        'izD23': izD23,
      };
}
