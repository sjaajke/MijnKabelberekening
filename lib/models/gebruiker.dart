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

class Gebruiker {
  final String id;
  final String naam;
  final DateTime aangemaakt;

  const Gebruiker({
    required this.id,
    required this.naam,
    required this.aangemaakt,
  });

  Gebruiker copyWith({String? naam}) => Gebruiker(
        id: id,
        naam: naam ?? this.naam,
        aangemaakt: aangemaakt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'aangemaakt': aangemaakt.toIso8601String(),
      };

  factory Gebruiker.fromJson(Map<String, dynamic> j) => Gebruiker(
        id: j['id'] as String,
        naam: j['naam'] as String,
        aangemaakt: DateTime.parse(j['aangemaakt'] as String),
      );
}
