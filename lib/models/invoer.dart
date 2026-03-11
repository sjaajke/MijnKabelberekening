import 'dart:math';
import 'enums.dart';
import 'bundel_config.dart';

/// Volledige invoer voor de kabelberekening.
class Invoer {
  final Systeemtype systeem;
  final double spanningV;
  final double stroomA;           // 0 als vermogen opgegeven
  final double? vermogenW;        // null als stroom opgegeven
  final double cosPhi;
  final double frequentieHz;
  final double lengteM;
  final Leggingswijze legging;
  final Geleidermateriaal geleider;
  final Isolatiemateriaal isolatie;
  final double omgevingstempC;
  final double grondtempC;
  final double lambdaGrond;       // K·m/W bodemthermische weerstand
  final BundelConfig? bundel;     // null = enkele kabel
  final double maxSpanningsvalPct;
  final double kortsluitstroomA;  // 0 = geen toets
  final double kortsluitduurMs;
  // ── Maximale leidinglengte (kortsluitbeveiliging) ──────────────────────────
  // null = toets niet uitvoeren
  final BeveiligingType? beveiligingType;
  final double? beveiligingWaarde; // In (A) bij MCB, Ia (A) bij handmatig
  final double zonlichtToeslagK;  // extra ΔT door directe zonstraling (0 = geen)
  /// 3e harmonische als % van fasestroom (0 = geen correctie).
  /// NEN 1010 Bijlage 52.E.1 — alleen voor ac3Fase met 4 of 5 aders.
  final double derdeHarmonischePct;
  final double? forceerDoorsnedemm2; // null = automatisch kiezen
  final int nParallel;            // kabels parallel per fase (≥1, alleen AC)
  final int aantalAders;          // fysiek aantal aders: 1–5
  /// Aantal geleiders per kring bij 1-aderige AC-kabels (singels).
  /// 2 = L + N,  3 = L + N + PE.  Alleen relevant voor ac1Fase + aantalAders==1.
  final int geleidersPerKring;

  // ── Grondkabel-specifieke velden ──────────────────────────────────────────
  final double diepteM;           // legdiepte (m); gebruikt in thermisch én cyclisch

  // ── Cyclische belastingsfactor (NEN IEC 60583-1) ──────────────────────────
  // null = cyclische berekening uitgeschakeld (M = 1.0)
  final List<double>? cyclischProfiel; // 24 waarden I/Imax per uur (0..1)
  final int cyclischNKringen;          // aantal kringen in de groep (N)
  final bool cyclischAanliggend;       // true = aanliggend (touching), false = gespreid
  final double cyclischHartOpHartMm;  // hart-op-hart afstand tussen kringen (mm)

  // ── Bronimpedantie (transformator & stelsel) ───────────────────────────────
  /// Bronimpedantie-sectie ingeschakeld.
  final bool bronimpedantieActief;
  /// false = kies uit standaard transformatordatabank; true = handmatig invoeren.
  final bool transformatorHandmatig;
  /// Transformatorvermogen [kVA] — uit databank of handmatig.
  final double transformatorKva;
  /// Kortsluitspanning [%] — uit databank of handmatig.
  final double transformatorUccPct;
  /// Aardingsstelsel (TN-S, TN-C, TN-C-S, TT, IT) voor NEN 1010-checks.
  final Aardingsstelsel aardingsstelsel;
  /// true = primair netwerk heeft oneindig kortsluitvermogen (Z_net = 0).
  final bool skNetOneindig;
  /// Kortsluitvermogen distributienet [MVA] — alleen als !skNetOneindig.
  final double skNetMva;
  /// Handmatig ingevoerde totale stroomopwaartse lusimpedantie [mΩ].
  /// null = gebruik transformatordatabank/handmatige transformatorinvoer.
  /// Vul hier Z_totaal_lus in van de bovenliggende kabel om te ketenen.
  final double? zUpstreamHandmatigMohm;

  const Invoer({
    required this.systeem,
    required this.spanningV,
    this.stroomA = 0,
    this.vermogenW,
    this.cosPhi = 1.0,
    this.frequentieHz = 50,
    required this.lengteM,
    this.legging = Leggingswijze.c,
    this.geleider = Geleidermateriaal.koper,
    this.isolatie = Isolatiemateriaal.pvc,
    this.omgevingstempC = 30,
    this.grondtempC = 20,
    this.lambdaGrond = 1.0,
    this.bundel,
    this.maxSpanningsvalPct = 3.0,
    this.kortsluitstroomA = 0,
    this.kortsluitduurMs = 500,
    this.beveiligingType,
    this.beveiligingWaarde,
    this.zonlichtToeslagK = 0,
    this.derdeHarmonischePct = 0,
    this.forceerDoorsnedemm2,
    this.nParallel = 1,
    this.aantalAders = 5,
    this.geleidersPerKring = 2,
    this.diepteM = 0.70,
    this.cyclischProfiel,
    this.cyclischNKringen = 1,
    this.cyclischAanliggend = true,
    this.cyclischHartOpHartMm = 0,
    this.bronimpedantieActief = false,
    this.transformatorHandmatig = false,
    this.transformatorKva = 250,
    this.transformatorUccPct = 4.0,
    this.aardingsstelsel = Aardingsstelsel.tnS,
    this.skNetOneindig = true,
    this.skNetMva = 100.0,
    this.zUpstreamHandmatigMohm,
  });

