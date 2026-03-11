#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
KABELBEREKENINGSPROGRAMMA v3.0 — PRAKTISCHE VOORBEELDEN
=========================================================
Demonstratie van alle berekeningsscenario's:
  1. Enkele 3-fase AC kabel (werkplaats)
  2. 1-fase AC kabel (voedingscircuit)
  3. Bundel 20 × 5 kabels — maatgevende kabel bepaald
  4. Ondergrondse kabel (D1) met bodemweerstand
  5. DC-systeem 2-draad (PV-installatie)
  6. Kortsluittoets + minimum doorsnede
  7. Vergelijkingstabel alle doorsnedes

Importeer kabelberekening.py als bibliotheek.
"""

from kabelberekening import (
    Invoer, BundelConfig, Resultaten,
    Systeemtype, Geleidermateriaal, Isolatiemateriaal, Leggingswijze,
    bereken, rapport,
    STANDAARD_DOORSNEDES_CU, KABEL_CATALOGUS,
    Correctiefactoren, Kortsluit, K_WAARDEN,
    ISOLATIE_EIGENSCHAPPEN, GELEIDER_EIGENSCHAPPEN,
    VERSION, NORM_REFERENCE,
)
import math


SCHEIDINGSLIJN = "═" * 82


def demo_header():
    print(f"""
{SCHEIDINGSLIJN}
  KABELBEREKENINGSPROGRAMMA v{VERSION} — DEMONSTRATIE
  Normen: {NORM_REFERENCE}
{SCHEIDINGSLIJN}
""")


# ============================================================================
# VOORBEELD 1: Enkele 3-fase kabel (werkplaats)
# ============================================================================

def voorbeeld_1_enkelvoudige_3fase():
    """
    Werkplaats driefaseaansluiting:
      - 3-fase 400 V / 50 Hz
      - Belasting: 28 kW motor, cos φ = 0.87
      - Lengte: 35 m
      - Legging: aanliggend aan wand (methode C)
      - Omgeving: 25 °C
      - Cu XLPE kabel
      - Eis spanningsval: ≤ 3%
      - Kortsluit: 8 kA / 500 ms
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 1: Enkele 3-fase kabel — werkplaats motoraansluiting")
    print(f"{'─'*82}")

    inv = Invoer(
        systeem=Systeemtype.AC_3FASE,
        spanning_v=400,
        stroom_a=0,
        vermogen_w=28000,        # 28 kW motor
        cos_phi=0.87,
        frequentie_hz=50,
        lengte_m=35,
        legging=Leggingswijze.C,
        geleider=Geleidermateriaal.KOPER,
        isolatie=Isolatiemateriaal.XLPE,
        omgevingstemp_c=25,
        max_spanningsval_pct=3.0,
        kortsluitstroom_a=8000,
        kortsluitduur_ms=500,
        normkeuze="NEN 1010",
    )

    res = bereken(inv)
    print(rapport(inv, res))


# ============================================================================
# VOORBEELD 2: 1-fase circuit (verlichting / stopcontact)
# ============================================================================

