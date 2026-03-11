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

/// Bundel-configuratie voor meerdere kabels (rechthoekige stapeling).
/// De bundelfactoren worden berekend door de Correctiefactoren-klasse in berekening/.
class BundelConfig {
  final int nHorizontaal;    // kabels naast elkaar
  final int nVerticaal;      // lagen boven elkaar
  final double hartOpHartMm; // mm

  const BundelConfig({
    required this.nHorizontaal,
    required this.nVerticaal,
    required this.hartOpHartMm,
  });

  int get totaalKabels => nHorizontaal * nVerticaal;

  /// Positie van slechtst gekoelde kabel (1-gebaseerd, centrum bundel).
  (int, int) get slechtstePositie =>
      (nHorizontaal ~/ 2 + 1, nVerticaal ~/ 2 + 1);

  Map<String, dynamic> toJson() => {
        'nHorizontaal': nHorizontaal,
        'nVerticaal': nVerticaal,
        'hartOpHartMm': hartOpHartMm,
      };

  factory BundelConfig.fromJson(Map<String, dynamic> j) => BundelConfig(
        nHorizontaal: j['nHorizontaal'] as int,
        nVerticaal: j['nVerticaal'] as int,
        hartOpHartMm: (j['hartOpHartMm'] as num).toDouble(),
      );
}