  /// Standaard-invoer voor nieuwe berekening.
  factory Invoer.standaard() => const Invoer(
        systeem: Systeemtype.ac3Fase,
        spanningV: 400,
        stroomA: 32,
        cosPhi: 0.95,
        lengteM: 25,
      );

  double get effectieveStroom {
    if (vermogenW != null && vermogenW! > 0) {
      if (systeem == Systeemtype.ac3Fase) {
        return vermogenW! / (sqrt(3) * spanningV * cosPhi);
      }
      return vermogenW! / (spanningV * cosPhi);
    }
    return stroomA;
  }

  bool get isGrondkabel =>
      legging == Leggingswijze.d1 || legging == Leggingswijze.d2;

  // ── Bronimpedantie computed getters ────────────────────────────────────────

  /// Fasespanning [V]: U_LL/√3 voor 3-fase, U_LL voor 1-fase.
  double get uFaseV =>
      systeem == Systeemtype.ac3Fase ? spanningV / sqrt(3) : spanningV;

  /// Bronimpedantie per fase, verwezen naar secundaire zijde [Ω].
  /// Bevat transformatorimpedantie + optionele netwerkimpedantie.
  /// Geeft 0 terug als bronimpedantie niet actief is.
  double get zbOhm {
    if (!bronimpedantieActief) return 0.0;
    if (zUpstreamHandmatigMohm != null && zUpstreamHandmatigMohm! > 0) {
      // Gebruiker heeft volledige lusimpedantie upstream opgegeven [mΩ];
      // per-fase equivalent = helft van de lusimpedantie.
      return zUpstreamHandmatigMohm! / 2000.0;
    }
    final zbTrafo = (transformatorUccPct / 100.0) *
        (spanningV * spanningV) /
        (transformatorKva * 1000.0);
    if (skNetOneindig || skNetMva <= 0) return zbTrafo;
    final zbNet = (spanningV * spanningV) / (skNetMva * 1e6);
    return zbTrafo + zbNet;
  }

  /// Enkelfasige lus-kortsluitstroom aan de bron [A] (TN-stelsel).
  /// Geld als effectieve kortsluitstroomA wanneer bronimpedantie actief is.
  ///   I_k = U_fase / (2 × Z_b)
  double get ikBronBerekendA {
    final zb = zbOhm;
    if (zb <= 0) return 0.0;
    return uFaseV / (2.0 * zb);
  }

  /// Effectieve kortsluitstroom [A] voor de berekening:
  /// uit bronimpedantie als actief, anders handmatig ingevoerd.
  double get effectieveKortsluitstroomA {
    if (bronimpedantieActief && zbOhm > 0) return ikBronBerekendA;
    return kortsluitstroomA;
  }

  /// Berekende activeringsstroom [A] voor de kortsluitbeveiliging,
  /// of null als de max-lengte-toets niet actief is.
  double? get beveiligingIa {
    if (beveiligingType == null || beveiligingWaarde == null) return null;
    return beveiligingType!.berekenIa(beveiligingWaarde!);
  }

  /// Of harmonischencorrectie van toepassing is (NEN 1010 Bijlage 52.E.1).
  bool get harmonischenActief =>
      systeem == Systeemtype.ac3Fase &&
      (aantalAders == 4 || aantalAders == 5) &&
      derdeHarmonischePct > 0;

