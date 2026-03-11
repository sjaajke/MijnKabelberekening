/// Bundel-configuratie voor meerdere kabels (rechthoekige stapeling).
/// De bundelfactoren worden berekend door de Correctiefactoren-klasse in berekening/.
class BundelConfig {
  final int nHorizontaal;    // kabels naast elkaar
  final int nVerticaal;      // lagen boven elkaar
  final double hartOpHartMm; // mm

  const BundelConfig({
    required this.nHorizontaal,
    required this.nVerticaal,
    required this.hartOpHartMm,
  });

  int get totaalKabels => nHorizontaal * nVerticaal;

  /// Positie van slechtst gekoelde kabel (1-gebaseerd, centrum bundel).
  (int, int) get slechtstePositie =>
      (nHorizontaal ~/ 2 + 1, nVerticaal ~/ 2 + 1);

  Map<String, dynamic> toJson() => {
        'nHorizontaal': nHorizontaal,
        'nVerticaal': nVerticaal,
        'hartOpHartMm': hartOpHartMm,
      };

  factory BundelConfig.fromJson(Map<String, dynamic> j) => BundelConfig(
        nHorizontaal: j['nHorizontaal'] as int,
        nVerticaal: j['nVerticaal'] as int,
        hartOpHartMm: (j['hartOpHartMm'] as num).toDouble(),
      );
}
