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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoer.dart';
import '../models/kabel_boom.dart';
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

  Future<void> voegBoomToe(
      String projectId, String naam, KabelBoom boom) async {
    final idx = _projecten.indexWhere((p) => p.id == projectId);
    if (idx < 0) return;
    final now = DateTime.now();
    final opgeslaanBoom = OpgeslaanBoom(
      id: now.microsecondsSinceEpoch.toString(),
      naam: naam.trim(),
      aangemaakt: now,
      boomData: boom.toJson(),
    );
    _projecten[idx] = _projecten[idx].copyWith(
      bomen: [..._projecten[idx].bomen, opgeslaanBoom],
      gewijzigd: now,
    );
    notifyListeners();
    await _slaOp();
  }

  Future<void> verwijderBoom(String projectId, String boomId) async {
    final idx = _projecten.indexWhere((p) => p.id == projectId);
    if (idx < 0) return;
    final nieuw =
        _projecten[idx].bomen.where((b) => b.id != boomId).toList();
    _projecten[idx] = _projecten[idx].copyWith(
      bomen: nieuw,
      gewijzigd: DateTime.now(),
    );
    notifyListeners();
    await _slaOp();
  }
}
