#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║         KABELBEREKENINGSPROGRAMMA v3.0 — PROFESSIONAL EDITION               ║
║         AC & DC Elektrische Leidingdimensionering                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Normen:                                                                    ║
║    IEC 60364-5-52:2009/A1:2017  Bedrading — keuze en aanbrenging           ║
║    IEC 60287-1-1:2006           Stroombelastbaarheid (thermisch model)      ║
║    IEC 60228:2004               Geleiders voor kabels                       ║
║    IEC 60502-1:2004             Stroomkabels tot 1 kV                       ║
║    IEC 60949:1988               Kortsluitvastheid geleiders                 ║
║    NEN 1010:2020                Veiligheidsbepalingen laagspanning          ║
║    NEN 3082                     Tabellen elektrische installatiewerk        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  VERBETERINGEN t.o.v. v1/v2:                                                ║
║    ✓ Correcte WORTEL-formule temperatuurcorrectie (IEC 60364-5-52 §523)    ║
║    ✓ Factor 2 in 1-fase spanningsval (retourgeleider)                       ║
║    ✓ Correcte k-waarden kortsluit: Cu/Al × PVC/XLPE gescheiden             ║
║    ✓ Uitgebreide catalogus 1.5–400 mm² Cu + Al, PVC + XLPE                ║
║    ✓ DC-weerstand apart (geen skin-effect bij DC)                           ║
║    ✓ Bundelanalyse: maatgevende positie bepaald (centrum bundel)           ║
║    ✓ Minimum doorsnede berekend vanuit kortsluitstroom                      ║
║    ✓ Interactieve invoer + technisch rapport                               ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import math
from enum import Enum
from dataclasses import dataclass, field
from typing import Optional, Tuple, List, Dict

VERSION = "3.0.0"
NORM_REFERENCE = "IEC 60364-5-52:2009/A1 | IEC 60287 | IEC 60949 | NEN 1010:2020"


# ============================================================================
# SECTIE 1 — ENUMERATIES
# ============================================================================

class Systeemtype(Enum):
    AC_1FASE  = "AC 1-fase (L + N)"
    AC_3FASE  = "AC 3-fase (3L + PE)"
    DC_2DRAAD = "DC 2-draad (+ / −)"
    DC_AARDE  = "DC met aardretour"


class Geleidermateriaal(Enum):
    KOPER     = "Cu"
    ALUMINIUM = "Al"


class Isolatiemateriaal(Enum):
    PVC  = "PVC"    # max 70 °C continu, 160 °C kortsluit
    XLPE = "XLPE"   # max 90 °C continu, 250 °C kortsluit
    EPR  = "EPR"    # max 90 °C continu, 250 °C kortsluit


class Leggingswijze(Enum):
    """
    Referentiemethoden per IEC 60364-5-52 Bijlage B.
    Code links naar stroomtabel.
    """
    A1  = "A1  — In isolerende buis, ingebouwd in thermisch isolerende wand"
    A2  = "A2  — In isolerende buis, ingebouwd in gemetselde wand"
    B1  = "B1  — In kabelkanaal/buis op/in wand (meerkabelig)"
    B2  = "B2  — In kabelkanaal/buis op/in wand (eénkabelig)"
    C   = "C   — Aanliggend aan wand/plafond (direct op oppervlak)"
    D1  = "D1  — Direct ingegraven (in grond)"
    D2  = "D2  — In buis ingegraven"
    E   = "E   — In vrije lucht (1 D van oppervlak)"
    F   = "F   — Op kabelgoot (touching)"
    G   = "G   — Op kabelgoot (spaced, 1 D)"


# ============================================================================
# SECTIE 2 — MATERIAALEIGENSCHAPPEN & NORMBEPERKINGEN
# ============================================================================

@dataclass(frozen=True)
class IsolatieProp:
    """Isolatie-eigenschappen per IEC 60502/60228."""
    max_temp_continu:   float   # °C — maximale geleidertemperatuur bij continue belasting
    max_temp_kortsluit: float   # °C — maximale temperatuur bij kortsluit (IEC 60949)
    ref_temp_tabel:     float   # °C — referentietemperatuur van stroomtabellen


ISOLATIE_EIGENSCHAPPEN: Dict[Isolatiemateriaal, IsolatieProp] = {
    Isolatiemateriaal.PVC:  IsolatieProp(70,  160, 30),
    Isolatiemateriaal.XLPE: IsolatieProp(90,  250, 30),
    Isolatiemateriaal.EPR:  IsolatieProp(90,  250, 30),
}


@dataclass(frozen=True)
class GeleiderProp:
    """Temperatuurafhankelijke weerstandseigenschappen (IEC 60228)."""
    materiaal:    Geleidermateriaal
    rho_20:       float   # Ω·mm²/m @ 20 °C  (resistiviteit bij 20 °C)
    alpha_20:     float   # 1/K               (temperatuurcoëfficiënt bij 20 °C)

    def rho_bij_temp(self, T: float) -> float:
        """ρ(T) = ρ₂₀ · [1 + α₂₀ · (T − 20)]  [Ω·mm²/m]"""
        return self.rho_20 * (1 + self.alpha_20 * (T - 20.0))

    def R_dc(self, doorsnede_mm2: float, lengte_m: float, T: float = 20.0) -> float:
        """DC-weerstand: R = ρ(T) · L / A  [Ω]"""
        if doorsnede_mm2 <= 0:
            return float('inf')
        return self.rho_bij_temp(T) * lengte_m / doorsnede_mm2


GELEIDER_EIGENSCHAPPEN: Dict[Geleidermateriaal, GeleiderProp] = {
    Geleidermateriaal.KOPER:     GeleiderProp(Geleidermateriaal.KOPER,     0.017241, 0.00393),
    Geleidermateriaal.ALUMINIUM: GeleiderProp(Geleidermateriaal.ALUMINIUM, 0.028264, 0.00403),
}

# k-waarden IEC 60949 voor adiabatische kortsluitberekening
# A_min = I_k · √t / k    →    k = f(materiaal, isolatie, initiële temp, eindtemp)
K_WAARDEN: Dict[Tuple[Geleidermateriaal, Isolatiemateriaal], float] = {
    (Geleidermateriaal.KOPER,     Isolatiemateriaal.PVC):  115,   # Cu, 70→160 °C
    (Geleidermateriaal.KOPER,     Isolatiemateriaal.XLPE): 143,   # Cu, 90→250 °C
    (Geleidermateriaal.KOPER,     Isolatiemateriaal.EPR):  143,   # Cu, 90→250 °C
    (Geleidermateriaal.ALUMINIUM, Isolatiemateriaal.PVC):   76,   # Al, 70→160 °C
    (Geleidermateriaal.ALUMINIUM, Isolatiemateriaal.XLPE):  94,   # Al, 90→250 °C
    (Geleidermateriaal.ALUMINIUM, Isolatiemateriaal.EPR):   94,   # Al, 90→250 °C
}


# ============================================================================
# SECTIE 3 — KABELCATALOGUS
# ============================================================================

@dataclass
class KabelSpec:
    """
    Volledig kabelspecificatie.
    Stroomwaarden I_z_C resp. I_z_E gelden voor:
      - 3 belaste aders, θ_amb = 30 °C
      - I_z_C: methode C (aanliggend aan wand)
      - I_z_E: methode E (vrije lucht, 1D afstand)
    """
    naam:             str
    doorsnede_mm2:    float            # geleiderdoorsnede (mm²)
    geleider:         Geleidermateriaal
    isolatie:         Isolatiemateriaal
    buitendiameter:   float            # mm — totale buitendiameter kabel
    R_ac_per_km_20C:  float            # Ω/km per fase @ 20 °C (AC, incl. skin eff.)
    X_ac_per_km:      float            # Ω/km per fase @ 50 Hz
    I_z_C:            float            # A — referentiestroom methode C (30 °C, 3-fase)
    I_z_E:            float            # A — referentiestroom methode E (vrije lucht)