def voorbeeld_2_eenfase():
    """
    1-fase verlichtingscircuit:
      - 230 V / 50 Hz
      - Stroom: 16 A
      - Lengte: 30 m
      - Legging: methode B2 (in buis op wand)
      - Cu PVC
      - Omgeving: 30 °C
      - Eis: ≤ 3%

    LET OP: 1-fase spanningsval gebruikt factor 2 (retour via N-geleider).
    Dit was een bug in v1/v2 — nu correct.
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 2: 1-fase verdeelcircuit  (correcte factor ×2 voor retour!)")
    print(f"{'─'*82}")

    inv = Invoer(
        systeem=Systeemtype.AC_1FASE,
        spanning_v=230,
        stroom_a=16,
        cos_phi=1.0,             # puur resistief
        lengte_m=30,
        legging=Leggingswijze.B2,
        geleider=Geleidermateriaal.KOPER,
        isolatie=Isolatiemateriaal.PVC,
        omgevingstemp_c=30,
        max_spanningsval_pct=3.0,
        normkeuze="NEN 1010",
    )

    res = bereken(inv)
    print(rapport(inv, res))

    # Toon verschil correcte vs. oude formule
    if res.kabel:
        R_m = res.kabel.R_ac_per_km_20C / 1000.0
        X_m = res.kabel.X_ac_per_km / 1000.0
        I   = inv.stroom_a
        L   = inv.lengte_m
        cos = inv.cos_phi
        sin = math.sqrt(1 - cos**2)

        dU_correct = 2 * I * L * (R_m * cos + X_m * sin)
        dU_fout_v1 = 1 * I * L * (R_m * cos + X_m * sin)   # v1 miste factor 2

        print("  ┌─ VERGELIJKING MET VERSIE 1 ─────────────────────────────────────────")
        print(f"  │  ΔU correct (×2 retour): {dU_correct:.3f} V  = {100*dU_correct/230:.2f}%")
        print(f"  │  ΔU v1-formule (×1, fout): {dU_fout_v1:.3f} V  = {100*dU_fout_v1/230:.2f}%")
        print(f"  │  Verschil: {dU_correct - dU_fout_v1:.3f} V — v1 onderschatte met factor 2!")
        print("  └────────────────────────────────────────────────────────────────────")


# ============================================================================
# VOORBEELD 3: Bundel 20 × 5 kabels
# ============================================================================

def voorbeeld_3_bundel_20x5():
    """
    Kabelbundel in kabelgoot:
      - 20 kabels naast elkaar × 5 lagen hoog = 100 kabels totaal
      - Elk circuit: 3-fase 400V, 16A
      - Lengte: 40 m
      - Hart-op-hart: 65 mm (typisch voor 12-16 mm² kabel)
      - Omgeving: 35 °C
      - Cu PVC, methode F (kabelgoot, touching)
      - Eis: ≤ 2%

    Vraagstelling: is de slechtst gekoelde kabel (centrum) nog veilig?
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 3: BUNDEL 20 × 5 kabels — slechtst gekoelde positie")
    print(f"{'─'*82}")

    bundel = BundelConfig(
        n_horizontaal=20,
        n_verticaal=5,
        hart_op_hart_mm=65,
    )

    # Toon bundel-analyse vooraf
    f_h = Correctiefactoren.f_horizontale_bundeling(20)
    f_v = Correctiefactoren.f_verticale_stapeling(5)
    worst = bundel.slechtste_positie()
    print(f"""
  Bundelanalyse:
    Indeling           : 20 breed × 5 hoog = {bundel.totaal_kabels} kabels totaal
    f_h (20 kabels)    : {f_h:.3f}  (tabel B.52.20: 20 kabels in één laag)
    f_v (5 lagen)      : {f_v:.3f}  (tabel B.52.21: aanvullend voor 5 lagen)
    Gecomb. factor     : {f_h*f_v:.3f}  → de slechtste kabel mag nog maar {f_h*f_v*100:.1f}% dragen
    Maatgevende positie: ({worst[0]}, {worst[1]}) — centrum van het pakket
    """)

    inv = Invoer(
        systeem=Systeemtype.AC_3FASE,
        spanning_v=400,
        stroom_a=16,
        cos_phi=0.92,
        lengte_m=40,
        legging=Leggingswijze.F,
        geleider=Geleidermateriaal.KOPER,
        isolatie=Isolatiemateriaal.PVC,
        omgevingstemp_c=35,
        bundel=bundel,
        max_spanningsval_pct=2.0,
        normkeuze="IEC",
    )

    res = bereken(inv)
    print(rapport(inv, res))

    # Vergelijk: gemiddelde kabel vs. slechtste kabel
    f_gemiddeld = bundel.factor_gemiddelde_kabel()
    f_worst     = bundel.gecombineerde_factor()
    print(f"""  ┌─ VERGELIJKING KABELPOSITIES ────────────────────────────────────────
  │  Gemiddelde kabel (totaal {bundel.totaal_kabels} als 1 groep): f = {f_gemiddeld:.3f}
  │  Slechtste kabel  (centrum, gecombineerd):  f = {f_worst:.3f}
  │  Verschil:        {(f_worst - f_gemiddeld)*100:+.1f}%  — centrum is {abs((f_worst/f_gemiddeld-1)*100):.1f}% ongunstiger
  └────────────────────────────────────────────────────────────────────""")


# ============================================================================
# VOORBEELD 4: Ondergrondse kabel
# ============================================================================

