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
import '../berekening/ontwerper.dart';
import '../models/invoer.dart';
import '../models/kabel_boom.dart';
import '../models/leiding_node.dart';
import '../models/resultaten.dart';

class BoomProvider extends ChangeNotifier {
  KabelBoom? _boom;
  String? _actiefNodeId;

  // ── Getters ───────────────────────────────────────────────────────────────

  KabelBoom? get boom => _boom;
  bool get heeftBoom => _boom != null;
  String? get actiefNodeId => _actiefNodeId;

  LeidingNode? get actiefNode =>
      _boom?.nodes.where((n) => n.id == _actiefNodeId).firstOrNull;

  List<LeidingNode> rootNodes() =>
      _boom?.nodes.where((n) => n.parentId == null).toList() ?? [];

  List<LeidingNode> childrenVan(String parentId) =>
      _boom?.nodes.where((n) => n.parentId == parentId).toList() ?? [];

  LeidingNode? nodeById(String id) =>
      _boom?.nodes.where((n) => n.id == id).firstOrNull;

  // ── Boom aanmaken / verwijderen ────────────────────────────────────────────

  Future<void> maakNieuweBoom(String naam) async {
    _boom = KabelBoom(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      naam: naam,
    );
    _actiefNodeId = null;
    notifyListeners();
    await _slaOp();
  }

  void setActiefNode(String? id) {
    if (_actiefNodeId == id) return;
    _actiefNodeId = id;
    notifyListeners();
  }

  Future<void> updateBoomConfig(KabelBoom nieuw) async {
    // Ongeldig verklaar alle resultaten — bron is veranderd.
    _boom = nieuw.copyWith(
      nodes: nieuw.nodes
          .map((n) => n.copyWith(clearResultaten: true))
          .toList(),
    );
    notifyListeners();
    await _slaOp();
  }

  Future<void> hernoemBoom(String naam) async {
    if (_boom == null) return;
    _boom = _boom!.copyWith(naam: naam.trim());
    notifyListeners();
    await _slaOp();
  }

  Future<void> verwijderBoom() async {
    _boom = null;
    _actiefNodeId = null;
    notifyListeners();
    await _slaOp();
  }

  // ── Nodes beheren ─────────────────────────────────────────────────────────

  Future<String> voegNodeToe({String? parentId, String naam = 'Leiding'}) async {
    if (_boom == null) throw StateError('Geen boom actief');
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final node = LeidingNode(
      id: id,
      naam: naam.trim(),
      parentId: parentId,
      invoer: Invoer.standaard(),
    );
    _boom = _boom!.copyWith(nodes: [..._boom!.nodes, node]);
    _actiefNodeId = id;
    notifyListeners();
    await _slaOp();
    return id;
  }

  Future<void> hernoemNode(String nodeId, String naam) async {
    final idx = _nodeIdx(nodeId);
    if (idx < 0) return;
    final updated = List<LeidingNode>.from(_boom!.nodes);
    updated[idx] = updated[idx].copyWith(naam: naam.trim());
    _boom = _boom!.copyWith(nodes: updated);
    notifyListeners();
    await _slaOp();
  }

  Future<void> verwijderNode(String nodeId) async {
    final teVerwijderen = {nodeId, ..._alleNakomelingsIds(nodeId)};
    final updated =
        _boom!.nodes.where((n) => !teVerwijderen.contains(n.id)).toList();
    _boom = _boom!.copyWith(nodes: updated);
    if (teVerwijderen.contains(_actiefNodeId)) _actiefNodeId = null;
    notifyListeners();
    await _slaOp();
  }

  // ── Resultaten opslaan & cascade ──────────────────────────────────────────

  /// Sla invoer + resultaten op voor [nodeId].
  /// Nakomelingen worden ongeldig verklaard (hun upstream-Z is veranderd).
  Future<void> opslaanNodeResultaten(
    String nodeId,
    Invoer invoer,
    Resultaten resultaten,
  ) async {
    final idx = _nodeIdx(nodeId);
    if (idx < 0) return;
    final updated = List<LeidingNode>.from(_boom!.nodes);
    // Sla invoer op ZONDER auto-berekende upstream-Z (die wordt herberekend).
    updated[idx] = updated[idx].copyWith(
      invoer: invoer.copyWith(
        clearZUpstream: true,
        bronimpedantieActief: false,
      ),
      resultaten: resultaten,
    );
    // Nakomelingen ongeldig maken.
    for (final dId in _alleNakomelingsIds(nodeId)) {
      final dIdx = updated.indexWhere((n) => n.id == dId);
      if (dIdx >= 0) {
        updated[dIdx] = updated[dIdx].copyWith(clearResultaten: true);
      }
    }
    _boom = _boom!.copyWith(nodes: updated);
    notifyListeners();
    await _slaOp();
  }

