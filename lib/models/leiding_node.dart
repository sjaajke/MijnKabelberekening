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
import 'resultaten.dart';

/// Eén kabel in de kabelnet-boomstructuur.
/// Slaat de door de gebruiker ingestelde [invoer] op (zonder upstream-Z —
/// die wordt altijd dynamisch berekend vanuit de ouderknoop).
/// [resultaten] zijn geldig na de laatste berekening; null = nog niet berekend.
class LeidingNode {
  final String id;
  final String naam;

  /// null = directe verbinding met de transformatorbron.
  final String? parentId;

  /// Gebruikersinstellingen van deze kabel.
  /// Let op: [Invoer.zUpstreamHandmatigMohm] en [Invoer.bronimpedantieActief]
  /// worden NIET hier opgeslagen — ze worden per berekening via [BoomProvider]
  /// aangevuld (zie [BoomProvider.invoerVoorNode]).
  final Invoer invoer;

  /// Meest recente berekeningsresultaten, of null.
  final Resultaten? resultaten;

  const LeidingNode({
    required this.id,
    required this.naam,
    this.parentId,
    required this.invoer,
    this.resultaten,
  });

  LeidingNode copyWith({
    String? naam,
    String? parentId,
    bool clearParent = false,
    Invoer? invoer,
    Resultaten? resultaten,
    bool clearResultaten = false,
  }) =>
      LeidingNode(
        id: id,
        naam: naam ?? this.naam,
        parentId: clearParent ? null : (parentId ?? this.parentId),
        invoer: invoer ?? this.invoer,
        resultaten: clearResultaten ? null : (resultaten ?? this.resultaten),
      );

  /// Serialisatie: resultaten worden NIET opgeslagen (herberekend bij laden).
  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'parentId': parentId,
        'invoer': invoer.toJson(),
      };

  factory LeidingNode.fromJson(Map<String, dynamic> j) => LeidingNode(
        id: j['id'] as String,
        naam: j['naam'] as String,
        parentId: j['parentId'] as String?,
        invoer: Invoer.fromJson(j['invoer'] as Map<String, dynamic>),
      );
}