def voorbeeld_4_ondergronds():
    """
    Ondergrondse voedingskabel:
      - 3-fase 400 V, 60 A
      - Direct ingegraven (methode D1), diepte 0.80 m
      - Bodemthermische weerstand: 1.5 K·m/W (droge zandgrond)
      - Grondtemperatuur: 20 °C
      - Cu XLPE
      - Lengte: 80 m
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 4: Ondergrondse kabel (D1) met bodemweerstand")
    print(f"{'─'*82}")

    inv = Invoer(
        systeem=Systeemtype.AC_3FASE,
        spanning_v=400,
        stroom_a=60,
        cos_phi=0.93,
        lengte_m=80,
        legging=Leggingswijze.D1,
        geleider=Geleidermateriaal.KOPER,
        isolatie=Isolatiemateriaal.XLPE,
        omgevingstemp_c=30,
        grondtemp_c=20,
        lambda_grond=1.5,        # K·m/W — droge zandgrond
        max_spanningsval_pct=2.5,
        normkeuze="NEN 1010",
    )

    res = bereken(inv)
    print(rapport(inv, res))

    # Toon invloed bodemweerstand
    print("  ┌─ INVLOED BODEMTHERMISCHE WEERSTAND ────────────────────────────────")
    print("  │  λ (K·m/W)   Correctiefactor   Reden")
    print("  │  " + "─"*60)
    for lam, omsch in [(0.5, "natte klei"),
                        (1.0, "referentie (vochtige grond)"),
                        (1.5, "droge grond (dit geval)"),
                        (2.0, "droog zand"),
                        (2.5, "zeer droog zand (ongunstigst)")]:
        f = Correctiefactoren.f_bodemweerstand(lam)
        print(f"  │  {lam:>5.1f}          {f:.3f}            {omsch}")
    print("  └────────────────────────────────────────────────────────────────────")


# ============================================================================
# VOORBEELD 5: DC-systeem (PV-installatie)
# ============================================================================

def voorbeeld_5_dc_pvinstallatie():
    """
    DC-kabels PV-installatie (zonnepanelen → omvormer):
      - DC 48 V systeem
      - Stroom: 60 A (bij STC: kortstondige piekstroom hogere waarde)
      - Lengte: 25 m (enkele richting)
      - 2-draads systeem (+ en −)
      - Cu XLPE (UV-bestendig)
      - Eis: ≤ 2% spanningsval (NEN 1041 voor PV ≤ 1%)

    Toon juiste DC formule: ΔU = 2·I·R·L (factor 2 voor heen + retour).
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 5: DC 2-draad — PV-installatie")
    print(f"{'─'*82}")

    inv = Invoer(
        systeem=Systeemtype.DC_2DRAAD,
        spanning_v=48,
        stroom_a=60,
        lengte_m=25,
        legging=Leggingswijze.E,
        geleider=Geleidermateriaal.KOPER,
        isolatie=Isolatiemateriaal.XLPE,
        omgevingstemp_c=45,      # op dak — hogere omgevingstemp
        max_spanningsval_pct=1.5,
        normkeuze="IEC",
    )

    res = bereken(inv)
    print(rapport(inv, res))

    # Vergelijk: AC vs DC resistance (voor informatie)
    print("  ┌─ DC vs AC WEERSTAND ───────────────────────────────────────────────")
    print("  │  Doorsnede   R_DC @ 70°C   R_AC @ 70°C   Verschil")
    print("  │  " + "─"*55)
    prop = GELEIDER_EIGENSCHAPPEN[Geleidermateriaal.KOPER]
    for A in [4.0, 6.0, 10.0, 16.0, 25.0, 35.0]:
        key = (Geleidermateriaal.KOPER, Isolatiemateriaal.XLPE, A)
        kabel = KABEL_CATALOGUS.get(key)
        if kabel is None:
            continue
        R_dc_70 = prop.R_dc(A, 1000, 70)          # Ω/km @ 70°C
        R_ac_70 = kabel.R_ac_per_km_20C * (1 + 0.00393 * (70 - 20))  # Ω/km @ 70°C
        verschil_pct = (R_ac_70 / R_dc_70 - 1) * 100
        print(f"  │  {A:>5.1f} mm²   {R_dc_70:>8.4f} Ω/km  {R_ac_70:>8.4f} Ω/km  {verschil_pct:+.1f}%")
    print("  │  (Skin-effect verwaarloosbaar voor DC en kleine doorsnedes)")
    print("  └────────────────────────────────────────────────────────────────────")


# ============================================================================
# VOORBEELD 6: Kortsluittoets + min. doorsnede
# ============================================================================