  // ── Herbereken volledige boom (cascade, top-down) ─────────────────────────

  Future<void> herberekenAlles() async {
    if (_boom == null) return;
    final updated = List<LeidingNode>.from(_boom!.nodes);

    // Topologische volgorde (BFS vanuit wortels).
    final wachtrij = updated.where((n) => n.parentId == null).toList();
    while (wachtrij.isNotEmpty) {
      final node = wachtrij.removeAt(0);
      final idx = updated.indexWhere((n) => n.id == node.id);

      final zUp = _upstreamMohmFromList(node.id, updated);
      final invoer = updated[idx].invoer.copyWith(
        bronimpedantieActief: true,
        zUpstreamHandmatigMohm: zUp,
        aardingsstelsel: _boom!.aardingsstelsel,
      );
      final resultaten = KabelOntwerper(invoer).bereken();

      updated[idx] = updated[idx].copyWith(
        invoer: updated[idx].invoer, // ongewijzigde gebruikersinvoer
        resultaten: resultaten,
      );

      wachtrij.addAll(updated.where((n) => n.parentId == node.id));
    }

    _boom = _boom!.copyWith(nodes: updated);
    notifyListeners();
    await _slaOp();
  }

  // ── Invoer voor een node (met auto upstream-Z) ────────────────────────────

  /// Geeft de invoer voor [nodeId] aangevuld met de automatisch berekende
  /// stroomopwaartse lusimpedantie en de bron-aardingsstelsel.
  Invoer invoerVoorNode(String nodeId) {
    final node = nodeById(nodeId)!;
    final zUp = _upstreamMohm(nodeId);
    return node.invoer.copyWith(
      bronimpedantieActief: true,
      zUpstreamHandmatigMohm: zUp,
      aardingsstelsel: _boom!.aardingsstelsel,
    );
  }

  // ── Persistentie ─────────────────────────────────────────────────────────

  static const _prefsKey = 'kabel_boom_v1';

  Future<void> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json != null) {
      try {
        _boom = KabelBoom.fromJson(jsonDecode(json) as Map<String, dynamic>);
      } catch (_) {
        _boom = null;
      }
    }
    notifyListeners();
  }

  Future<void> _slaOp() async {
    final prefs = await SharedPreferences.getInstance();
    if (_boom == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, jsonEncode(_boom!.toJson()));
    }
  }

  // ── Privé helpers ─────────────────────────────────────────────────────────

  int _nodeIdx(String nodeId) =>
      _boom?.nodes.indexWhere((n) => n.id == nodeId) ?? -1;

  Set<String> _alleNakomelingsIds(String nodeId) {
    final result = <String>{};
    final wachtrij = [nodeId];
    while (wachtrij.isNotEmpty) {
      final current = wachtrij.removeLast();
      for (final c
          in (_boom?.nodes ?? []).where((n) => n.parentId == current)) {
        result.add(c.id);
        wachtrij.add(c.id);
      }
    }
    return result;
  }

  /// Upstream lus-Z [mΩ] voor [nodeId], op basis van [_boom!.nodes].
  double? _upstreamMohm(String nodeId) =>
      _upstreamMohmFromList(nodeId, _boom!.nodes);

  /// Upstream lus-Z [mΩ] voor [nodeId], op basis van een willekeurige [nodes]-lijst
  /// (voor gebruik tijdens cascade-herberekening).
  double? _upstreamMohmFromList(String nodeId, List<LeidingNode> nodes) {
    final node = nodes.firstWhere((n) => n.id == nodeId,
        orElse: () => throw StateError('Node $nodeId niet gevonden'));
    if (node.parentId == null) {
      // Wortelknoop — gebruik transformatorimpedantie van de bron.
      final spanningV = node.invoer.spanningV;
      final zb = _boom!.zbOhm(spanningV);
      if (zb <= 0) return null;
      return 2.0 * zb * 1000.0; // totale lus [mΩ]
    }
    // Kinderknoop — upstream = Z_totaal_lus van ouder.
    final parent =
        nodes.firstWhere((n) => n.id == node.parentId!,
            orElse: () => throw StateError('Ouder niet gevonden'));
    final ik1f = parent.resultaten?.ik1fEindA;
    if (ik1f == null || ik1f <= 0) return null;
    final uFase = parent.invoer.uFaseV;
    return (uFase / ik1f) * 1000.0; // [mΩ]
  }

  // ── Diepte van een node in de boom ────────────────────────────────────────
  int diepteVan(String nodeId) {
    var depth = 0;
    var current = nodeById(nodeId);
    while (current?.parentId != null) {
      depth++;
      current = nodeById(current!.parentId!);
    }
    return depth;
  }
}
