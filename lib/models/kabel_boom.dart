import 'dart:math' show sqrt;
import 'enums.dart';
import 'leiding_node.dart';

/// Een kabelnet-boomstructuur met één gedeelde bronimpedantie.
/// De bronimpedantie-instellingen gelden voor de hele boom; elke [LeidingNode]
/// erft de stroomopwaartse lusimpedantie automatisch van zijn ouderknoop.
class KabelBoom {
  final String id;
  final String naam;

  // ── Bronimpedantie (transformator + primair net) ──────────────────────────
  final bool transformatorHandmatig;
  final double transformatorKva;
  final double transformatorUccPct;
  final Aardingsstelsel aardingsstelsel;
  final bool skNetOneindig;
  final double skNetMva;

  // ── Kabelnodes (platte lijst; parentId-verwijzingen bouwen de boom) ───────
  final List<LeidingNode> nodes;

  const KabelBoom({
    required this.id,
    required this.naam,
    this.transformatorHandmatig = false,
    this.transformatorKva = 250,
    this.transformatorUccPct = 4.0,
    this.aardingsstelsel = Aardingsstelsel.tnS,
    this.skNetOneindig = true,
    this.skNetMva = 100.0,
    this.nodes = const [],
  });

  /// Bronimpedantie [Ω] per fase bij de gegeven spanning [V].
  double zbOhm(double spanningV) {
    final zbTrafo = (transformatorUccPct / 100.0) *
        (spanningV * spanningV) /
        (transformatorKva * 1000.0);
    if (skNetOneindig || skNetMva <= 0) return zbTrafo;
    final zbNet = (spanningV * spanningV) / (skNetMva * 1e6);
    return zbTrafo + zbNet;
  }

  /// Driefasige kortsluitstroom aan de bron [A] (informatief).
  double ik3fBron(double spanningV) {
    final zb = zbOhm(spanningV);
    if (zb <= 0) return 0;
    return spanningV / (sqrt(3) * zb);
  }

  KabelBoom copyWith({
    String? naam,
    bool? transformatorHandmatig,
    double? transformatorKva,
    double? transformatorUccPct,
    Aardingsstelsel? aardingsstelsel,
    bool? skNetOneindig,
    double? skNetMva,
    List<LeidingNode>? nodes,
  }) =>
      KabelBoom(
        id: id,
        naam: naam ?? this.naam,
        transformatorHandmatig:
            transformatorHandmatig ?? this.transformatorHandmatig,
        transformatorKva: transformatorKva ?? this.transformatorKva,
        transformatorUccPct: transformatorUccPct ?? this.transformatorUccPct,
        aardingsstelsel: aardingsstelsel ?? this.aardingsstelsel,
        skNetOneindig: skNetOneindig ?? this.skNetOneindig,
        skNetMva: skNetMva ?? this.skNetMva,
        nodes: nodes ?? this.nodes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'transformatorHandmatig': transformatorHandmatig,
        'transformatorKva': transformatorKva,
        'transformatorUccPct': transformatorUccPct,
        'aardingsstelsel': aardingsstelsel.name,
        'skNetOneindig': skNetOneindig,
        'skNetMva': skNetMva,
        'nodes': nodes.map((n) => n.toJson()).toList(),
      };

  factory KabelBoom.fromJson(Map<String, dynamic> j) => KabelBoom(
        id: j['id'] as String,
        naam: j['naam'] as String,
        transformatorHandmatig:
            j['transformatorHandmatig'] as bool? ?? false,
        transformatorKva:
            (j['transformatorKva'] as num?)?.toDouble() ?? 250.0,
        transformatorUccPct:
            (j['transformatorUccPct'] as num?)?.toDouble() ?? 4.0,
        aardingsstelsel: j['aardingsstelsel'] != null
            ? Aardingsstelsel.values
                .byName(j['aardingsstelsel'] as String)
            : Aardingsstelsel.tnS,
        skNetOneindig: j['skNetOneindig'] as bool? ?? true,
        skNetMva: (j['skNetMva'] as num?)?.toDouble() ?? 100.0,
        nodes: (j['nodes'] as List<dynamic>?)
                ?.map((e) =>
                    LeidingNode.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
