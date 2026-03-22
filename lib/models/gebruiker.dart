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

/// Standaardwaarden per gebruiker — toegepast bij elke nieuwe berekening.
class GebruikerPreset {
  final Systeemtype systeem;
  final double spanningV;
  final Geleidermateriaal geleider;
  final Isolatiemateriaal isolatie;
  final Leggingswijze legging;
  final double omgevingstempC;
  final double maxSpanningsvalPct;
  final double cosPhi;

  const GebruikerPreset({
    this.systeem = Systeemtype.ac3Fase,
    this.spanningV = 400,
    this.geleider = Geleidermateriaal.koper,
    this.isolatie = Isolatiemateriaal.xlpe,
    this.legging = Leggingswijze.b1,
    this.omgevingstempC = 30,
    this.maxSpanningsvalPct = 3.0,
    this.cosPhi = 0.95,
  });

  GebruikerPreset copyWith({
    Systeemtype? systeem,
    double? spanningV,
    Geleidermateriaal? geleider,
    Isolatiemateriaal? isolatie,
    Leggingswijze? legging,
    double? omgevingstempC,
    double? maxSpanningsvalPct,
    double? cosPhi,
  }) =>
      GebruikerPreset(
        systeem: systeem ?? this.systeem,
        spanningV: spanningV ?? this.spanningV,
        geleider: geleider ?? this.geleider,
        isolatie: isolatie ?? this.isolatie,
        legging: legging ?? this.legging,
        omgevingstempC: omgevingstempC ?? this.omgevingstempC,
        maxSpanningsvalPct: maxSpanningsvalPct ?? this.maxSpanningsvalPct,
        cosPhi: cosPhi ?? this.cosPhi,
      );

  Map<String, dynamic> toJson() => {
        'systeem': systeem.name,
        'spanningV': spanningV,
        'geleider': geleider.name,
        'isolatie': isolatie.name,
        'legging': legging.name,
        'omgevingstempC': omgevingstempC,
        'maxSpanningsvalPct': maxSpanningsvalPct,
        'cosPhi': cosPhi,
      };

  factory GebruikerPreset.fromJson(Map<String, dynamic> j) => GebruikerPreset(
        systeem: Systeemtype.values.byName(j['systeem'] as String? ?? 'ac3Fase'),
        spanningV: (j['spanningV'] as num?)?.toDouble() ?? 400,
        geleider: Geleidermateriaal.values.byName(j['geleider'] as String? ?? 'koper'),
        isolatie: Isolatiemateriaal.values.byName(j['isolatie'] as String? ?? 'xlpe'),
        legging: Leggingswijze.values.byName(j['legging'] as String? ?? 'b1'),
        omgevingstempC: (j['omgevingstempC'] as num?)?.toDouble() ?? 30,
        maxSpanningsvalPct: (j['maxSpanningsvalPct'] as num?)?.toDouble() ?? 3.0,
        cosPhi: (j['cosPhi'] as num?)?.toDouble() ?? 0.95,
      );
}

class Gebruiker {
  final String id;
  final String naam;
  final DateTime aangemaakt;
  final GebruikerPreset preset;

  const Gebruiker({
    required this.id,
    required this.naam,
    required this.aangemaakt,
    this.preset = const GebruikerPreset(),
  });

  Gebruiker copyWith({String? naam, GebruikerPreset? preset}) => Gebruiker(
        id: id,
        naam: naam ?? this.naam,
        aangemaakt: aangemaakt,
        preset: preset ?? this.preset,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'aangemaakt': aangemaakt.toIso8601String(),
        'preset': preset.toJson(),
      };

  factory Gebruiker.fromJson(Map<String, dynamic> j) => Gebruiker(
        id: j['id'] as String,
        naam: j['naam'] as String,
        aangemaakt: DateTime.parse(j['aangemaakt'] as String),
        preset: j['preset'] != null
            ? GebruikerPreset.fromJson(j['preset'] as Map<String, dynamic>)
            : const GebruikerPreset(),
      );
}
