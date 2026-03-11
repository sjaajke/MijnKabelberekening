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

import '../models/enums.dart';

/// Isolatie-eigenschappen per IEC 60502 / 60228.
class IsolatieProp {
  final double maxTempContinu;    // °C
  final double maxTempKortsluit;  // °C
  final double refTempTabel;      // °C

  const IsolatieProp({
    required this.maxTempContinu,
    required this.maxTempKortsluit,
    required this.refTempTabel,
  });
}

const Map<Isolatiemateriaal, IsolatieProp> isolatieEigenschappen = {
  Isolatiemateriaal.pvc:  IsolatieProp(maxTempContinu: 70,  maxTempKortsluit: 160, refTempTabel: 30),
  Isolatiemateriaal.xlpe: IsolatieProp(maxTempContinu: 90,  maxTempKortsluit: 250, refTempTabel: 30),
  Isolatiemateriaal.epr:  IsolatieProp(maxTempContinu: 90,  maxTempKortsluit: 250, refTempTabel: 30),
};

/// k-waarden per IEC 60949 voor adiabatische kortsluitberekening.
/// A_min = I_k · √t / k
const Map<(Geleidermateriaal, Isolatiemateriaal), double> kWaarden = {
  (Geleidermateriaal.koper,     Isolatiemateriaal.pvc):  115,
  (Geleidermateriaal.koper,     Isolatiemateriaal.xlpe): 143,
  (Geleidermateriaal.koper,     Isolatiemateriaal.epr):  143,
  (Geleidermateriaal.aluminium, Isolatiemateriaal.pvc):   76,
  (Geleidermateriaal.aluminium, Isolatiemateriaal.xlpe):  94,
  (Geleidermateriaal.aluminium, Isolatiemateriaal.epr):   94,
};

/// Geleider-eigenschappen: ρ₂₀ in Ω·mm²/m, α₂₀ in 1/K.
class GeleiderProp {
  final double rho20;   // Ω·mm²/m @ 20°C
  final double alpha20; // 1/K

  const GeleiderProp({required this.rho20, required this.alpha20});

  double rhoOpTemp(double t) => rho20 * (1 + alpha20 * (t - 20));

  /// DC-weerstand: R = ρ(T) · L / A  [Ω]
  double rDc(double doorsnedemm2, double lengteM, {double t = 20}) {
    if (doorsnedemm2 <= 0) return double.infinity;
    return rhoOpTemp(t) * lengteM / doorsnedemm2;
  }
}

const Map<Geleidermateriaal, GeleiderProp> geleiderEigenschappen = {
  Geleidermateriaal.koper:     GeleiderProp(rho20: 0.017241, alpha20: 0.00393),
  Geleidermateriaal.aluminium: GeleiderProp(rho20: 0.028264, alpha20: 0.00403),
};

/// NEN-EN-IEC 60228:2005 Tabel 1 — maximale DC-weerstand bij 20 °C [Ω/km].
/// Klasse 2 (gestrande geleiders). Gebruikt voor L_max berekening per NEN 1010.
final _iec60228Cu = <double, double>{
  1.5: 12.10, 2.5: 7.41, 4.0: 4.61,  6.0: 3.08,  10.0: 1.83,
  16.0: 1.15, 25.0: 0.727, 35.0: 0.524, 50.0: 0.387, 70.0: 0.268,
  95.0: 0.193, 120.0: 0.153, 150.0: 0.124, 185.0: 0.0991,
  240.0: 0.0754, 300.0: 0.0601,
};

final _iec60228Al = <double, double>{
  16.0: 1.91,  25.0: 1.20,  35.0: 0.868, 50.0: 0.641, 70.0: 0.443,
  95.0: 0.320, 120.0: 0.253, 150.0: 0.206, 185.0: 0.164,
  240.0: 0.125, 300.0: 0.100,
};

/// R20 per meter per NEN-EN-IEC 60228:2005 Tabel 1 [Ω/m].
/// Valt terug op soortelijke weerstand als doorsnede niet in de tabel staat.
double iec60228R20PerM(Geleidermateriaal geleider, double doorsnedemm2) {
  final tabel = geleider == Geleidermateriaal.koper ? _iec60228Cu : _iec60228Al;
  final rPerKm = tabel[doorsnedemm2];
  if (rPerKm != null) return rPerKm / 1000;
  // Niet-standaard doorsnede: gebruik soortelijke weerstand als benadering.
  return geleiderEigenschappen[geleider]!.rho20 / doorsnedemm2;
}
