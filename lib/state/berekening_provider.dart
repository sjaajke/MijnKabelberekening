import 'package:flutter/foundation.dart';
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
}
