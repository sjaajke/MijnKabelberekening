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

import 'package:flutter/foundation.dart';
import '../models/gebruiker.dart';
import '../models/invoer.dart';
import '../models/resultaten.dart';
import '../berekening/ontwerper.dart';

class BerekeningProvider extends ChangeNotifier {
  Invoer _invoer = Invoer.standaard();
  Resultaten? _resultaten;
  bool _isBoomModus = false;

  Invoer get invoer => _invoer;
  Resultaten? get resultaten => _resultaten;
  bool get heeftResultaten => _resultaten != null;

  /// true wanneer de gebruiker in de boomberekeningsweergave werkt.
  /// InvoerScreen gebruikt dit om de bronimpedantie-sectie aan te passen.
  bool get isBoomModus => _isBoomModus;

  void setIsBoomModus(bool v) {
    if (_isBoomModus == v) return;
    _isBoomModus = v;
    notifyListeners();
  }

  /// Slaat de nieuwe invoer op en voert de berekening altijd opnieuw uit.
  /// Eén notifyListeners() zodat het scherm altijd ververst.
  void berekenMet(Invoer nieuw) {
    _invoer = nieuw;
    _resultaten = KabelOntwerper(_invoer).bereken();
    notifyListeners();
  }

  void updateInvoer(Invoer nieuw) {
    _invoer = nieuw;
    _resultaten = null;
    notifyListeners();
  }

  void reset() {
    _invoer = Invoer.standaard();
    _resultaten = null;
    notifyListeners();
  }

  /// Past de preset van de actieve gebruiker toe als startwaarden.
  void resetMetPreset(GebruikerPreset preset) {
    _invoer = Invoer.standaard().copyWith(
      systeem: preset.systeem,
      spanningV: preset.spanningV,
      geleider: preset.geleider,
      isolatie: preset.isolatie,
      legging: preset.legging,
      omgevingstempC: preset.omgevingstempC,
      maxSpanningsvalPct: preset.maxSpanningsvalPct,
      cosPhi: preset.cosPhi,
    );
    _resultaten = null;
    notifyListeners();
  }
}
