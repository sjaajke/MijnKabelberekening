import 'dart:math';

/// Cyclische reductiefactor M per NEN IEC 60583-1:2002 / NEN IEC 60287-2-1:2023.
/// Alleen van toepassing bij kabels in de grond (leggingswijze D1 of D2).
///
/// De factor M ≥ 1 geeft aan hoeveel meer stroom een kabel kan voeren
/// als de belasting niet continu maximaal is.
class CyclischeFactor {
  CyclischeFactor._();

  /// Berekent de cyclische factor M.
  ///
  /// Parameters:
  /// - profiel      : 24 waarden I/Imax per uur (uur 0..23), waarden 0..1
  /// - De           : uitwendige diameter kabel/mantel in meters
  /// - L            : legdiepte (m)
  /// - xi           : thermische grondweerstand (K·m/W)
  /// - tMax         : max geleidertemperatuur (°C)
  /// - tGr          : grondtemperatuur (°C)
  /// - W            : Joule-verliezen per kabel bij Tmax (W/m) = I²·R
  /// - N            : aantal kringen in groep (≥1)
  /// - dp1          : hart-op-hart afstand tussen kringen (m);
  ///                  gebruik De voor aanliggende kabels (touching)
  /// - aanliggend   : true → T4-formule voor aanliggende legging (touching);
  ///                  false → gespreid (spaced)
  ///
  /// Retourneert M ≥ 1.0; bij fouten of N=1 zonder naburige kringen: 1.0.
  static double bereken({
    required List<double> profiel,
    required double de,
    required double L,
    required double xi,
    required double tMax,
    required double tGr,
    required double W,
    required int N,
    required double dp1,
    required bool aanliggend,
  }) {
    if (profiel.length != 24) return 1.0;
    if (N < 1 || de <= 0 || L <= 0 || xi <= 0) return 1.0;

    // Yi = (I/Imax)² per uur
    final yi = List<double>.generate(24, (h) => profiel[h] * profiel[h]);

    // μ = gemiddelde Yi over 24 uur (gelijkwaardige continu-belasting)
    final mu = yi.fold(0.0, (s, v) => s + v) / 24;

    // ── F: beeldfactor ──────────────────────────────────────────────────────
    // Kabels in rechte lijn; afstand kring k naar kring 0 = k × dp1.
    // F = ∏ d'k / ∏ dk  (k = 1..N-1)
    final double F;
    if (N <= 1 || dp1 <= 0) {
      F = 1.0;
    } else {
      double prodReal = 1.0;
      double prodImg = 1.0;
      for (int k = 1; k < N; k++) {
        final dk = k * dp1;
        prodReal *= dk;
        prodImg *= sqrt((2 * L) * (2 * L) + dk * dk);
      }
      F = prodImg / prodReal;
    }

    // df: fictieve diameter (equivalent één-kabeldiameter voor de groep)
    final double df = (N <= 1 || dp1 <= 0 || F <= 1.0)
        ? de
        : (4 * L) / pow(F, 1.0 / (N - 1)).toDouble();

    // δ: thermische diffusiviteit grond (m²/s)
    final delta = _diffusiviteit(xi);

    // u1 = 2L / de
    final u1 = (2 * L) / de;

    // T4: externe thermische weerstand (K·m/W)
    final t4 = aanliggend ? _t4Aanliggend(u1, xi) : _t4Gespreid(u1, xi);

    // ΔT4: bijdrage van de beeldwarmtebron van de groep
    final deltaT4 = (N <= 1 || dp1 <= 0 || F <= 1.0)
        ? 0.0
        : (xi * log(F)) / (2 * pi);

    // θR(∞) = Tmax − Tgr
    final thetaInf = tMax - tGr;
    if (thetaInf <= 0 || W <= 0) return 1.0;
    final totaalT4 = t4 + deltaT4;
    if (totaalT4 <= 0) return 1.0;

    // k1 = W · (T4 + ΔT4) / θR(∞)
    final k1 = W * totaalT4 / thetaInf;

    // θR(i)/θR(∞) voor i = 0..6
    // θR(0) = 0 per definitie (beginpunt)
    final thetaR = List<double>.filled(7, 0.0);
    for (int i = 1; i <= 6; i++) {
      final t = 3600.0 * i;
      final gamma = _gamma(t, de, df, delta, N, L, F, dp1);
      thetaR[i] = 1.0 - k1 + k1 * gamma;
    }

    // Vind het piekuur (laatste uur met hoogste I/Imax, conform Excel)
    final maxI = profiel.reduce(max);
    if (maxI <= 0) return 1.0;
    int piekUur = 0;
    for (int h = 0; h < 24; h++) {
      if (profiel[h] >= maxI) piekUur = h;
    }

    // Y0..Y5: Yi op en voorafgaand aan het piekuur
    // Y0 = piekuur zelf, Y1 = uur ervoor, ...
    final Y = List<double>.generate(6, (i) => yi[(piekUur - i + 24) % 24]);

    // M = 1 / √( Σ(i=0..5) Yi·(θR(i+1) − θR(i))  +  μ·(1 − θR(6)) )
    double som = 0.0;
    for (int i = 0; i < 6; i++) {
      som += Y[i] * (thetaR[i + 1] - thetaR[i]);
    }
    som += mu * (1.0 - thetaR[6]);

    if (som <= 0 || som.isNaN || som.isInfinite) return 1.0;
    final M = 1.0 / sqrt(som);
    return (M.isNaN || M.isInfinite || M < 1.0) ? 1.0 : M;
  }