def _maak_catalogus() -> Dict[Tuple[Geleidermateriaal, Isolatiemateriaal, float], KabelSpec]:
    """
    Bouwt kabelcatalogus op basis van IEC 60364-5-52 tabel B.52.4 (PVC/Cu/C)
    en tabel B.52.5 (XLPE/Cu/C), aangevuld met fabrikantgegevens.

    DC-weerstand (IEC 60228, gestrande geleider, max. @ 20 °C):
      Skin-effect correctie voor AC (benadering, 50 Hz):
        ≤ 50 mm²:  factor 1.00
        70–120 mm²: factor 1.01
        150–185 mm²: factor 1.02
        240–300 mm²: factor 1.03
        400 mm²: factor 1.05

    Reactantie (Ω/km) typisch voor meerkabelig in driehoek/trefoil 50 Hz.
    """
    # (doorsnede, R_dc_20C Ω/km, X Ω/km, buitendiameter mm)
    cu_data = [
        (1.5,   13.30, 0.090,  8.0),
        (2.5,    7.98, 0.085,  9.5),
        (4.0,    4.95, 0.080, 11.0),
        (6.0,    3.30, 0.079, 12.5),
        (10.0,   1.91, 0.075, 15.0),
        (16.0,   1.21, 0.073, 17.5),
        (25.0,   0.780, 0.071, 21.0),
        (35.0,   0.554, 0.070, 23.5),
        (50.0,   0.387, 0.069, 26.5),
        (70.0,   0.268, 0.067, 30.5),   # skin: ×1.01 → 0.271
        (95.0,   0.193, 0.066, 35.0),   # skin: ×1.01 → 0.195
        (120.0,  0.153, 0.065, 39.0),   # skin: ×1.01 → 0.155
        (150.0,  0.124, 0.065, 43.5),   # skin: ×1.02 → 0.126
        (185.0,  0.0991, 0.064, 48.5),  # skin: ×1.02 → 0.101
        (240.0,  0.0754, 0.063, 55.0),  # skin: ×1.03 → 0.0777
        (300.0,  0.0601, 0.063, 61.0),  # skin: ×1.03 → 0.0619
        (400.0,  0.0470, 0.062, 69.0),  # skin: ×1.05 → 0.0494
    ]
    # Skin-effect correctie voor AC
    _skin = {1.5:1.00,2.5:1.00,4.0:1.00,6.0:1.00,10.0:1.00,16.0:1.00,
             25.0:1.00,35.0:1.00,50.0:1.00,70.0:1.01,95.0:1.01,120.0:1.01,
             150.0:1.02,185.0:1.02,240.0:1.03,300.0:1.03,400.0:1.05}

    # IEC 60364-5-52 tabel B.52.4 (Cu PVC 3-fase, methode C, 30 °C):
    pvc_C = {1.5:17.5, 2.5:24, 4:32, 6:41, 10:57, 16:76, 25:101, 35:125,
             50:151, 70:192, 95:232, 120:269, 150:309, 185:353, 240:415, 300:477, 400:562}
    # Methode E (vrije lucht) ≈ 1.25 × methode C (ruwe benadering, afwijkend per doorsnede)
    pvc_E_factor = 1.25

    # IEC 60364-5-52 tabel B.52.5 (Cu XLPE 3-fase, methode C, 30 °C):
    xlpe_C = {1.5:22, 2.5:30, 4:40, 6:51, 10:70, 16:94, 25:119, 35:147,
              50:179, 70:229, 95:278, 120:322, 150:371, 185:424, 240:500, 300:576, 400:675}
    xlpe_E_factor = 1.30

    catalogus = {}

    for (A, R_dc, X, D) in cu_data:
        R_ac = R_dc * _skin.get(A, 1.00)

        # Cu PVC
        key_pvc = (Geleidermateriaal.KOPER, Isolatiemateriaal.PVC, A)
        catalogus[key_pvc] = KabelSpec(
            naam=f"{A} mm² Cu PVC",
            doorsnede_mm2=A,
            geleider=Geleidermateriaal.KOPER,
            isolatie=Isolatiemateriaal.PVC,
            buitendiameter=D,
            R_ac_per_km_20C=R_ac,
            X_ac_per_km=X,
            I_z_C=pvc_C.get(A, 0),
            I_z_E=round(pvc_C.get(A, 0) * pvc_E_factor),
        )
        # Cu XLPE
        key_xlpe = (Geleidermateriaal.KOPER, Isolatiemateriaal.XLPE, A)
        catalogus[key_xlpe] = KabelSpec(
            naam=f"{A} mm² Cu XLPE",
            doorsnede_mm2=A,
            geleider=Geleidermateriaal.KOPER,
            isolatie=Isolatiemateriaal.XLPE,
            buitendiameter=D * 1.05,  # XLPE iets groter
            R_ac_per_km_20C=R_ac,
            X_ac_per_km=X,
            I_z_C=xlpe_C.get(A, 0),
            I_z_E=round(xlpe_C.get(A, 0) * xlpe_E_factor),
        )

    # Aluminium — beschikbaar vanaf 16 mm² (NEN 1010)
    # IEC 60364-5-52 tabel B.52.4 (Al PVC, methode C):
    al_pvc_C = {16:59, 25:79, 35:97, 50:118, 70:150, 95:182, 120:210,
                150:241, 185:276, 240:325, 300:373, 400:434}
    al_xlpe_C = {16:75, 25:97, 35:120, 50:145, 70:185, 95:225, 120:261,
                 150:300, 185:344, 240:405, 300:466, 400:546}
    al_data = [
        (16.0,   1.91, 0.073, 19.0),
        (25.0,   1.20, 0.071, 22.5),
        (35.0,   0.868, 0.070, 25.0),
        (50.0,   0.641, 0.069, 28.5),
        (70.0,   0.443, 0.067, 32.5),
        (95.0,   0.320, 0.066, 37.5),
        (120.0,  0.253, 0.065, 42.0),
        (150.0,  0.206, 0.065, 46.5),
        (185.0,  0.164, 0.064, 51.5),
        (240.0,  0.125, 0.063, 59.0),
        (300.0,  0.100, 0.063, 65.5),
        (400.0,  0.0778, 0.062, 74.0),
    ]
    for (A, R_dc, X, D) in al_data:
        key_al_pvc  = (Geleidermateriaal.ALUMINIUM, Isolatiemateriaal.PVC, A)
        key_al_xlpe = (Geleidermateriaal.ALUMINIUM, Isolatiemateriaal.XLPE, A)
        catalogus[key_al_pvc] = KabelSpec(
            naam=f"{A} mm² Al PVC",
            doorsnede_mm2=A,
            geleider=Geleidermateriaal.ALUMINIUM,
            isolatie=Isolatiemateriaal.PVC,
            buitendiameter=D,
            R_ac_per_km_20C=R_dc,
            X_ac_per_km=X,
            I_z_C=al_pvc_C.get(A, 0),
            I_z_E=round(al_pvc_C.get(A, 0) * 1.25),
        )
        catalogus[key_al_xlpe] = KabelSpec(
            naam=f"{A} mm² Al XLPE",
            doorsnede_mm2=A,
            geleider=Geleidermateriaal.ALUMINIUM,
            isolatie=Isolatiemateriaal.XLPE,
            buitendiameter=D * 1.05,
            R_ac_per_km_20C=R_dc,
            X_ac_per_km=X,
            I_z_C=al_xlpe_C.get(A, 0),
            I_z_E=round(al_xlpe_C.get(A, 0) * 1.30),
        )

    return catalogus


KABEL_CATALOGUS = _maak_catalogus()

STANDAARD_DOORSNEDES_CU = sorted([
    A for (_g, _i, A) in KABEL_CATALOGUS.keys()
    if _g == Geleidermateriaal.KOPER and _i == Isolatiemateriaal.PVC
])
STANDAARD_DOORSNEDES_AL = sorted([
    A for (_g, _i, A) in KABEL_CATALOGUS.keys()
    if _g == Geleidermateriaal.ALUMINIUM and _i == Isolatiemateriaal.PVC
])


# ============================================================================
# SECTIE 4 — CORRECTIEFACTOREN  (IEC 60364-5-52)
# ============================================================================