def voorbeeld_6_kortsluittoets():
    """
    Verdeelkast voedingskabel met kortsluitcontrole:
      - 3-fase 400 V
      - 100 A belasting
      - 15 m
      - Kortsluitstroom: 15 kA (bij bronzijde)
      - Duur: 200 ms (selectiviteit)
      - Cu XLPE, methode C

    Toont berekening minimale doorsnede uit kortsluitstroom.
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 6: Kortsluittoets — minimum doorsnede bepaling")
    print(f"{'─'*82}")

    I_k = 15000   # A
    t_ms = 200    # ms

    # Toon k-waarden en minimale doorsnedes
    print(f"\n  Kortsluitstroom : {I_k} A")
    print(f"  Duur            : {t_ms} ms = {t_ms/1000:.3f} s")
    print(f"  Formule         : A_min = I_k · √t / k")
    print(f"\n  Minimale doorsnedes (IEC 60949):")
    print(f"  {'Geleider':<10} {'Isolatie':<8} {'k':<6} {'A_min (mm²)'}")
    print(f"  " + "─"*45)

    for (gel, iso), k in K_WAARDEN.items():
        A_min = Kortsluit.min_doorsnede(I_k, t_ms/1000, gel, iso)
        print(f"  {gel.value:<10} {iso.value:<8} {k:<6} {A_min:.2f} mm²")

    inv = Invoer(
        systeem=Systeemtype.AC_3FASE,
        spanning_v=400,
        stroom_a=100,
        cos_phi=0.95,
        lengte_m=15,
        legging=Leggingswijze.C,
        geleider=Geleidermateriaal.KOPER,
        isolatie=Isolatiemateriaal.XLPE,
        omgevingstemp_c=30,
        max_spanningsval_pct=3.0,
        kortsluitstroom_a=I_k,
        kortsluitduur_ms=t_ms,
        normkeuze="IEC",
    )

    res = bereken(inv)
    print(rapport(inv, res))


# ============================================================================
# VOORBEELD 7: Vergelijkingstabel Cu PVC methode C
# ============================================================================

def voorbeeld_7_vergelijkingstabel():
    """
    Vergelijkingstabel voor Cu PVC, methode C, 3-fase 400 V.
    Toont toelaatbare stroom, correctiefactoren, spanningsval
    voor alle standaard doorsnedes.
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 7: VERGELIJKINGSTABEL — Cu PVC, methode C, 3-fase 400 V")
    print(f"{'─'*82}")
    print(f"  Conditie: 50 m kabel, 50 A, cos φ = 0.90, θ_amb = 35 °C\n")

    stroom = 50
    spanning = 400
    lengte = 50
    cos_phi = 0.90
    T_amb = 35

    # Temperatuurcorrectie
    f_T = Correctiefactoren.f_temperatuur(T_amb, 70.0)

    print(f"  Temperatuurcorrectie: f_T = √[(70−{T_amb})/(70−30)] = {f_T:.4f}\n")

    header = (f"  {'Doorsnede':>10} | {'I_z0':>6} | {'I_z':>6} | "
              f"{'ΔU [V]':>7} | {'ΔU [%]':>7} | {'Marge':>8} | Status")
    print(header)
    print("  " + "─"*(len(header)-2))

    for A in STANDAARD_DOORSNEDES_CU:
        key = (Geleidermateriaal.KOPER, Isolatiemateriaal.PVC, A)
        kabel = KABEL_CATALOGUS.get(key)
        if kabel is None or kabel.I_z_C == 0:
            continue

        I_z0 = kabel.I_z_C
        I_z  = I_z0 * f_T

        # Spanningsval (R bij 70°C)
        prop = GELEIDER_EIGENSCHAPPEN[Geleidermateriaal.KOPER]
        R_70 = prop.R_dc(A, 1.0, 70.0)  # Ω/m
        X_m  = kabel.X_ac_per_km / 1000.0
        sin_phi = math.sqrt(1 - cos_phi**2)
        delta_U = math.sqrt(3) * stroom * lengte * (R_70 * cos_phi + X_m * sin_phi)
        delta_U_pct = 100 * delta_U / spanning

        marge = (I_z / stroom - 1) * 100 if stroom > 0 else 0
        ok_stroom  = I_z >= stroom
        ok_sv      = delta_U_pct <= 3.0
        status = ("✓ OK" if ok_stroom and ok_sv
                  else ("⚠ stroom" if not ok_stroom
                        else "⚠ span.val"))

        print(f"  {A:>8.1f} mm² | {I_z0:>5.1f} | {I_z:>5.1f} | "
              f"{delta_U:>6.3f} | {delta_U_pct:>6.2f}% | {marge:>+7.1f}% | {status}")

    print(f"\n  I_z = I_z0 × f_T = I_z0 × {f_T:.4f}")
    print(f"  ΔU = √3·I·L·(R_70°C·cosφ + X·sinφ),  I={stroom}A, L={lengte}m, U={spanning}V")