  Map<String, dynamic> toJson() => {
        'systeem': systeem.name,
        'spanningV': spanningV,
        'stroomA': stroomA,
        'vermogenW': vermogenW,
        'cosPhi': cosPhi,
        'frequentieHz': frequentieHz,
        'lengteM': lengteM,
        'legging': legging.name,
        'geleider': geleider.name,
        'isolatie': isolatie.name,
        'omgevingstempC': omgevingstempC,
        'grondtempC': grondtempC,
        'lambdaGrond': lambdaGrond,
        'bundel': bundel?.toJson(),
        'maxSpanningsvalPct': maxSpanningsvalPct,
        'kortsluitstroomA': kortsluitstroomA,
        'kortsluitduurMs': kortsluitduurMs,
        'beveiligingType': beveiligingType?.name,
        'beveiligingWaarde': beveiligingWaarde,
        'zonlichtToeslagK': zonlichtToeslagK,
        'derdeHarmonischePct': derdeHarmonischePct,
        'forceerDoorsnedemm2': forceerDoorsnedemm2,
        'nParallel': nParallel,
        'aantalAders': aantalAders,
        'geleidersPerKring': geleidersPerKring,
        'diepteM': diepteM,
        'cyclischProfiel': cyclischProfiel,
        'cyclischNKringen': cyclischNKringen,
        'cyclischAanliggend': cyclischAanliggend,
        'cyclischHartOpHartMm': cyclischHartOpHartMm,
        'bronimpedantieActief': bronimpedantieActief,
        'transformatorHandmatig': transformatorHandmatig,
        'transformatorKva': transformatorKva,
        'transformatorUccPct': transformatorUccPct,
        'aardingsstelsel': aardingsstelsel.name,
        'skNetOneindig': skNetOneindig,
        'skNetMva': skNetMva,
        'zUpstreamHandmatigMohm': zUpstreamHandmatigMohm,
      };

  factory Invoer.fromJson(Map<String, dynamic> j) => Invoer(
        systeem: Systeemtype.values.byName(j['systeem'] as String),
        spanningV: (j['spanningV'] as num).toDouble(),
        stroomA: (j['stroomA'] as num).toDouble(),
        vermogenW: j['vermogenW'] != null ? (j['vermogenW'] as num).toDouble() : null,
        cosPhi: (j['cosPhi'] as num).toDouble(),
        frequentieHz: (j['frequentieHz'] as num).toDouble(),
        lengteM: (j['lengteM'] as num).toDouble(),
        legging: Leggingswijze.values.byName(j['legging'] as String),
        geleider: Geleidermateriaal.values.byName(j['geleider'] as String),
        isolatie: Isolatiemateriaal.values.byName(j['isolatie'] as String),
        omgevingstempC: (j['omgevingstempC'] as num).toDouble(),
        grondtempC: (j['grondtempC'] as num).toDouble(),
        lambdaGrond: (j['lambdaGrond'] as num).toDouble(),
        bundel: j['bundel'] != null
            ? BundelConfig.fromJson(j['bundel'] as Map<String, dynamic>)
            : null,
        maxSpanningsvalPct: (j['maxSpanningsvalPct'] as num).toDouble(),
        kortsluitstroomA: (j['kortsluitstroomA'] as num).toDouble(),
        kortsluitduurMs: (j['kortsluitduurMs'] as num).toDouble(),
        beveiligingType: j['beveiligingType'] != null
            ? BeveiligingType.values.byName(j['beveiligingType'] as String)
            : null,
        beveiligingWaarde: j['beveiligingWaarde'] != null
            ? (j['beveiligingWaarde'] as num).toDouble()
            : null,
        zonlichtToeslagK: (j['zonlichtToeslagK'] as num).toDouble(),
        derdeHarmonischePct: (j['derdeHarmonischePct'] as num).toDouble(),
        forceerDoorsnedemm2: j['forceerDoorsnedemm2'] != null
            ? (j['forceerDoorsnedemm2'] as num).toDouble()
            : null,
        nParallel: j['nParallel'] as int,
        aantalAders: j['aantalAders'] as int,
        geleidersPerKring: j['geleidersPerKring'] as int,
        diepteM: (j['diepteM'] as num).toDouble(),
        cyclischProfiel: j['cyclischProfiel'] != null
            ? (j['cyclischProfiel'] as List).map((e) => (e as num).toDouble()).toList()
            : null,
        cyclischNKringen: j['cyclischNKringen'] as int,
        cyclischAanliggend: j['cyclischAanliggend'] as bool,
        cyclischHartOpHartMm: (j['cyclischHartOpHartMm'] as num).toDouble(),
        bronimpedantieActief: j['bronimpedantieActief'] as bool? ?? false,
        transformatorHandmatig: j['transformatorHandmatig'] as bool? ?? false,
        transformatorKva: j['transformatorKva'] != null
            ? (j['transformatorKva'] as num).toDouble()
            : 250.0,
        transformatorUccPct: j['transformatorUccPct'] != null
            ? (j['transformatorUccPct'] as num).toDouble()
            : 4.0,
        aardingsstelsel: j['aardingsstelsel'] != null
            ? Aardingsstelsel.values.byName(j['aardingsstelsel'] as String)
            : Aardingsstelsel.tnS,
        skNetOneindig: j['skNetOneindig'] as bool? ?? true,
        skNetMva: j['skNetMva'] != null
            ? (j['skNetMva'] as num).toDouble()
            : 100.0,
        zUpstreamHandmatigMohm: j['zUpstreamHandmatigMohm'] != null
            ? (j['zUpstreamHandmatigMohm'] as num).toDouble()
            : null,
      );