class Correctiefactoren:
    """
    Alle correctiefactoren voor de toelaatbare stroom.

    Toelaatbare stroom: I_z = I_z0 · f_T · f_bundle
    waarbij:
      f_T      = temperatuurcorrectiefactor (wortelformule!)
      f_bundle = gecombineerde bundelfactor (horizontaal × verticaal)
    """

    @staticmethod
    def f_temperatuur(T_omgeving: float,
                      T_max_isolatie: float,
                      T_referentie: float = 30.0) -> float:
        """
        Temperatuurcorrectiefactor — IEC 60364-5-52 §523.2

        FORMULE (WORTEL, niet lineair!):
            f_T = √[(θ_max − θ_amb) / (θ_max − θ_ref)]

        Achtergrond:
          De maximaal toelaatbare verhitting ∝ (θ_max − θ_amb).
          Stroom ∝ √Verlies ∝ √(I²R) → wortel over de ΔT-verhouding.

        Voorbeeldwaarden (PVC 70°C, ref 30°C):
          θ_amb = 20°C → f_T = √(50/40) = 1.118
          θ_amb = 30°C → f_T = 1.000 (referentie)
          θ_amb = 40°C → f_T = √(30/40) = 0.866
          θ_amb = 50°C → f_T = √(20/40) = 0.707
        """
        teller = T_max_isolatie - T_omgeving
        noemer = T_max_isolatie - T_referentie

        if noemer <= 0 or teller <= 0:
            return 0.0

        return math.sqrt(teller / noemer)

    @staticmethod
    def f_horizontale_bundeling(n_kabels: int) -> float:
        """
        Reductie voor n kabels naast elkaar in één laag.
        IEC 60364-5-52 Tabel B.52.20 (methode C, E, F).

        n=1: 1.00  n=2: 0.80  n=3: 0.70  n=4: 0.65  n=5: 0.60
        n=6: 0.57  n=7: 0.54  n=8: 0.52  n=9: 0.50
        n=12: 0.45  n=16: 0.41  n=20: 0.38
        n>20: ≈0.38 (conservatief, IEC geeft geen hogere waarden)
        """
        tabel = {1:1.00, 2:0.80, 3:0.70, 4:0.65, 5:0.60,
                 6:0.57, 7:0.54, 8:0.52, 9:0.50, 12:0.45,
                 16:0.41, 20:0.38}

        if n_kabels <= 1:
            return 1.00
        if n_kabels in tabel:
            return tabel[n_kabels]

        # Interpolatie voor tussenliggende waarden
        sleutels = sorted(tabel.keys())
        for i in range(len(sleutels) - 1):
            a, b = sleutels[i], sleutels[i+1]
            if a < n_kabels < b:
                fa, fb = tabel[a], tabel[b]
                frac = (n_kabels - a) / (b - a)
                return fa + frac * (fb - fa)

        # Buiten tabel: conservatief 0.38 (n ≥ 20)
        return 0.38

    @staticmethod
    def f_verticale_stapeling(n_lagen: int) -> float:
        """
        Aanvullende reductiefactor voor gestapelde lagen.
        IEC 60364-5-52 Tabel B.52.21 (meerdere lagen op kabelgoot).

        Dit is een MULTIPLICATIEVE factor op de horizontale factor.
        De slechtst gekoelde kabel (centrum bundel) ervaart BEIDE factoren.

        n_lagen=1: 1.00  (geen aanvullende reductie)
        n_lagen=2: 0.87
        n_lagen=3: 0.79
        n_lagen=4: 0.72
        n_lagen=5: 0.66
        n_lagen=6: 0.61
        """
        tabel = {1:1.00, 2:0.87, 3:0.79, 4:0.72, 5:0.66, 6:0.61,
                 7:0.57, 8:0.53, 9:0.50, 10:0.47}

        if n_lagen <= 1:
            return 1.00
        if n_lagen in tabel:
            return tabel[n_lagen]

        # Extrapolatie voorbij 10 lagen: exponentieel afvlakken
        if n_lagen > 10:
            return max(0.40, 0.47 * math.exp(-0.05 * (n_lagen - 10)))

        # Interpolatie voor tussenwaarden
        sleutels = sorted(tabel.keys())
        for i in range(len(sleutels) - 1):
            a, b = sleutels[i], sleutels[i+1]
            if a < n_lagen < b:
                fa, fb = tabel[a], tabel[b]
                frac = (n_lagen - a) / (b - a)
                return fa + frac * (fb - fa)

        return 0.40

    @staticmethod
    def f_bodemweerstand(lambda_grond: float) -> float:
        """
        Correctie bodemthermische weerstand voor grondkabels.
        IEC 60364-5-52 Tabel B.52.16.

        λ_grond in K·m/W (typisch 0.5 tot 2.5):
          0.5: factor 1.28  (natte/kleiachtige grond — gunstiger)
          0.7: factor 1.13
          1.0: factor 1.00  (referentie, droge klei)
          1.5: factor 0.86
          2.0: factor 0.76
          2.5: factor 0.68  (droog zand — ongunstigst)
        """
        tabel_lambda = [0.5, 0.7, 1.0, 1.5, 2.0, 2.5]
        tabel_factor = [1.28, 1.13, 1.00, 0.86, 0.76, 0.68]

        if lambda_grond <= 0.5:
            return 1.28
        if lambda_grond >= 2.5:
            return 0.68

        for i in range(len(tabel_lambda) - 1):
            a, b = tabel_lambda[i], tabel_lambda[i+1]
            if a <= lambda_grond <= b:
                fa, fb = tabel_factor[i], tabel_factor[i+1]
                frac = (lambda_grond - a) / (b - a)
                return fa + frac * (fb - fa)

        return 1.00


# ============================================================================
# SECTIE 5 — BUNDELANALYSE
# ============================================================================

