import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gebruiker.dart';
import 'projecten_provider.dart';

class GebruikersProvider extends ChangeNotifier {
  static const _keyGebruikers = 'gebruikers';
  static const _keyActief = 'actieve_gebruiker';

  final ProjectenProvider _projectenProvider;

  GebruikersProvider(this._projectenProvider);

  List<Gebruiker> _gebruikers = [];
  String? _actieveGebruikerId;

  List<Gebruiker> get gebruikers => List.unmodifiable(_gebruikers);
  String? get actieveGebruikerId => _actieveGebruikerId;
  Gebruiker? get actieveGebruiker => _actieveGebruikerId == null
      ? null
      : _gebruikers.where((g) => g.id == _actieveGebruikerId).firstOrNull;

  Future<void> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyGebruikers);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _gebruikers =
          list.map((e) => Gebruiker.fromJson(e as Map<String, dynamic>)).toList();
    }
    _actieveGebruikerId = prefs.getString(_keyActief);
    if (_actieveGebruikerId != null) {
      final bestaat = _gebruikers.any((g) => g.id == _actieveGebruikerId);
      if (!bestaat) {
        _actieveGebruikerId = null;
      } else {
        await _projectenProvider.laadVoorGebruiker(_actieveGebruikerId!);
      }
    }
    notifyListeners();
  }

  Future<void> _slaOp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyGebruikers, jsonEncode(_gebruikers.map((g) => g.toJson()).toList()));
    if (_actieveGebruikerId != null) {
      await prefs.setString(_keyActief, _actieveGebruikerId!);
    } else {
      await prefs.remove(_keyActief);
    }
  }

  Future<void> maakGebruiker(String naam) async {
    final now = DateTime.now();
    final gebruiker = Gebruiker(
      id: now.microsecondsSinceEpoch.toString(),
      naam: naam.trim(),
      aangemaakt: now,
    );
    _gebruikers.add(gebruiker);
    await _slaOp();
    await selecteerGebruiker(gebruiker.id);
  }

  Future<void> selecteerGebruiker(String id) async {
    _actieveGebruikerId = id;
    await _slaOp();
    await _projectenProvider.laadVoorGebruiker(id);
    notifyListeners();
  }

  Future<void> wisselGebruiker() async {
    _actieveGebruikerId = null;
    await _slaOp();
    _projectenProvider.leegmaak();
    notifyListeners();
  }

  Future<void> hernoemGebruiker(String id, String naam) async {
    final idx = _gebruikers.indexWhere((g) => g.id == id);
    if (idx < 0) return;
    _gebruikers[idx] = _gebruikers[idx].copyWith(naam: naam.trim());
    await _slaOp();
    notifyListeners();
  }

  Future<void> verwijderGebruiker(String id) async {
    _gebruikers.removeWhere((g) => g.id == id);
    if (_actieveGebruikerId == id) {
      _actieveGebruikerId = null;
      _projectenProvider.leegmaak();
    }
    await _slaOp();
    notifyListeners();
  }
}
