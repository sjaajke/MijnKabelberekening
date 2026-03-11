import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../models/kabel_spec.dart';
import '../data/catalogus.dart';

/// Beheert door de gebruiker toegevoegde kabels.
/// Custom kabels worden opgeslagen in SharedPreferences en bij opstarten
/// samengevoegd met de standaard [kabelCatalogus].
class CustomCatalogusProvider extends ChangeNotifier {
  static const _prefsKey = 'custom_kabels';

  final List<KabelSpec> _custom = [];
  final Set<(Geleidermateriaal, Isolatiemateriaal, double, int)> _customKeys =
      {};
  // Backup van standaard-entries die overschreven zijn
  final Map<(Geleidermateriaal, Isolatiemateriaal, double, int), KabelSpec>
      _backup = {};

  List<KabelSpec> get customKabels => List.unmodifiable(_custom);

  bool isCustom(
          (Geleidermateriaal, Isolatiemateriaal, double, int) key) =>
      _customKeys.contains(key);

  /// Laad opgeslagen custom kabels en voeg ze toe aan [kabelCatalogus].
  Future<void> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return;

    final list = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    for (final j in list) {
      try {
        _voegToeLokaal(KabelSpec.fromJson(j));
      } catch (_) {
        // Sla ongeldige entries over
      }
    }
  }

  void _voegToeLokaal(KabelSpec kabel) {
    final key =
        (kabel.geleider, kabel.isolatie, kabel.doorsnedemm2, kabel.aantalAders);

    // Backup de standaard entry als deze nog niet overschreven is
    if (!_customKeys.contains(key) && kabelCatalogus.containsKey(key)) {
      _backup[key] = kabelCatalogus[key]!;
    }

    // Schrijf in de globale catalogus (overschrijft eventuele standaard entry)
    kabelCatalogus[key] = kabel;

    // Update of voeg toe aan de eigen lijst
    final idx = _custom.indexWhere((k) =>
        k.geleider == kabel.geleider &&
        k.isolatie == kabel.isolatie &&
        k.doorsnedemm2 == kabel.doorsnedemm2 &&
        k.aantalAders == kabel.aantalAders);
    if (idx >= 0) {
      _custom[idx] = kabel;
    } else {
      _custom.add(kabel);
    }
    _customKeys.add(key);
  }

  /// Voeg een nieuwe kabel toe aan de catalogus en sla op.
  void voegToe(KabelSpec kabel) {
    _voegToeLokaal(kabel);
    _sla();
    notifyListeners();
  }

  /// Verwijder een custom kabel en herstel eventuele standaard entry.
  void verwijder(KabelSpec kabel) {
    final key =
        (kabel.geleider, kabel.isolatie, kabel.doorsnedemm2, kabel.aantalAders);

    _custom.removeWhere((k) =>
        k.geleider == kabel.geleider &&
        k.isolatie == kabel.isolatie &&
        k.doorsnedemm2 == kabel.doorsnedemm2 &&
        k.aantalAders == kabel.aantalAders);
    _customKeys.remove(key);

    // Herstel standaard entry of verwijder uit catalogus
    if (_backup.containsKey(key)) {
      kabelCatalogus[key] = _backup.remove(key)!;
    } else {
      kabelCatalogus.remove(key);
    }

    _sla();
    notifyListeners();
  }

  Future<void> _sla() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_custom.map((k) => k.toJson()).toList());
    await prefs.setString(_prefsKey, json);
  }
}