@dataclass
class BundelConfig:
    """
    Configuratie van een kabelbundel (rechthoekige stapeling).

    Slechtst gekoelde kabel = CENTRUM van het pakket.
    Voor 20 breed × 5 hoog: positie (10, 3) [1-gebaseerd].
    """
    n_horizontaal:      int     # kabels naast elkaar
    n_verticaal:        int     # lagen boven elkaar
    hart_op_hart_mm:    float   # hart-op-hartafstand (mm)

    @property
    def totaal_kabels(self) -> int:
        return self.n_horizontaal * self.n_verticaal

    def slechtste_positie(self) -> Tuple[int, int]:
        """Geeft (horizontale_index, verticale_index) — 1-gebaseerd."""
        return (self.n_horizontaal // 2 + 1, self.n_verticaal // 2 + 1)

    def gecombineerde_factor(self) -> float:
        """
        Gecombineerde bundelfactor voor de SLECHTST GEKOELDE kabel.

        Methode (conservatief, per NEN-ingenieurspraktijk):
          f_bundel = f_horizontaal(n_h) × f_verticaal(n_v)

        Aanname: centrum kabel ervaart maximale onderlinge opwarming
        van zowel de horizontale als de verticale buren.
        """
        f_h = Correctiefactoren.f_horizontale_bundeling(self.n_horizontaal)
        f_v = Correctiefactoren.f_verticale_stapeling(self.n_verticaal)
        return f_h * f_v

    def factor_gemiddelde_kabel(self) -> float:
        """
        Gemiddelde kabel factor (minder conservatief):
        Gebaseerd op totaal aantal kabels als 1 grote bundel.
        """
        return Correctiefactoren.f_horizontale_bundeling(self.totaal_kabels)


# ============================================================================
# SECTIE 6 — INVOERDATA
# ============================================================================

@dataclass
class Invoer:
    """Volledige invoer voor de kabelberekening."""

    # Systeemparameters
    systeem:         Systeemtype
    spanning_v:      float          # nominale spanning (V RMS)

    # Belasting
    stroom_a:        float          # gevraagde stroom (A) — OF berekend uit vermogen
    vermogen_w:      Optional[float] = None   # W (alternatief voor stroom)
    cos_phi:         float = 1.0    # arbeidsfactor (alleen AC)
    frequentie_hz:   float = 50.0   # Hz (alleen AC)

    # Kabel
    lengte_m:        float = 1.0    # m
    legging:         Leggingswijze  = Leggingswijze.C
    geleider:        Geleidermateriaal = Geleidermateriaal.KOPER
    isolatie:        Isolatiemateriaal = Isolatiemateriaal.PVC

    # Omgeving
    omgevingstemp_c: float = 30.0   # °C
    grondtemp_c:     float = 20.0   # °C (bij D1/D2)
    lambda_grond:    float = 1.0    # K·m/W bodemthermische weerstand

    # Bundel
    bundel:          Optional[BundelConfig] = None  # None = enkele kabel

    # Eisen
    max_spanningsval_pct: float = 3.0  # %
    normkeuze:       str = "IEC"

    # Kortsluit
    kortsluitstroom_a:   float = 0.0   # A (0 = geen toets)
    kortsluitduur_ms:    float = 500.0  # ms

    def effectieve_stroom(self) -> float:
        """Bepaalt stroom uit vermogen indien opgegeven."""
        if self.vermogen_w is not None and self.vermogen_w > 0:
            if self.systeem == Systeemtype.AC_3FASE:
                return self.vermogen_w / (math.sqrt(3) * self.spanning_v * self.cos_phi)
            else:
                return self.vermogen_w / (self.spanning_v * self.cos_phi)
        return self.stroom_a

    def is_grondkabel(self) -> bool:
        return self.legging in (Leggingswijze.D1, Leggingswijze.D2)


# ============================================================================
# SECTIE 7 — BEREKENINGSRESULTATEN
# ============================================================================

@dataclass
class Resultaten:
    """Volledige berekeningsresultaten."""

    # Geselecteerde kabel
    kabel:                   Optional[KabelSpec] = None
    doorsnede_min_kortsluit: float = 0.0    # mm² — minimum vanuit kortsluit

    # Gevraagde stroom
    I_gevraagd:   float = 0.0    # A

    # Correctiefactoren
    f_T:          float = 1.0    # temperatuurcorrectie
    f_bundel:     float = 1.0    # bundelfactor (gecombineerd)
    f_grond:      float = 1.0    # bodemweerstandsfactor
    f_totaal:     float = 1.0    # totale correctiefactor

    # Toelaatbare stroom
    I_z0:         float = 0.0    # A — referentiestroom uit tabel (θ=30°C)
    I_z:          float = 0.0    # A — toelaatbare stroom (gecorrigeerd)
    marge_stroom_pct: float = 0.0  # % — veiligheidsmarge op stroom

    # Spanningsval
    delta_U_v:    float = 0.0    # V
    delta_U_pct:  float = 0.0    # %
    OK_spanning:  bool  = False

    # Temperatuur
    I2R_verlies_W_per_m:   float = 0.0
    temp_stijging_K:       float = 0.0
    geleider_temp_c:       float = 0.0
    max_temp_c:            float = 70.0
    OK_temp:               bool  = False

    # Kortsluit
    delta_T_kortsluit_K:   float = 0.0
    eindtemp_kortsluit_c:  float = 0.0
    OK_kortsluit:          Optional[bool] = None   # None = niet getoetst

    # Bundel
    bundel_positie_worst:  Optional[Tuple[int, int]] = None

    # Globale status
    voldoet:      bool  = False
    waarschuwingen: List[str] = field(default_factory=list)
    fouten:         List[str] = field(default_factory=list)


# ============================================================================
# SECTIE 8 — BEREKENINGSKERN
# ============================================================================

class Spanningsval:
    """
    Spanningsvalberekeningen voor AC en DC.

    FORMULES:
      1-fase AC: ΔU = 2·I·L·(R·cosφ + X·sinφ)          [factor 2 voor retour!]
      3-fase AC: ΔU = √3·I·L·(R·cosφ + X·sinφ)
      DC 2-draad: ΔU = 2·I·R_DC·L                        [factor 2 voor beide geleiders]
      DC aardretour: ΔU = I·R_DC·L                        [aardretour ≈ 0 Ω]

    Waarbij R en X in Ω/m (per fase), L in meter.
    """

    @staticmethod
    def _correcteer_weerstand_voor_temp(R_20C_per_km: float,
                                        geleider: Geleidermateriaal,
                                        T_geleider: float) -> float:
        """Corrigeert AC-weerstand van 20 °C naar bedrijfstemperatuur T_geleider."""
        prop = GELEIDER_EIGENSCHAPPEN[geleider]
        factor = 1 + prop.alpha_20 * (T_geleider - 20.0)
        return R_20C_per_km * factor / 1000.0  # → Ω/m

    @staticmethod
    def ac_1fase(I: float, R_per_m: float, X_per_m: float,
                 L: float, cos_phi: float) -> Tuple[float, float]:
        """
        ΔU_1ph = 2 · I · L · (R·cosφ + X·sinφ)  [V]

        Factor 2: stroom gaat via leidgeleider ÉN retourgeleider.
        """
        sin_phi = math.sqrt(max(0.0, 1 - cos_phi**2))
        delta_U = 2.0 * I * L * (R_per_m * cos_phi + X_per_m * sin_phi)
        return delta_U

    @staticmethod
    def ac_3fase(I: float, R_per_m: float, X_per_m: float,
                 L: float, cos_phi: float) -> float:
        """
        ΔU_3ph = √3 · I · L · (R·cosφ + X·sinφ)  [V] (lijn-tot-lijn)

        Bij gesymmetrische belasting: nulgeleider voert geen stroom.
        """
        sin_phi = math.sqrt(max(0.0, 1 - cos_phi**2))
        delta_U = math.sqrt(3) * I * L * (R_per_m * cos_phi + X_per_m * sin_phi)
        return delta_U

    @staticmethod
    def dc_2draad(I: float, R_DC_per_m: float, L: float) -> float:
        """
        ΔU_DC = 2 · I · R_DC · L  [V]

        Factor 2: heengeleider + retourgeleider.
        """
        return 2.0 * I * R_DC_per_m * L

    @staticmethod
    def dc_aardretour(I: float, R_DC_per_m: float, L: float) -> float:
        """
        ΔU_DC_aard = I · R_DC · L  [V]

        Aardretour-weerstand verwaarloosbaar (laag bij goed geaarde installatie).
        """
        return I * R_DC_per_m * L

    @classmethod
    def bereken(cls, invoer: Invoer, kabel: KabelSpec, T_geleider: float = 70.0) -> Tuple[float, float]:
        """
        Berekent spanningsval voor het gegeven systeem.

        Returns:
            (ΔU_volt, ΔU_procent)
        """
        I = invoer.effectieve_stroom()
        L = invoer.lengte_m

        if invoer.systeem in (Systeemtype.AC_1FASE, Systeemtype.AC_3FASE):
            R_m = cls._correcteer_weerstand_voor_temp(
                kabel.R_ac_per_km_20C, kabel.geleider, T_geleider
            )
            X_m = kabel.X_ac_per_km / 1000.0

            if invoer.systeem == Systeemtype.AC_1FASE:
                delta_U = cls.ac_1fase(I, R_m, X_m, L, invoer.cos_phi)
            else:
                delta_U = cls.ac_3fase(I, R_m, X_m, L, invoer.cos_phi)

        else:  # DC
            prop = GELEIDER_EIGENSCHAPPEN[kabel.geleider]
            R_dc_m = prop.R_dc(kabel.doorsnede_mm2, 1.0, T_geleider)  # Ω/m

            if invoer.systeem == Systeemtype.DC_2DRAAD:
                delta_U = cls.dc_2draad(I, R_dc_m, L)
            else:
                delta_U = cls.dc_aardretour(I, R_dc_m, L)

        delta_U_pct = 100.0 * delta_U / invoer.spanning_v if invoer.spanning_v > 0 else 0.0
        return delta_U, delta_U_pct


class Thermisch:
    """
    Vereenvoudigd thermisch model voor temperatuurschatting geleider.

    AANPAK:
      P_verlies = I² · R  [W/m]

      Temperatuurstijging benadering (praktisch):
        ΔT ≈ P · λ_th_eff  [K]

      waar λ_th_eff een effectieve thermische weerstand is afgeleid van
      de kabelgeometrie (buitendiameter) en omgeving (lucht vs. grond).

    NOOT: Nauwkeurige berekening vereist IEC 60287 thermisch circuitmodel
    (T1, T2, T3, T4) inclusief dielektrische verliezen en inductieverliezen.
    Voor een conservatieve eerste benadering is dit model voldoende.
    """

    @staticmethod
    def I2R_verlies(I: float, R_per_m: float) -> float:
        """P = I² · R  [W/m]"""
        return I**2 * R_per_m

    @staticmethod
    def temp_stijging_lucht(P_per_m: float, buitendiameter_mm: float) -> float:
        """
        Temperatuurstijging kabel in lucht (vrije convectie benadering).

        Benadering via empirische relatie voor ronde kabels:
          ΔT ≈ P / (π · D · h_conv)

        Convectiecoëfficiënt h_conv ≈ 10 W/(m²·K) voor vrije convectie.
        Effectieve omtrek = π · D [m²/m].
        """
        D_m = buitendiameter_mm / 1000.0
        if D_m <= 0:
            return 0.0
        h_conv = 10.0  # W/(m²·K) vrije convectie in lucht
        omtrek = math.pi * D_m
        return P_per_m / (omtrek * h_conv) if omtrek > 0 else 0.0

    @staticmethod
    def temp_stijging_grond(P_per_m: float,
                            buitendiameter_mm: float,
                            diepte_m: float = 0.70,
                            lambda_grond: float = 1.0) -> float:
        """
        Temperatuurstijging kabel in grond (IEC 60287-2-1 vereenvoudigd).

        T_aarde = (λ_grond / 2π) · ln(4u/d)  [K·m/W]

        u = 2 × diepte (afstand tot spiegelkabel)
        d = buitendiameter kabel (m)
        """
        D_m = buitendiameter_mm / 1000.0
        if D_m <= 0 or diepte_m <= 0:
            return 0.0
        u = 2 * diepte_m
        T_grond = (lambda_grond / (2 * math.pi)) * math.log(4 * u / D_m)
        return P_per_m * T_grond


class Kortsluit:
    """
    Thermische kortsluittoets per IEC 60949.

    FORMULE:
      ΔT = (I_k² · t) / (k² · A²)

    Minimale doorsnede vanuit kortsluitstroom:
      A_min = I_k · √t / k  [mm²]

    k-waarden per materiaal + isolatie (IEC 60949, tabel 1):
      Cu PVC   (70→160 °C): k = 115
      Cu XLPE  (90→250 °C): k = 143
      Al PVC   (70→160 °C): k = 76
      Al XLPE  (90→250 °C): k = 94
    """

    @staticmethod
    def k_waarde(geleider: Geleidermateriaal, isolatie: Isolatiemateriaal) -> float:
        """Geeft k-waarde per IEC 60949."""
        return K_WAARDEN.get((geleider, isolatie), 115)

    @staticmethod
    def temp_stijging(I_k: float, t_s: float, A_mm2: float,
                      geleider: Geleidermateriaal,
                      isolatie: Isolatiemateriaal) -> float:
        """
        Adiabatische temperatuurstijging tijdens kortsluit.

        ΔT = (I_k² · t) / (k² · A²)  [K]
        """
        k = Kortsluit.k_waarde(geleider, isolatie)
        if A_mm2 <= 0:
            return float('inf')
        return (I_k**2 * t_s) / (k**2 * A_mm2**2)

    @staticmethod
    def min_doorsnede(I_k: float, t_s: float,
                      geleider: Geleidermateriaal,
                      isolatie: Isolatiemateriaal) -> float:
        """
        Minimale doorsnede vanuit kortsluitstroom.

        A_min = I_k · √t / k  [mm²]
        """
        k = Kortsluit.k_waarde(geleider, isolatie)
        if k <= 0:
            return float('inf')
        return I_k * math.sqrt(t_s) / k


# ============================================================================
# SECTIE 9 — BEREKENINGSORCHESTRATOR
# ============================================================================

class KabelOntwerper:
    """
    Hoofdklasse: orkestreert de volledige kabelberekening.

    Workflow:
      1. Valideer invoer
      2. Bepaal correctiefactoren
      3. Bereken minimum doorsnede kortsluit
      4. Zoek kleinste geschikte kabel (iteratief)
      5. Bereken spanningsval
      6. Bereken temperatuurstijging
      7. Voer kortsluittoets uit
      8. Stel eindoordeel op
    """

    def __init__(self, invoer: Invoer):
        self.invoer = invoer
        self.res = Resultaten()

    def bereken(self) -> Resultaten:
        """Voert volledige berekening uit en geeft resultaten."""
        self.res = Resultaten()

        if not self._valideer():
            return self.res

        self._bepaal_correctiefactoren()
        self._bepaal_min_doorsnede_kortsluit()
        self._zoek_geschikte_kabel()

        if self.res.kabel is None:
            return self.res

        self._bereken_spanningsval()
        self._bereken_temperatuur()
        self._toets_kortsluit()
        self._eindoordeel()

        return self.res

    # ------------------------------------------------------------------
    def _valideer(self) -> bool:
        I = self.invoer.effectieve_stroom()
        if I <= 0:
            self.res.fouten.append("Stroom/vermogen moet > 0 zijn.")
            return False
        if self.invoer.spanning_v <= 0:
            self.res.fouten.append("Spanning moet > 0 V zijn.")
            return False
        if self.invoer.lengte_m <= 0:
            self.res.fouten.append("Kabellengte moet > 0 m zijn.")
            return False
        if self.invoer.cos_phi <= 0 or self.invoer.cos_phi > 1:
            self.res.fouten.append("cos φ moet tussen 0 (exclusief) en 1 liggen.")
            return False
        if self.invoer.omgevingstemp_c >= 70 and self.invoer.isolatie == Isolatiemateriaal.PVC:
            self.res.waarschuwingen.append(
                f"Omgevingstemperatuur {self.invoer.omgevingstemp_c} °C is ≥ max PVC-temp (70 °C)!"
            )
        self.res.I_gevraagd = I
        return True

    # ------------------------------------------------------------------
    def _bepaal_correctiefactoren(self):
        inv = self.invoer
        isolprop = ISOLATIE_EIGENSCHAPPEN[inv.isolatie]

        # Omgevingstemperatuur voor grond vs. lucht
        T_ref = isolprop.ref_temp_tabel
        T_omg = inv.grondtemp_c if inv.is_grondkabel() else inv.omgevingstemp_c

        self.res.f_T = Correctiefactoren.f_temperatuur(T_omg, isolprop.max_temp_continu, T_ref)

        # Bundelfactor
        if inv.bundel is not None and inv.bundel.totaal_kabels > 1:
            self.res.f_bundel = inv.bundel.gecombineerde_factor()
            self.res.bundel_positie_worst = inv.bundel.slechtste_positie()
        else:
            self.res.f_bundel = 1.0

        # Bodemweerstand
        if inv.is_grondkabel():
            self.res.f_grond = Correctiefactoren.f_bodemweerstand(inv.lambda_grond)
        else:
            self.res.f_grond = 1.0

        self.res.f_totaal = self.res.f_T * self.res.f_bundel * self.res.f_grond

        if self.res.f_totaal <= 0:
            self.res.fouten.append(
                f"Gecombineerde correctiefactor ≤ 0 (f_T={self.res.f_T:.3f}). "
                "Omgevingstemperatuur te hoog?"
            )

    # ------------------------------------------------------------------
    def _bepaal_min_doorsnede_kortsluit(self):
        inv = self.invoer
        if inv.kortsluitstroom_a > 0:
            t_s = inv.kortsluitduur_ms / 1000.0
            self.res.doorsnede_min_kortsluit = Kortsluit.min_doorsnede(
                inv.kortsluitstroom_a, t_s, inv.geleider, inv.isolatie
            )

    # ------------------------------------------------------------------
    def _zoek_geschikte_kabel(self):
        """
        Zoekt de kleinste kabel waarvoor I_z ≥ I_gevraagd.
        Houdt rekening met minimum doorsnede vanuit kortsluit.
        """
        inv = self.invoer
        if self.res.f_totaal <= 0:
            self.res.fouten.append("Geen kabel selecteerbaar: correctiefactor ≤ 0.")
            return

        doorsnedes = (
            STANDAARD_DOORSNEDES_CU
            if inv.geleider == Geleidermateriaal.KOPER
            else STANDAARD_DOORSNEDES_AL
        )

        for A in doorsnedes:
            sleutel = (inv.geleider, inv.isolatie, A)
            kabel = KABEL_CATALOGUS.get(sleutel)
            if kabel is None:
                continue

            # Referentiestroom op basis van leggingswijze
            I_z0 = self._referentie_stroom(kabel)
            if I_z0 <= 0:
                continue

            I_z = I_z0 * self.res.f_totaal

            # Stroom-eis
            if I_z < self.res.I_gevraagd:
                continue

            # Kortsluit minimum-doorsnede-eis
            if A < self.res.doorsnede_min_kortsluit:
                self.res.waarschuwingen.append(
                    f"{A} mm² voldoet aan stroomeis maar niet aan kortsluit-eis "
                    f"(min. {self.res.doorsnede_min_kortsluit:.2f} mm²). "
                    "Zoeken naar grotere doorsnede."
                )
                continue

            # Geschikt gevonden
            self.res.kabel = kabel
            self.res.I_z0  = I_z0
            self.res.I_z   = I_z
            self.res.marge_stroom_pct = (I_z / self.res.I_gevraagd - 1) * 100
            return

        self.res.fouten.append(
            f"Geen geschikte kabel gevonden in catalogus voor I={self.res.I_gevraagd:.1f} A "
            f"met f_totaal={self.res.f_totaal:.3f}. Kies groter geleider of andere legging."
        )

    def _referentie_stroom(self, kabel: KabelSpec) -> float:
        """Kiest I_z0 op basis van leggingswijze (methode C vs. E)."""
        legging = self.invoer.legging
        if legging in (Leggingswijze.E, Leggingswijze.G):
            return kabel.I_z_E
        return kabel.I_z_C  # Conservatief: methode C als default

    # ------------------------------------------------------------------
    def _bereken_spanningsval(self):
        kabel = self.res.kabel
        inv = self.invoer
        isolprop = ISOLATIE_EIGENSCHAPPEN[inv.isolatie]

        # Gebruik bedrijfstemperatuur = max. isol.temp. (conservatief)
        T_gel = isolprop.max_temp_continu

        delta_U, delta_U_pct = Spanningsval.bereken(inv, kabel, T_gel)

        self.res.delta_U_v   = delta_U
        self.res.delta_U_pct = delta_U_pct
        self.res.OK_spanning = delta_U_pct <= inv.max_spanningsval_pct

        if not self.res.OK_spanning:
            self.res.fouten.append(
                f"Spanningsval {delta_U_pct:.2f}% overschrijdt eis {inv.max_spanningsval_pct:.2f}%."
            )

    # ------------------------------------------------------------------
    def _bereken_temperatuur(self):
        kabel = self.res.kabel
        inv = self.invoer
        I = self.res.I_gevraagd
        isolprop = ISOLATIE_EIGENSCHAPPEN[inv.isolatie]

        # Weerstand bij bedrijfstemperatuur (max. isol.temp.)
        T_max = isolprop.max_temp_continu
        prop = GELEIDER_EIGENSCHAPPEN[kabel.geleider]
        R_per_m = prop.R_dc(kabel.doorsnede_mm2, 1.0, T_max)

        P = Thermisch.I2R_verlies(I, R_per_m)
        self.res.I2R_verlies_W_per_m = P

        T_omg = inv.grondtemp_c if inv.is_grondkabel() else inv.omgevingstemp_c

        if inv.is_grondkabel():
            delta_T = Thermisch.temp_stijging_grond(P, kabel.buitendiameter, 0.70, inv.lambda_grond)
        else:
            delta_T = Thermisch.temp_stijging_lucht(P, kabel.buitendiameter)

        self.res.temp_stijging_K   = delta_T
        self.res.geleider_temp_c   = T_omg + delta_T
        self.res.max_temp_c        = isolprop.max_temp_continu
        self.res.OK_temp           = self.res.geleider_temp_c <= isolprop.max_temp_continu

        if not self.res.OK_temp:
            self.res.waarschuwingen.append(
                f"Berekende geleidertemperatuur {self.res.geleider_temp_c:.1f} °C "
                f"> maximum {isolprop.max_temp_continu} °C. "
                "Thermisch model is vereenvoudigd — raadpleeg IEC 60287 voor nauwkeurige waarde."
            )

    # ------------------------------------------------------------------
    def _toets_kortsluit(self):
        inv = self.invoer
        kabel = self.res.kabel
        if inv.kortsluitstroom_a <= 0:
            self.res.OK_kortsluit = None
            return

        t_s = inv.kortsluitduur_ms / 1000.0
        isolprop = ISOLATIE_EIGENSCHAPPEN[inv.isolatie]

        delta_T = Kortsluit.temp_stijging(
            inv.kortsluitstroom_a, t_s,
            kabel.doorsnede_mm2,
            kabel.geleider, kabel.isolatie
        )
        # Uitgangstemp: maximale bedrijfstemperatuur (worst case)
        T_start = isolprop.max_temp_continu
        T_eind  = T_start + delta_T

        self.res.delta_T_kortsluit_K  = delta_T
        self.res.eindtemp_kortsluit_c = T_eind
        self.res.OK_kortsluit = T_eind <= isolprop.max_temp_kortsluit

        if not self.res.OK_kortsluit:
            self.res.fouten.append(
                f"Kortsluittoets: eindtemperatuur {T_eind:.1f} °C > "
                f"max. {isolprop.max_temp_kortsluit} °C voor {kabel.isolatie.value}. "
                f"Minimale doorsnede: {self.res.doorsnede_min_kortsluit:.2f} mm²."
            )

    # ------------------------------------------------------------------
    def _eindoordeel(self):
        self.res.voldoet = (
            len(self.res.fouten) == 0
            and self.res.kabel is not None
            and self.res.OK_spanning
            and self.res.OK_temp
            and (self.res.OK_kortsluit is None or self.res.OK_kortsluit)
        )


# ============================================================================
# SECTIE 10 — RAPPORTGENERATOR
# ============================================================================

class Rapport:
    """Genereert gestructureerd technisch rapport (engineering-dossier kwaliteit)."""

    BREEDTE = 82
    SCHEIDINGSLIJN = "─" * BREEDTE

    @classmethod
    def genereer(cls, invoer: Invoer, res: Resultaten) -> str:
        r = []
        r += cls._header()
        r += cls._systeemgegevens(invoer)
        r += cls._belasting(invoer, res)
        if invoer.bundel and invoer.bundel.totaal_kabels > 1:
            r += cls._bundelinfo(invoer.bundel, res)
        r += cls._correctiefactoren(res)
        if res.kabel:
            r += cls._kabelgegevens(res)
            r += cls._belastbaarheid(res)
            r += cls._spanningsval(invoer, res)
            r += cls._temperatuur(res)
            if invoer.kortsluitstroom_a > 0:
                r += cls._kortsluittoets(invoer, res)
        r += cls._eindoordeel(res)
        r += cls._formules_gebruikt(invoer)
        r += cls._footer()
        return "\n".join(r)

    @classmethod
    def _header(cls) -> List[str]:
        return [
            "",
            "═" * cls.BREEDTE,
            f"  KABELBEREKENINGSRAPPORT  |  v{VERSION}  |  {NORM_REFERENCE}",
            "═" * cls.BREEDTE,
            "",
        ]

    @classmethod
    def _systeemgegevens(cls, inv: Invoer) -> List[str]:
        return [
            "┌─ SYSTEEMGEGEVENS " + "─" * (cls.BREEDTE - 19),
            f"│  Systeemtype         : {inv.systeem.value}",
            f"│  Nominale spanning   : {inv.spanning_v} V",
            f"│  Frequentie          : {inv.frequentie_hz} Hz"
              if inv.systeem in (Systeemtype.AC_1FASE, Systeemtype.AC_3FASE)
              else f"│  Systeem             : DC",
            f"│  Leggingswijze       : {inv.legging.value}",
            f"│  Kabellengte         : {inv.lengte_m} m",
            f"│  Omgevingstemperatuur: {inv.omgevingstemp_c} °C"
              + (f"  (grondtemp.: {inv.grondtemp_c} °C)" if inv.is_grondkabel() else ""),
            f"│  Normstelsel         : {inv.normkeuze}",
            "│",
        ]

    @classmethod
    def _belasting(cls, inv: Invoer, res: Resultaten) -> List[str]:
        r = [
            "├─ BELASTINGSGEGEVENS " + "─" * (cls.BREEDTE - 22),
            f"│  Gevraagde stroom    : {res.I_gevraagd:.2f} A",
        ]
        if inv.vermogen_w:
            r.append(f"│  Opgegeven vermogen  : {inv.vermogen_w:.0f} W")
        if inv.systeem in (Systeemtype.AC_1FASE, Systeemtype.AC_3FASE):
            sin_phi = math.sqrt(max(0, 1 - inv.cos_phi**2))
            r.append(f"│  Arbeidsfactor cos φ : {inv.cos_phi:.3f}  (sin φ = {sin_phi:.3f})")
        r.append("│")
        return r

    @classmethod
    def _bundelinfo(cls, bundel: BundelConfig, res: Resultaten) -> List[str]:
        f_h = Correctiefactoren.f_horizontale_bundeling(bundel.n_horizontaal)
        f_v = Correctiefactoren.f_verticale_stapeling(bundel.n_verticaal)
        worst = res.bundel_positie_worst
        r = [
            "├─ BUNDELCONFIGURATIE " + "─" * (cls.BREEDTE - 22),
            f"│  Indeling            : {bundel.n_horizontaal} breed × {bundel.n_verticaal} hoog",
            f"│  Totaal kabels       : {bundel.totaal_kabels}",
            f"│  Hart-op-hart        : {bundel.hart_op_hart_mm:.0f} mm",
            f"│  Horizontale factor  : f_h = {f_h:.3f}  ({bundel.n_horizontaal} kabels/laag, tabel B.52.20)",
            f"│  Verticale factor    : f_v = {f_v:.3f}  ({bundel.n_verticaal} lagen, tabel B.52.21)",
            f"│  Gecomb. factor      : f_bundel = {f_h*f_v:.3f}",
            f"│  Maatgevende kabel   : positie ({worst[0]}, {worst[1]}) — centrum bundel",
            "│  ⚠  Berekening geldt voor de SLECHTST GEKOELDE kabel in het pakket.",
            "│",
        ]
        return r

    @classmethod
    def _correctiefactoren(cls, res: Resultaten) -> List[str]:
        return [
            "├─ CORRECTIEFACTOREN  (IEC 60364-5-52) " + "─" * (cls.BREEDTE - 40),
            f"│  f_T   (temperatuur) : {res.f_T:.4f}  ← √[(θ_max−θ_amb)/(θ_max−30)]",
            f"│  f_bnd (bundeling)   : {res.f_bundel:.4f}  ← f_h × f_v",
            f"│  f_gnd (bodem)       : {res.f_grond:.4f}  ← tabel B.52.16",
            f"│  f_TOTAAL            : {res.f_totaal:.4f}  ← product alle factoren",
            "│",
        ]

    @classmethod
    def _kabelgegevens(cls, res: Resultaten) -> List[str]:
        k = res.kabel
        return [
            "├─ GESELECTEERDE KABEL " + "─" * (cls.BREEDTE - 23),
            f"│  Type                : {k.naam}",
            f"│  Doorsnede           : {k.doorsnede_mm2} mm²",
            f"│  Geleider            : {k.geleider.value}",
            f"│  Isolatie            : {k.isolatie.value}  (max {ISOLATIE_EIGENSCHAPPEN[k.isolatie].max_temp_continu} °C)",
            f"│  Buitendiameter      : {k.buitendiameter:.1f} mm",
            f"│  R_AC @ 20 °C        : {k.R_ac_per_km_20C:.4f} Ω/km (per fase)",
            f"│  X   @ 50 Hz         : {k.X_ac_per_km:.4f} Ω/km (per fase)",
            "│",
        ]

    @classmethod
    def _belastbaarheid(cls, res: Resultaten) -> List[str]:
        marge_symb = "✓" if res.marge_stroom_pct >= 0 else "✗"
        return [
            "├─ BELASTBAARHEID " + "─" * (cls.BREEDTE - 18),
            f"│  I_z0 (referentie)   : {res.I_z0:.1f} A  (tabel, θ_amb=30°C)",
            f"│  I_z  (gecorrigeerd) : {res.I_z:.1f} A  = I_z0 × {res.f_totaal:.4f}",
            f"│  I_gevraagd          : {res.I_gevraagd:.2f} A",
            f"│  Veiligheidsmarge    : {marge_symb}  {res.marge_stroom_pct:+.1f}%",
            "│",
        ]

    @classmethod
    def _spanningsval(cls, inv: Invoer, res: Resultaten) -> List[str]:
        symb = "✓" if res.OK_spanning else "✗"
        return [
            "├─ SPANNINGSVAL " + "─" * (cls.BREEDTE - 16),
            f"│  ΔU (absoluut)       : {res.delta_U_v:.3f} V",
            f"│  ΔU (procent)        : {res.delta_U_pct:.3f}%",
            f"│  Eis                 : ≤ {inv.max_spanningsval_pct:.2f}%",
            f"│  Status              : {symb}  {'VOLDOET' if res.OK_spanning else 'OVERSCHREDEN'}",
            "│",
        ]

    @classmethod
    def _temperatuur(cls, res: Resultaten) -> List[str]:
        symb = "✓" if res.OK_temp else "⚠"
        marge = res.max_temp_c - res.geleider_temp_c
        return [
            "├─ TEMPERATUURVERHOGING  (vereenvoudigd model) " + "─" * (cls.BREEDTE - 47),
            f"│  I²R-verlies         : {res.I2R_verlies_W_per_m:.4f} W/m",
            f"│  Temperatuurstijging : {res.temp_stijging_K:.2f} K",
            f"│  Geleidertemperatuur : {res.geleider_temp_c:.1f} °C",
            f"│  Maximum toegestaan  : {res.max_temp_c:.0f} °C",
            f"│  Marge               : {symb}  {marge:.1f} K",
            "│  ℹ  Gebruik IEC 60287 voor nauwkeurig thermisch model.",
            "│",
        ]

    @classmethod
    def _kortsluittoets(cls, inv: Invoer, res: Resultaten) -> List[str]:
        symb = "✓" if res.OK_kortsluit else "✗"
        isolprop = ISOLATIE_EIGENSCHAPPEN[res.kabel.isolatie]
        k = K_WAARDEN.get((res.kabel.geleider, res.kabel.isolatie), "?")
        return [
            "├─ KORTSLUITVASTHEID  (IEC 60949) " + "─" * (cls.BREEDTE - 34),
            f"│  Kortsluitstroom     : {inv.kortsluitstroom_a:.0f} A",
            f"│  Kortsluitduur       : {inv.kortsluitduur_ms:.0f} ms",
            f"│  k-waarde            : {k}  ({res.kabel.geleider.value} {res.kabel.isolatie.value})",
            f"│  Min. doorsnede      : {res.doorsnede_min_kortsluit:.2f} mm²  = I_k·√t / k",
            f"│  Temperatuurstijging : {res.delta_T_kortsluit_K:.1f} K",
            f"│  Eindtemperatuur     : {res.eindtemp_kortsluit_c:.1f} °C",
            f"│  Max. toegestaan     : {isolprop.max_temp_kortsluit} °C",
            f"│  Status              : {symb}  {'VOLDOET' if res.OK_kortsluit else 'FAALT'}",
            "│",
        ]

    @classmethod
    def _eindoordeel(cls, res: Resultaten) -> List[str]:
        r = ["├─ EINDOORDEEL " + "─" * (cls.BREEDTE - 15)]
        if res.voldoet:
            r.append("│  ✓  ALLE CONTROLES VOLDOEN AAN NORM")
        else:
            r.append("│  ✗  CONTROLES GEFAALD — ZIE FOUTEN HIERONDER")

        if res.fouten:
            r.append("│")
            r.append("│  FOUTEN:")
            for f in res.fouten:
                r.append(f"│    ✗ {f}")

        if res.waarschuwingen:
            r.append("│")
            r.append("│  WAARSCHUWINGEN:")
            for w in res.waarschuwingen:
                r.append(f"│    ⚠ {w}")

        r.append("│")
        return r

    @classmethod
    def _formules_gebruikt(cls, inv: Invoer) -> List[str]:
        r = [
            "├─ GEBRUIKTE FORMULES " + "─" * (cls.BREEDTE - 22),
            "│",
            "│  1. Temperatuurcorrectie (IEC 60364-5-52 §523):",
            "│       f_T = √[(θ_max − θ_amb) / (θ_max − θ_ref)]",
            "│",
        ]
        if inv.systeem == Systeemtype.AC_1FASE:
            r += [
                "│  2. Spanningsval 1-fase AC:",
                "│       ΔU = 2 · I · L · (R·cosφ + X·sinφ)   [factor 2 voor retour!]",
                "│",
            ]
        elif inv.systeem == Systeemtype.AC_3FASE:
            r += [
                "│  2. Spanningsval 3-fase AC:",
                "│       ΔU = √3 · I · L · (R·cosφ + X·sinφ)",
                "│",
            ]
        elif inv.systeem == Systeemtype.DC_2DRAAD:
            r += [
                "│  2. Spanningsval DC 2-draad:",
                "│       ΔU = 2 · I · R_DC · L   [factor 2 voor heen + retour]",
                "│",
            ]
        r += [
            "│  3. I²R-verlies:",
            "│       P = I² · R  [W/m]",
            "│",
            "│  4. Kortsluit minimale doorsnede (IEC 60949):",
            "│       A_min = I_k · √t / k",
            "│       Adiabatische ΔT = (I_k² · t) / (k² · A²)",
            "│",
            "│  5. DC-weerstand:",
            "│       R_DC(T) = ρ_20 · [1 + α·(T−20)] · L / A",
            "│",
        ]
        return r

    @classmethod
    def _footer(cls) -> List[str]:
        return [
            "└" + "─" * cls.BREEDTE,
            f"  Kabelberekeningsprogramma v{VERSION}  |  {NORM_REFERENCE}",
            "═" * cls.BREEDTE,
            "",
        ]


# ============================================================================
# SECTIE 11 — INTERACTIEVE INVOER
# ============================================================================

def _kies(opties: list, prompt: str, default_idx: int = 0):
    """Hulpfunctie voor genummerde keuzelijst."""
    print(f"\n{prompt}")
    for i, o in enumerate(opties):
        marker = " (standaard)" if i == default_idx else ""
        print(f"  {i+1}. {o}{marker}")
    while True:
        inp = input(f"  Keuze [1-{len(opties)}] (Enter = {default_idx+1}): ").strip()
        if inp == "":
            return opties[default_idx]
        try:
            idx = int(inp) - 1
            if 0 <= idx < len(opties):
                return opties[idx]
        except ValueError:
            pass
        print("  Ongeldige invoer. Probeer opnieuw.")


def _getal(prompt: str, default: float, min_val: float = 0.0, max_val: float = 1e9) -> float:
    """Hulpfunctie voor getaltinvoer met validatie."""
    while True:
        inp = input(f"  {prompt} [standaard: {default}]: ").strip()
        if inp == "":
            return default
        try:
            val = float(inp.replace(",", "."))
            if min_val <= val <= max_val:
                return val
            print(f"  Waarde moet tussen {min_val} en {max_val} liggen.")
        except ValueError:
            print("  Ongeldige invoer. Voer een getal in.")


def interactieve_invoer() -> Optional[Invoer]:
    """Vraagt alle invoerparameters interactief op."""
    print("\n" + "═"*70)
    print("  KABELBEREKENINGSPROGRAMMA v3.0 — Invoer")
    print("═"*70)

    try:
        # Systeemtype
        stelsel_namen = [s.value for s in Systeemtype]
        stelsel_str = _kies(stelsel_namen, "Systeemtype:")
        systeem = next(s for s in Systeemtype if s.value == stelsel_str)

        # Spanning
        spanning = _getal("Nominale spanning (V)", 400, 1, 200000)

        # Belasting
        print("\n  Belasting via:")
        methode = _kies(["Stroom (A)", "Vermogen (W)"], "Belastingsinvoer:", 0)
        if "Stroom" in methode:
            stroom = _getal("Stroom (A)", 32, 0.1, 10000)
            vermogen = None
        else:
            vermogen = _getal("Vermogen (W)", 10000, 1, 1e8)
            stroom = 0.0

        # Arbeidsfactor
        cos_phi = 1.0
        if systeem in (Systeemtype.AC_1FASE, Systeemtype.AC_3FASE):
            cos_phi = _getal("Arbeidsfactor cos φ", 0.95, 0.1, 1.0)

        # Kabellengte
        lengte = _getal("Kabellengte (m)", 50, 0.1, 50000)

        # Leggingswijze
        legging_namen = [l.value for l in Leggingswijze]
        legging_str = _kies(legging_namen, "Leggingswijze:", 4)  # default = C
        legging = next(l for l in Leggingswijze if l.value == legging_str)

        # Geleider
        gel_namen = [g.value for g in Geleidermateriaal]
        gel_str = _kies(gel_namen, "Geleidermateriaal:", 0)
        geleider = next(g for g in Geleidermateriaal if g.value == gel_str)

        # Isolatie
        iso_namen = [i.value for i in [Isolatiemateriaal.PVC, Isolatiemateriaal.XLPE]]
        iso_str = _kies(iso_namen, "Isolatiemateriaal:", 0)
        isolatie = Isolatiemateriaal.PVC if iso_str == "PVC" else Isolatiemateriaal.XLPE

        # Omgeving
        omgevingstemp = _getal("Omgevingstemperatuur (°C)", 30, -30, 70)

        # Bundel
        bundel = None
        gebruik_bundel = _kies(["Enkele kabel", "Meerdere kabels (bundel)"],
                               "Aantal kabels:", 0)
        if "bundel" in gebruik_bundel.lower() or "meerdere" in gebruik_bundel.lower():
            n_h = int(_getal("Aantal kabels naast elkaar", 2, 1, 100))
            n_v = int(_getal("Aantal lagen hoog", 1, 1, 50))
            hoh  = _getal("Hart-op-hart afstand (mm)", 60, 1, 1000)
            bundel = BundelConfig(n_h, n_v, hoh)

        # Spanningsval-eis
        max_sv = _getal("Maximaal toegestane spanningsval (%)", 3.0, 0.1, 20.0)

        # Kortsluit
        kortsluit_str = _kies(["Geen kortsluittoets",
                                "Kortsluitstroom opgeven"],
                              "Kortsluittoets:", 0)
        I_k = 0.0
        t_k = 500.0
        if "kortsluit" in kortsluit_str.lower() and "opgeven" in kortsluit_str.lower():
            I_k = _getal("Kortsluitstroom (A)", 10000, 100, 200000)
            t_k = _getal("Kortsluitduur (ms)", 500, 1, 60000)

        # Grondparameters
        grondtemp = 20.0
        lambda_g  = 1.0
        if legging in (Leggingswijze.D1, Leggingswijze.D2):
            grondtemp = _getal("Grondtemperatuur (°C)", 20, 0, 40)
            lambda_g  = _getal("Bodemthermische weerstand (K·m/W)", 1.0, 0.3, 3.0)

        return Invoer(
            systeem=systeem,
            spanning_v=spanning,
            stroom_a=stroom,
            vermogen_w=vermogen,
            cos_phi=cos_phi,
            lengte_m=lengte,
            legging=legging,
            geleider=geleider,
            isolatie=isolatie,
            omgevingstemp_c=omgevingstemp,
            grondtemp_c=grondtemp,
            lambda_grond=lambda_g,
            bundel=bundel,
            max_spanningsval_pct=max_sv,
            kortsluitstroom_a=I_k,
            kortsluitduur_ms=t_k,
        )

    except KeyboardInterrupt:
        print("\n\n  Invoer afgebroken.")
        return None


# ============================================================================
# SECTIE 12 — PUBLIEKE API (voor gebruik als bibliotheek)
# ============================================================================

def bereken(invoer: Invoer) -> Resultaten:
    """
    Voert de volledige kabelberekening uit.

    Args:
        invoer: Volledig ingevuld Invoer-object

    Returns:
        Resultaten-object met alle berekeningen en controles.
    """
    ontwerper = KabelOntwerper(invoer)
    return ontwerper.bereken()


def rapport(invoer: Invoer, res: Resultaten) -> str:
    """
    Genereert technisch rapport als string.

    Args:
        invoer: Invoer-object
        res:    Resultaten-object (van bereken())

    Returns:
        Geformateerd rapport als string.
    """
    return Rapport.genereer(invoer, res)


# ============================================================================
# SECTIE 13 — MAIN / STARTPUNT
# ============================================================================

def main():
    """Interactief startpunt."""
    print("""
╔══════════════════════════════════════════════════════════════════════╗
║   KABELBEREKENINGSPROGRAMMA v3.0 — Professional Edition            ║
║   AC & DC  |  IEC 60364 / IEC 60287 / IEC 60949 / NEN 1010       ║
╚══════════════════════════════════════════════════════════════════════╝
    """)

    while True:
        print("\nMENU")
        print("  1. Nieuwe kabelberekening (interactief)")
        print("  2. Demonstratie voorbeelden (zie demo.py)")
        print("  0. Afsluiten")

        keuze = input("\nKeuze: ").strip()

        if keuze == "1":
            inv = interactieve_invoer()
            if inv:
                res = bereken(inv)
                print(rapport(inv, res))
                input("\nDruk Enter om verder te gaan...")

        elif keuze == "0":
            print("\nProgramma beëindigd. Tot ziens!")
            break
        else:
            print("Ongeldige keuze.")


if __name__ == "__main__":
    main()