# ============================================================================
# VOORBEELD 8: Temperatuurcorrectie — vergelijking v1 vs v3
# ============================================================================

def voorbeeld_8_temp_vergelijking():
    """
    Laat zien dat de lineaire formule van v1/v2 FOUT is.
    Verschil kan oplopen tot >10% bij extreme temperaturen.
    """
    print(f"\n{'─'*82}")
    print("  VOORBEELD 8: TEMPERATUURCORRECTIE — wortelformule vs. lineaire formule (v1-bug)")
    print(f"{'─'*82}")
    print(f"\n  Isolatie: PVC (max. 70 °C, ref. 30 °C)")
    print(f"\n  {'θ_amb':>8} | {'f_T (correct √)':>16} | {'f_T (v1 lineair)':>16} | {'Afwijking':>10}")
    print(f"  " + "─"*60)

    T_max = 70.0
    T_ref = 30.0

    for T_amb in [10, 20, 25, 30, 35, 40, 45, 50, 55, 60]:
        if T_amb >= T_max:
            break
        f_correct = math.sqrt((T_max - T_amb) / (T_max - T_ref))
        f_lineair  = (T_max - T_amb) / (T_max - T_ref)   # lineair (v1 formule)
        afwijking  = (f_lineair / f_correct - 1) * 100

        marker = " ← FOUT v1" if abs(afwijking) > 1.0 else ""
        print(f"  {T_amb:>5} °C  | {f_correct:>12.4f}    | {f_lineair:>12.4f}    | {afwijking:>+8.2f}%{marker}")

    print(f"""
  Conclusie:
    Bij 20 °C: lineaire factor = {(70-20)/(70-30):.4f}, wortelformule = {math.sqrt((70-20)/(70-30)):.4f}
    De lineaire formule OVERSCHAT het vermogen (onveilig bij lage temperatuur).
    Bij 40 °C: lineaire factor = {(70-40)/(70-30):.4f}, wortelformule = {math.sqrt((70-40)/(70-30)):.4f}
    Bij 40 °C ONDERSCHAT de lineaire formule het vermogen.

    Correct per IEC 60364-5-52 §523.2: f_T = √[(θ_max−θ_amb)/(θ_max−θ_ref)]
    """)


# ============================================================================
# HOOFDPROGRAMMA
# ============================================================================

def main():
    demo_header()

    while True:
        print("VOORBEELDEN:")
        print("  1. Enkele 3-fase kabel (werkplaats, 28 kW motor)")
        print("  2. 1-fase circuit (factor ×2 voor retour — was bug in v1)")
        print("  3. Bundel 20 × 5 kabels — slechtst gekoelde kabel bepaald")
        print("  4. Ondergrondse kabel (D1, bodemweerstand)")
        print("  5. DC 2-draad PV-installatie")
        print("  6. Kortsluittoets + minimum doorsnede (IEC 60949)")
        print("  7. Vergelijkingstabel Cu PVC methode C")
        print("  8. Temperatuurcorrectie: wortelformule vs. v1-lineaire formule")
        print("  9. Alles uitvoeren")
        print("  0. Afsluiten")

        keuze = input("\nKeuze: ").strip()

        if keuze == "1":
            voorbeeld_1_enkelvoudige_3fase()
        elif keuze == "2":
            voorbeeld_2_eenfase()
        elif keuze == "3":
            voorbeeld_3_bundel_20x5()
        elif keuze == "4":
            voorbeeld_4_ondergronds()
        elif keuze == "5":
            voorbeeld_5_dc_pvinstallatie()
        elif keuze == "6":
            voorbeeld_6_kortsluittoets()
        elif keuze == "7":
            voorbeeld_7_vergelijkingstabel()
        elif keuze == "8":
            voorbeeld_8_temp_vergelijking()
        elif keuze == "9":
            voorbeeld_1_enkelvoudige_3fase()
            voorbeeld_2_eenfase()
            voorbeeld_3_bundel_20x5()
            voorbeeld_4_ondergronds()
            voorbeeld_5_dc_pvinstallatie()
            voorbeeld_6_kortsluittoets()
            voorbeeld_7_vergelijkingstabel()
            voorbeeld_8_temp_vergelijking()
            print(f"\n{SCHEIDINGSLIJN}")
            print("  Alle voorbeelden uitgevoerd.")
            print(SCHEIDINGSLIJN)
        elif keuze == "0":
            print("\nAfsluiten...")
            break
        else:
            print("  Ongeldige keuze.")

        input("\n[Enter om door te gaan]")
        print()


if __name__ == "__main__":
    main()
