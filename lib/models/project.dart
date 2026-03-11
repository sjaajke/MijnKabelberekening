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

import 'invoer.dart';

/// Een opgeslagen berekening binnen een project (snapshot van invoer).
class OpgeslaanBerekening {
  final String id;
  final String naam;
  final DateTime aangemaakt;
  final Map<String, dynamic> invoerData;

  const OpgeslaanBerekening({
    required this.id,
    required this.naam,
    required this.aangemaakt,
    required this.invoerData,
  });

  Invoer get invoer => Invoer.fromJson(invoerData);

  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'aangemaakt': aangemaakt.toIso8601String(),
        'invoerData': invoerData,
      };

  factory OpgeslaanBerekening.fromJson(Map<String, dynamic> j) =>
      OpgeslaanBerekening(
        id: j['id'] as String,
        naam: j['naam'] as String,
        aangemaakt: DateTime.parse(j['aangemaakt'] as String),
        invoerData: Map<String, dynamic>.from(j['invoerData'] as Map),
      );
}

/// Een project dat meerdere berekeningen groepeert.
class Project {
  final String id;
  final String naam;
  final DateTime aangemaakt;
  final DateTime gewijzigd;
  final List<OpgeslaanBerekening> berekeningen;

  const Project({
    required this.id,
    required this.naam,
    required this.aangemaakt,
    required this.gewijzigd,
    required this.berekeningen,
  });

  Project copyWith({
    String? naam,
    List<OpgeslaanBerekening>? berekeningen,
    DateTime? gewijzigd,
  }) =>
      Project(
        id: id,
        naam: naam ?? this.naam,
        aangemaakt: aangemaakt,
        gewijzigd: gewijzigd ?? this.gewijzigd,
        berekeningen: berekeningen ?? this.berekeningen,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'aangemaakt': aangemaakt.toIso8601String(),
        'gewijzigd': gewijzigd.toIso8601String(),
        'berekeningen': berekeningen.map((b) => b.toJson()).toList(),
      };

  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'] as String,
        naam: j['naam'] as String,
        aangemaakt: DateTime.parse(j['aangemaakt'] as String),
        gewijzigd: DateTime.parse(j['gewijzigd'] as String),
        berekeningen: (j['berekeningen'] as List)
            .map((b) => OpgeslaanBerekening.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}
