import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoer.dart';
import '../models/project.dart';

class ProjectenProvider extends ChangeNotifier {
  String _gebruikerId = '';

  String get _key => 'projecten_$_gebruikerId';

  List<Project> _projecten = [];
  List<Project> get projecten => List.unmodifiable(_projecten);

  Future<void> laadVoorGebruiker(String gebruikerId) async {
    _gebruikerId = gebruikerId;
    _projecten = [];
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _projecten = list
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  void leegmaak() {
    _gebruikerId = '';
    _projecten = [];
    notifyListeners();
  }

  Future<void> _slaOp() async {
    if (_gebruikerId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_projecten.map((p) => p.toJson()).toList()));
  }

  Future<void> maakProject(String naam) async {
    final now = DateTime.now();
    final project = Project(
      id: now.microsecondsSinceEpoch.toString(),
      naam: naam.trim(),
      aangemaakt: now,
      gewijzigd: now,
      berekeningen: const [],
    );
    _projecten.insert(0, project);
    notifyListeners();
    await _slaOp();
  }

  Future<void> hernoemProject(String projectId, String nieuwNaam) async {
    final idx = _projecten.indexWhere((p) => p.id == projectId);
    if (idx < 0) return;
    _projecten[idx] = _projecten[idx].copyWith(
      naam: nieuwNaam.trim(),
      gewijzigd: DateTime.now(),
    );
    notifyListeners();
    await _slaOp();
  }

  Future<void> verwijderProject(String projectId) async {
    _projecten.removeWhere((p) => p.id == projectId);
    notifyListeners();
    await _slaOp();
  }

  Future<void> voegBerekeningToe(
      String projectId, String naam, Invoer invoer) async {
    final idx = _projecten.indexWhere((p) => p.id == projectId);
    if (idx < 0) return;
    final now = DateTime.now();
    final berekening = OpgeslaanBerekening(
      id: now.microsecondsSinceEpoch.toString(),
      naam: naam.trim(),
      aangemaakt: now,
      invoerData: invoer.toJson(),
    );
    _projecten[idx] = _projecten[idx].copyWith(
      berekeningen: [..._projecten[idx].berekeningen, berekening],
      gewijzigd: now,
    );
    notifyListeners();
    await _slaOp();
  }

  Future<void> verwijderBerekening(
      String projectId, String berekeningId) async {
    final idx = _projecten.indexWhere((p) => p.id == projectId);
    if (idx < 0) return;
    final nieuw = _projecten[idx]
        .berekeningen
        .where((b) => b.id != berekeningId)
        .toList();
    _projecten[idx] = _projecten[idx].copyWith(
      berekeningen: nieuw,
      gewijzigd: DateTime.now(),
    );
    notifyListeners();
    await _slaOp();
  }
}