  // ── Warmteresponsfunctie ─────────────────────────────────────────────────

  static double _gamma(double t, double de, double df, double delta,
      int N, double L, double F, double dp1) {
    final xDe = de * de / (16.0 * t * delta);
    final eiDe = _negEi(xDe);

    if (N <= 1 || dp1 <= 0) {
      final denom = 2.0 * log(4.0 * L / de);
      return denom > 0 ? eiDe / denom : 0.0;
    }

    final xDf = df * df / (16.0 * t * delta);
    final eiDf = _negEi(xDf);
    final denom = 2.0 * log(4.0 * L * F / de);
    return denom > 0 ? (eiDe + (N - 1) * eiDf) / denom : 0.0;
  }

  // ── Exponentiaalintegraal −Ei(−x) ────────────────────────────────────────
  // Benadering per Abramowitz & Stegun (identiek aan Excel-implementatie).

  static double _negEi(double x) {
    if (x <= 0) return 0.0;
    if (x <= 1.0) {
      // Polynoom voor 0 < x ≤ 1
      return -log(x)
          - 0.5772
          + 1.0000 * x
          - 0.2499 * x * x
          + 0.0552 * x * x * x
          - 0.0098 * x * x * x * x
          + 0.0011 * x * x * x * x * x;
    }
    // Asymptotische benadering voor x > 1
    final ex = exp(x);
    final teller = x * x + 2.3347 * x + 0.2506;
    final noemer = x * ex * (x * x + 3.3307 * x + 1.6815);
    return noemer > 0 ? teller / noemer : 0.0;
  }

  // ── Externe thermische weerstand T4 ─────────────────────────────────────

  /// T4 voor aanliggende kringen (touching) — NEN IEC 60287-2-1 formule.
  static double _t4Aanliggend(double u1, double xi) {
    if (u1 <= 1.0) return 0.0;
    final arg = u1 + sqrt(u1 * u1 - 1.0) - 0.63;
    return arg > 0 ? (1.5 * xi / pi) * log(arg) : 0.0;
  }

  /// T4 voor gespreide kringen (spaced) — NEN IEC 60287-2-1 formule.
  static double _t4Gespreid(double u1, double xi) {
    if (u1 <= 1.0) return 0.0;
    final arg = u1 + sqrt(u1 * u1 - 1.0);
    return arg > 0 ? (xi / (2.0 * pi)) * log(arg) : 0.0;
  }

  // ── Thermische diffusiviteit ─────────────────────────────────────────────

  /// Lookup-tabel δ (m²/s) bij gegeven ξ (K·m/W) — conform Excel-tabel.
  static double _diffusiviteit(double xi) {
    const xs = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0, 2.5, 3.0];
    const ds = [8e-7, 7e-7, 6e-7, 6e-7, 5e-7, 5e-7, 4e-7, 4e-7, 3e-7, 2e-7, 2e-7];
    if (xi <= xs.first) return ds.first;
    if (xi >= xs.last) return ds.last;
    for (int i = 0; i < xs.length - 1; i++) {
      if (xi >= xs[i] && xi <= xs[i + 1]) {
        final f = (xi - xs[i]) / (xs[i + 1] - xs[i]);
        return ds[i] + f * (ds[i + 1] - ds[i]);
      }
    }
    return 5e-7;
  }

  // ── Standaard belastingsprofielen ────────────────────────────────────────

  /// Constant profiel (altijd 1.0): M = 1.0.
  static const List<double> profielConstant = [
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  ];

  /// Dag-nacht cyclus conform het IEC 60583-1 rekenvoorbeeld.
  static const List<double> profielDagCyclus = [
    0.00, 0.00, 0.00, 0.00, 0.00, 0.10,  // uur 0–5
    0.25, 0.60, 0.90, 1.00, 1.00, 1.00,  // uur 6–11
    1.00, 1.00, 1.00, 1.00, 0.90, 0.40,  // uur 12–17
    0.20, 0.15, 0.05, 0.00, 0.00, 0.00,  // uur 18–23
  ];
}