  Invoer copyWith({
    Systeemtype? systeem,
    double? spanningV,
    double? stroomA,
    double? vermogenW,
    bool clearVermogen = false,
    double? cosPhi,
    double? frequentieHz,
    double? lengteM,
    Leggingswijze? legging,
    Geleidermateriaal? geleider,
    Isolatiemateriaal? isolatie,
    double? omgevingstempC,
    double? grondtempC,
    double? lambdaGrond,
    BundelConfig? bundel,
    bool clearBundel = false,
    double? maxSpanningsvalPct,
    double? kortsluitstroomA,
    double? kortsluitduurMs,
    BeveiligingType? beveiligingType,
    bool clearBeveiligingType = false,
    double? beveiligingWaarde,
    bool clearBeveiligingWaarde = false,
    double? zonlichtToeslagK,
    double? derdeHarmonischePct,
    double? forceerDoorsnedemm2,
    bool clearForceer = false,
    int? nParallel,
    int? aantalAders,
    int? geleidersPerKring,
    double? diepteM,
    List<double>? cyclischProfiel,
    bool clearCyclisch = false,
    int? cyclischNKringen,
    bool? cyclischAanliggend,
    double? cyclischHartOpHartMm,
    bool? bronimpedantieActief,
    bool? transformatorHandmatig,
    double? transformatorKva,
    double? transformatorUccPct,
    Aardingsstelsel? aardingsstelsel,
    bool? skNetOneindig,
    double? skNetMva,
    double? zUpstreamHandmatigMohm,
    bool clearZUpstream = false,
  }) =>
      Invoer(
        systeem: systeem ?? this.systeem,
        spanningV: spanningV ?? this.spanningV,
        stroomA: stroomA ?? this.stroomA,
        vermogenW: clearVermogen ? null : (vermogenW ?? this.vermogenW),
        cosPhi: cosPhi ?? this.cosPhi,
        frequentieHz: frequentieHz ?? this.frequentieHz,
        lengteM: lengteM ?? this.lengteM,
        legging: legging ?? this.legging,
        geleider: geleider ?? this.geleider,
        isolatie: isolatie ?? this.isolatie,
        omgevingstempC: omgevingstempC ?? this.omgevingstempC,
        grondtempC: grondtempC ?? this.grondtempC,
        lambdaGrond: lambdaGrond ?? this.lambdaGrond,
        bundel: clearBundel ? null : (bundel ?? this.bundel),
        maxSpanningsvalPct: maxSpanningsvalPct ?? this.maxSpanningsvalPct,
        kortsluitstroomA: kortsluitstroomA ?? this.kortsluitstroomA,
        kortsluitduurMs: kortsluitduurMs ?? this.kortsluitduurMs,
        beveiligingType:
            clearBeveiligingType ? null : (beveiligingType ?? this.beveiligingType),
        beveiligingWaarde:
            clearBeveiligingWaarde ? null : (beveiligingWaarde ?? this.beveiligingWaarde),
        zonlichtToeslagK: zonlichtToeslagK ?? this.zonlichtToeslagK,
        derdeHarmonischePct: derdeHarmonischePct ?? this.derdeHarmonischePct,
        forceerDoorsnedemm2:
            clearForceer ? null : (forceerDoorsnedemm2 ?? this.forceerDoorsnedemm2),
        nParallel: nParallel ?? this.nParallel,
        aantalAders: aantalAders ?? this.aantalAders,
        geleidersPerKring: geleidersPerKring ?? this.geleidersPerKring,
        diepteM: diepteM ?? this.diepteM,
        cyclischProfiel: clearCyclisch ? null : (cyclischProfiel ?? this.cyclischProfiel),
        cyclischNKringen: cyclischNKringen ?? this.cyclischNKringen,
        cyclischAanliggend: cyclischAanliggend ?? this.cyclischAanliggend,
        cyclischHartOpHartMm: cyclischHartOpHartMm ?? this.cyclischHartOpHartMm,
        bronimpedantieActief: bronimpedantieActief ?? this.bronimpedantieActief,
        transformatorHandmatig: transformatorHandmatig ?? this.transformatorHandmatig,
        transformatorKva: transformatorKva ?? this.transformatorKva,
        transformatorUccPct: transformatorUccPct ?? this.transformatorUccPct,
        aardingsstelsel: aardingsstelsel ?? this.aardingsstelsel,
        skNetOneindig: skNetOneindig ?? this.skNetOneindig,
        skNetMva: skNetMva ?? this.skNetMva,
        zUpstreamHandmatigMohm: clearZUpstream
            ? null
            : (zUpstreamHandmatigMohm ?? this.zUpstreamHandmatigMohm),
      );
}
