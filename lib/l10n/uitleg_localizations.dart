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

import 'app_localizations.dart';

/// Extension met alle vertalingen voor uitleg_screen.dart
extension UitlegLocalizations on AppLocalizations {
  // ── OVERZICHT ─────────────────────────────────────────────────────────────
  String get overzichtTitel => isNL ? 'Berekeningsvolgorde' : 'Calculation Sequence';
  String get overzichtValideer => isNL ? 'Valideer invoer' : 'Validate input';
  String get overzichtValideerSub => isNL ? 'U, I/P, L, temperatures' : 'U, I/P, L, temperatures';
  String get overzichtCF => isNL ? 'Correctiefactoren' : 'Correction Factors';
  String get overzichtCFSub => isNL
      ? 'f_T · f_bundel · f_grond [· M · f_harm] = f_totaal'
      : 'f_T · f_bundle · f_ground [· M · f_harm] = f_total';
  String get overzichtCyclisch => isNL ? 'Cyclische factor M' : 'Cyclic Factor M';
  String get overzichtCyclischSub => isNL
      ? 'M ≥ 1,0  —  grondkabels + dagprofiel  (NEN IEC 60583-1)'
      : 'M ≥ 1.0  —  buried cables + day profile  (NEN IEC 60583-1)';
  String get overzichtHarm => isNL ? 'Harmonischen f_harm' : 'Harmonics f_harm';
  String get overzichtHarmSub => isNL
      ? 'f_harm ∈ {0,86; 1,0}  —  3-fase 4/5-aderig  (NEN 1010 Bijl. 52.E.1)'
      : 'f_harm ∈ {0.86; 1.0}  —  3-phase 4/5-core  (NEN 1010 Ann. 52.E.1)';
  String get overzichtMinDoorsnede => isNL ? 'Min. doorsnede kortsluit' : 'Min. cross-section short-circuit';
  String get overzichtMinDoorsnedeFormule => 'A_min = (Ik/n)·√t / k';
  String get overzichtKabelkeuze => isNL ? 'Kabelkeuze' : 'Cable Selection';
  String get overzichtKabelkeuzeSub => isNL
      ? 'kleinste A waarbij I_z0·f_totaal ≥ I_design'
      : 'smallest A where I_z0·f_total ≥ I_design';
  String get overzichtSpanningsval => isNL ? 'Spanningsval' : 'Voltage Drop';
  String get overzichtSpanningsvalSub => isNL ? 'ΔU ≤ max. %' : 'ΔU ≤ max. %';
  String get overzichtTemp => isNL ? 'Temperatuurstijging' : 'Temperature Rise';
  String get overzichtTempSub => isNL ? 'I²R-verlies → geleidertemp' : 'I²R loss → conductor temp';
  String get overzichtKortsluit => isNL ? 'Kortsluittoets' : 'Short-circuit Check';
  String get overzichtKortsluitFormule => 'ΔT = (Ik²·t)/(k²·A²)';
  String get overzichtMaxLengte => isNL ? 'Max. leidinglengte' : 'Max. Cable Length';
  String get overzichtMaxLengteSub => isNL
      ? 'L ≤ L_max (kortsluitbeveiliging)'
      : 'L ≤ L_max (short-circuit protection)';
  String get overzichtEindoordeel => isNL ? 'Eindoordeel' : 'Final Assessment';
  String get overzichtEindoordeelSub => isNL
      ? 'Voldoet als alle stappen slagen'
      : 'Passes if all steps succeed';

  // ── STROOM BEPALEN ────────────────────────────────────────────────────────
  String get stroomTitel => isNL ? 'Stap 1 — Stroom bepalen' : 'Step 1 — Determine Current';
  String get stroomIntro => isNL
      ? 'De belastingsstroom I wordt bepaald op basis van de invoer:'
      : 'The load current I is determined from the input:';
  String get stroomAC1 => isNL
      ? 'AC 1-fase / 3-fase:  I = P / (U · cosφ)   [A]'
      : 'AC 1-phase / 3-phase:  I = P / (U · cosφ)   [A]';
  String get stroomAC1Sub => isNL
      ? 'Actief vermogen P in watt, spanning U in volt, vermogensfactor cosφ'
      : 'Active power P in watts, voltage U in volts, power factor cosφ';
  String get stroomDC => 'DC:                  I = P / U             [A]';
  String get stroomDCSub => isNL
      ? 'Bij DC geen cosφ; vermogensfactor = 1'
      : 'For DC no cosφ; power factor = 1';
  String get stroomDirect => isNL
      ? 'Direct invoer:       I = ingevoerde waarde [A]'
      : 'Direct input:        I = entered value [A]';
  String get stroomDirectSub => isNL
      ? 'Wanneer stroom direct wordt ingevoerd i.p.v. vermogen'
      : 'When current is entered directly instead of power';
  String get stroomParallel => isNL ? 'Parallel (AC):' : 'Parallel (AC):';
  String get stroomParallelFormule => isNL
      ? 'I per kabel = I_totaal / n   (n = aantal parallelle kabels)'
      : 'I per cable = I_total / n   (n = number of parallel cables)';
  String get stroomParallelSub => isNL
      ? 'Bij parallelle kabels neemt elke kabel I/n stroom. Alle verdere berekeningen gelden per kabel.'
      : 'With parallel cables each cable carries I/n. All further calculations apply per cable.';

  // ── CORRECTIEFACTOREN ─────────────────────────────────────────────────────
  String get cfTitel => isNL
      ? 'Stap 2 — Correctiefactoren  (IEC 60364-5-52)'
      : 'Step 2 — Correction Factors  (IEC 60364-5-52)';
  String get cfIntro => isNL
      ? 'De catalogus-waarden I_z0 gelden bij standaard omstandigheden (30 °C, enkelvoudig, zandgrond λ=1,0 K·m/W). Correctiefactoren passen dit aan voor de werkelijke situatie:'
      : 'The catalogue values I_z0 apply at standard conditions (30 °C, single cable, sandy soil λ=1.0 K·m/W). Correction factors adjust for the actual situation:';
  String get cfFormule => isNL
      ? 'I_z = I_z0 · f_T · f_bundel · f_grond   =   I_z0 · f_totaal'
      : 'I_z = I_z0 · f_T · f_bundle · f_ground   =   I_z0 · f_total';
  String get cfTempTitel => isNL
      ? 'Temperatuurcorrectiefactor  f_T  (§ 523.2)'
      : 'Temperature Correction Factor  f_T  (§ 523.2)';
  String get cfTempFormule =>
      'f_T = √[ (θ_max − θ_omg) / (θ_max − θ_ref) ]';
  String get cfTempSub => isNL
      ? 'θ_max = max. geleidertemperatuur (PVC 70°C, XLPE/EPR 90°C)  ·  θ_omg = omgevings- of grondtemperatuur  ·  θ_ref = 30°C'
      : 'θ_max = max. conductor temperature (PVC 70°C, XLPE/EPR 90°C)  ·  θ_amb = ambient or ground temperature  ·  θ_ref = 30°C';
  String get cfTempNote => isNL
      ? 'Let op: de formule is een wortelfunctie — NIET lineair! Bij θ_omg = 40°C (PVC): f_T = 0,866 (niet 0,857).'
      : 'Note: the formula is a square root function — NOT linear! At θ_amb = 40°C (PVC): f_T = 0.866 (not 0.857).';
  String get cfBundelTitel => isNL
      ? 'Bundelingsfactor  f_bundel  (Tabel B.52.20 / B.52.21)'
      : 'Grouping Factor  f_bundle  (Table B.52.20 / B.52.21)';
  String get cfBundelFormule =>
      'f_bundel = f_horizontaal · f_verticaal';
  String get cfBundelSub => isNL
      ? 'f_horizontaal: reductie voor n kabels naast elkaar  ·  f_verticaal: aanvullende reductie voor gestapelde lagen'
      : 'f_horizontal: reduction for n cables side by side  ·  f_vertical: additional reduction for stacked layers';
  String get cfGrondTitel => isNL
      ? 'Bodemweerstandsfactor  f_grond  (Tabel B.52.16, alleen D1/D2)'
      : 'Soil Resistance Factor  f_ground  (Table B.52.16, D1/D2 only)';
  String get cfGrondFormule => isNL
      ? 'f_grond = f(λ_grond)   (λ in K·m/W, referentie λ=1,0)'
      : 'f_ground = f(λ_soil)   (λ in K·m/W, reference λ=1.0)';
  String get cfGrondSub => isNL
      ? 'Droge grond (λ > 1) → f_grond < 1 (reductie)  ·  Natte grond (λ < 1) → f_grond > 1 (voordeel)'
      : 'Dry soil (λ > 1) → f_ground < 1 (reduction)  ·  Wet soil (λ < 1) → f_ground > 1 (benefit)';
  String get cfZonTitel => isNL
      ? 'Zonstralings-toeslag  (NEN 1010, alleen bovengronds)'
      : 'Solar Radiation Supplement  (NEN 1010, above-ground only)';
  String get cfZonFormule => isNL
      ? 'θ_eff = θ_omg + ΔT_zon   (typisch +15 K)'
      : 'θ_eff = θ_amb + ΔT_sun   (typically +15 K)';
  String get cfZonSub => isNL
      ? 'Verhoogt de effectieve omgevingstemperatuur vóór berekening van f_T'
      : 'Increases the effective ambient temperature before calculating f_T';

  // ── CYCLISCH ─────────────────────────────────────────────────────────────
  String get cyclischTitel => isNL
      ? 'Stap 2a — Cyclische belastingsfactor M  (NEN IEC 60583-1:2002)'
      : 'Step 2a — Cyclic Load Factor M  (NEN IEC 60583-1:2002)';
  String get cyclischIntro => isNL
      ? 'Grondkabels die niet continu volledig belast zijn, kunnen meer stroom dragen dan de statische tabelwaarde aangeeft. De cyclische factor M (≥ 1,0) verhoogt de toelaatbare stroom op basis van een 24-uurs dagbelastingsprofiel:'
      : 'Buried cables that are not continuously fully loaded can carry more current than the static table value indicates. The cyclic factor M (≥ 1.0) increases the permissible current based on a 24-hour daily load profile:';
  String get cyclischFormuleTitel => isNL
      ? 'Formule cyclische factor  (NEN IEC 60583-1:2002 §4)'
      : 'Cyclic factor formula  (NEN IEC 60583-1:2002 §4)';
  String get cyclischFormulaM =>
      'M = 1 / √[ Σᵢ₌₁⁶ Yᵢ · ΔθR(i)  +  μ · (1 − θR(6)) ]';
  String get cyclischFormuleSub => isNL
      ? 'Sommatie over de 6 uur na de piek  ·  Yᵢ = (I(piek−i)/I_max)²  ·  ΔθR(i) = θR(i−1) − θR(i)  ·  μ = gem. (I/I_max)² over 24 uur'
      : 'Summation over the 6 hours after peak  ·  Yᵢ = (I(peak−i)/I_max)²  ·  ΔθR(i) = θR(i−1) − θR(i)  ·  μ = avg. (I/I_max)² over 24 hours';
  String get cyclischTherTitel => isNL
      ? 'Thermische responsie θR(i)  (IEC 60287-2-1)'
      : 'Thermal response θR(i)  (IEC 60287-2-1)';
  String get cyclischTherFormule =>
      'θR(i) = [−Ei(−r²/4δt)] / [2·ln(4L/De)]';
  String get cyclischTherSub => isNL
      ? '−Ei = exponentieel integraal  ·  r = De/2 (kabelradius)  ·  δ = thermische diffusiviteit grond [m²/s]  ·  t = i × 3600 s  ·  L = legdiepte [m]  ·  De = buitendiameter [m]'
      : '−Ei = exponential integral  ·  r = De/2 (cable radius)  ·  δ = thermal diffusivity of soil [m²/s]  ·  t = i × 3600 s  ·  L = burial depth [m]  ·  De = outer diameter [m]';
  String get cyclischDiffTitel => isNL
      ? 'Thermische diffusiviteit δ  (uit ξ)'
      : 'Thermal Diffusivity δ  (from ξ)';
  String get cyclischColXi => isNL ? 'ξ (K·m/W)' : 'ξ (K·m/W)';
  String get cyclischColDelta => isNL ? 'δ (×10⁻⁶ m²/s)' : 'δ (×10⁻⁶ m²/s)';
  String get cyclischT4Titel => isNL
      ? 'Externe thermische weerstand T₄  (per kabelligging)'
      : 'External Thermal Resistance T₄  (per cable installation)';
  String get cyclischT4Aanliggend => isNL
      ? 'Aanliggend (touching):  T₄ = (ξ/2π) · ln(2L/De · (F^(2/(N−1))))'
      : 'Touching:  T₄ = (ξ/2π) · ln(2L/De · (F^(2/(N−1))))';
  String get cyclischT4AanliggendSub => isNL
      ? 'F = beeldfactor voor N kringen in lijn  ·  N = aantal kringen in de groep  ·  F = ∏d′k / ∏dk  (producten van beeld- en werkelijke afstanden)'
      : 'F = image factor for N circuits in line  ·  N = number of circuits in group  ·  F = ∏d′k / ∏dk  (products of image and actual distances)';
  String get cyclischT4Gespreid => isNL
      ? 'Gespreid (spaced):  T₄ = (ξ/2π) · ln(2L/De) + (ξ(N−1)/2π) · ln(df/dp1)'
      : 'Spaced:  T₄ = (ξ/2π) · ln(2L/De) + (ξ(N−1)/2π) · ln(df/dp1)';
  String get cyclischT4GespreidSub => isNL
      ? 'dp1 = hart-op-hart afstand [m]  ·  df = fictieve diameter = 4L/F^(1/(N−1))'
      : 'dp1 = centre-to-centre distance [m]  ·  df = fictitious diameter = 4L/F^(1/(N−1))';
  String get cyclischSlot => isNL
      ? 'M > 1,0 betekent dat de kabel meer stroom kan dragen dan de tabelwaarde. Bij volledig continue belasting (profiel = 1,0) is M = 1,0. De factor wordt per kandidaat-kabel opnieuw berekend omdat M afhankelijk is van de kabeldiameter en het Joule-verlies W = I²·R.'
      : 'M > 1.0 means the cable can carry more current than the table value. With fully continuous loading (profile = 1.0) M = 1.0. The factor is recalculated per candidate cable because M depends on the cable diameter and the Joule loss W = I²·R.';

  // ── HARMONISCHEN ─────────────────────────────────────────────────────────
  String get harmTitel => isNL
      ? 'Stap 2b — Hogere harmonischen  (NEN 1010 Bijlage 52.E.1)'
      : 'Step 2b — Higher Harmonics  (NEN 1010 Annex 52.E.1)';
  String get harmIntro => isNL
      ? 'Bij belastingen met hoge 3e harmonische (computers, frequentieregelaars, UPS) draagt de nulpuntsgeleider (N) de som van alle fasige harmonische stromen. Dit verhoogt de warmteproductie in de kabel. NEN 1010 Bijlage 52.E.1 (= IEC 60364-5-52 Tabel E.52.1) geeft correctiefactoren voor 4- of 5-aderige kabels met 4 belaste aders (3L + N):'
      : 'For loads with high 3rd harmonic (computers, frequency converters, UPS) the neutral conductor (N) carries the sum of all harmonic currents. This increases heat production in the cable. NEN 1010 Annex 52.E.1 (= IEC 60364-5-52 Table E.52.1) gives correction factors for 4- or 5-core cables with 4 loaded cores (3L + N):';
  String get harmNulTitel => isNL
      ? 'Nulpuntsstroom bij dominante 3e harmonische:'
      : 'Neutral current with dominant 3rd harmonic:';
  String get harmNulFormule => 'I_N = 3 · h₃ · I_fase';
  String get harmNulSub => isNL
      ? 'h₃ = 3e harmonische als fractie van de fasestroom  ·  I_N is de stroom in de nulpuntsgeleider (3× de harmonische component)'
      : 'h₃ = 3rd harmonic as fraction of phase current  ·  I_N is the current in the neutral conductor (3× the harmonic component)';
  String get harmTabelTitel => isNL
      ? 'Tabel E.52.1 — correctiefactoren:'
      : 'Table E.52.1 — correction factors:';
  String get harmColH3 => isNL ? 'h₃ (% van I_fase)' : 'h₃ (% of I_phase)';
  String get harmColGrondslag => isNL ? 'Grondslag' : 'Basis';
  String get harmCol0_15 => '0 – 15 %';
  String get harmColFasestroom => isNL ? 'fasestroom' : 'phase current';
  String get harmColNulstroom => isNL ? 'nulpuntsstroom' : 'neutral current';
  String get harmKeuzeFormule =>
      'I_z = I_z0 · f_base · f_harm   ≥   I_design';
  String get harmKeuzeSub => isNL
      ? 'I_design = I_fase  bij h₃ ≤ 33%  ·  I_design = I_N  bij h₃ > 33%'
      : 'I_design = I_phase  at h₃ ≤ 33%  ·  I_design = I_N  at h₃ > 33%';
  String get harmZone1 => isNL
      ? 'h₃ = 15–33%:\nKabel heeft 14% minder capaciteit (f=0,86), maar fasestroom blijft maatgevend'
      : 'h₃ = 15–33%:\nCable has 14% less capacity (f=0.86), but phase current remains governing';
  String get harmZone2 => isNL
      ? 'h₃ = 33–45%:\nNulpuntsstroom is maatgevend én capaciteitsreductie van 14%'
      : 'h₃ = 33–45%:\nNeutral current is governing AND 14% capacity reduction';
  String get harmZone3 => isNL
      ? 'h₃ > 45%:\nNulpuntsstroom maatgevend; geen extra reductie meer (N-geleider limiteert)'
      : 'h₃ > 45%:\nNeutral current governing; no additional reduction (N-conductor limits)';
  String get harmToepassingsgebied => isNL
      ? 'Toepassingsgebied: uitsluitend AC 3-fase met 4- of 5-aderige kabel (3L + N). Bij DC, 1-fase of 3-aderige kabel is geen nulpuntsgeleider aanwezig en is deze correctie niet van toepassing.'
      : 'Application: only AC 3-phase with 4- or 5-core cable (3L + N). For DC, 1-phase or 3-core cable there is no neutral conductor and this correction does not apply.';

  // ── MIN KORTSLUIT ────────────────────────────────────────────────────────
  String get ksMinTitel => isNL
      ? 'Stap 3 — Minimale doorsnede vanuit kortsluit  (IEC 60949)'
      : 'Step 3 — Minimum Cross-section from Short-circuit  (IEC 60949)';
  String get ksMinIntro => isNL
      ? 'Als een kortsluitstroom opgegeven is, bepaalt de adiabatische kortsluitformule een ondergrens voor de doorsnede:'
      : 'If a short-circuit current is specified, the adiabatic short-circuit formula determines a lower limit for the cross-section:';
  String get ksMinFormule => 'A_min = (Ik/n) · √t_s / k   [mm²]';
  String get ksMinSub => isNL
      ? 'Ik = kortsluitstroom [A]  ·  n = parallelle kabels  ·  t_s = kortsluitduur [s]  ·  k = materiaalconstante'
      : 'Ik = short-circuit current [A]  ·  n = parallel cables  ·  t_s = short-circuit duration [s]  ·  k = material constant';
  String get ksMinKWaarden => isNL ? 'k-waarden (IEC 60949):' : 'k values (IEC 60949):';
  String get ksMinColGeleider => isNL ? 'Geleider' : 'Conductor';
  String get ksMinColIsolatie => isNL ? 'Isolatie' : 'Insulation';
  String get ksMinSlot => isNL
      ? 'De geselecteerde kabel moet A ≥ A_min hebben. Anders wordt de kortsluittoets gefaald (stap 7).'
      : 'The selected cable must have A ≥ A_min. Otherwise the short-circuit test fails (step 7).';

  // ── KABELKEUZE ────────────────────────────────────────────────────────────
  String get kabelkeuzeTitel => isNL ? 'Stap 4 — Kabelkeuze uit catalogus' : 'Step 4 — Cable Selection from Catalogue';
  String get kabelkeuzeIntro => isNL
      ? 'De app zoekt de kleinste standaarddoorsnede die aan alle eisen voldoet. De catalogus bevat waarden per IEC 60364-5-52 Tabel B.52.4/B.52.5.'
      : 'The app finds the smallest standard cross-section that meets all requirements. The catalogue contains values per IEC 60364-5-52 Table B.52.4/B.52.5.';
  String get kabelkeuzeFormule => isNL
      ? 'I_z = I_z0 · f_totaal   ≥   I / n'
      : 'I_z = I_z0 · f_total   ≥   I / n';
  String get kabelkeuzeSub => isNL
      ? 'I_z0 = cataloguswaarde bij 30°C, enkelvoudig  ·  Methode C (in buis/wand) of E (vrije lucht, 1D) afhankelijk van leggingswijze'
      : 'I_z0 = catalogue value at 30°C, single cable  ·  Method C (in conduit/wall) or E (free air, 1D) depending on installation method';
  String get kabelkeuzeAutomatisch => isNL ? 'Automatisch:' : 'Automatic:';
  String get kabelkeuzeAutomatischSub => isNL
      ? 'Itereer over doorsnedes oplopend; neem eerste die voldoet'
      : 'Iterate over cross-sections ascending; take first that passes';
  String get kabelkeuzeGeforceerd => isNL ? 'Geforceerd:' : 'Forced:';
  String get kabelkeuzeGeforceerrdSub => isNL
      ? 'Gebruik opgegeven doorsnede; toets alle criteria'
      : 'Use specified cross-section; test all criteria';
  String get kabelkeuzeSingel => isNL ? '3-fase singel:' : '3-phase single:';
  String get kabelkeuzeSingelSub => isNL
      ? 'Gebruik I_zC3 / I_zE3 (3 belaste aders i.p.v. 2)'
      : 'Use I_zC3 / I_zE3 (3 loaded cores instead of 2)';
  String get kabelkeuzeKortsluitSub => isNL
      ? 'Doorsnede uit stap 3 (kortsluit-minimum) geldt als extra ondergrens: kabels die hier niet aan voldoen worden overgeslagen.'
      : 'Cross-section from step 3 (short-circuit minimum) applies as extra lower limit: cables that do not meet this are skipped.';

  // ── CATALOGUS WAARDEN ────────────────────────────────────────────────────
  String get catalogusTitel => isNL
      ? 'Kabelcatalogus — herkomst van R_ac, I_z en ⌀'
      : 'Cable Catalogue — Origin of R_ac, I_z and ⌀';
  String get catalogusIntro => isNL
      ? 'De catalogus bevat voor elke combinatie van geleider, isolatie, doorsnede en adertal vier elektrische grootheden. Hieronder staat hoe ze bepaald zijn.'
      : 'The catalogue contains four electrical quantities for each combination of conductor, insulation, cross-section and core count. Below is how they are determined.';
  String get catalogusRacTitel => isNL
      ? 'R_AC 20°C  —  wisselstroomweerstand  (IEC 60228)'
      : 'R_AC 20°C  —  AC resistance  (IEC 60228)';
  String get catalogusRacIntro => isNL
      ? 'Startpunt is de gelijkstroomweerstand bij 20 °C uit IEC 60228:'
      : 'Starting point is the DC resistance at 20 °C from IEC 60228:';
  String get catalogusRacFormule => 'R_DC = ρ₂₀ / A   [Ω/km]';
  String get catalogusRacSub => isNL
      ? 'ρ₂₀(Cu) = 17,241 mΩ·mm²/m  ·  ρ₂₀(Al) = 28,264 mΩ·mm²/m  ·  A = doorsnede [mm²]'
      : 'ρ₂₀(Cu) = 17.241 mΩ·mm²/m  ·  ρ₂₀(Al) = 28.264 mΩ·mm²/m  ·  A = cross-section [mm²]';
  String get catalogusRacSkin => isNL
      ? 'Voor wisselstroom wordt een skin-effectcorrectie toegepast:'
      : 'For AC a skin effect correction is applied:';
  String get catalogusRacSkinFormule => 'R_AC = R_DC · k_skin';
  String get catalogusRacSkinSub => isNL
      ? 'k_skin ≈ 1,00 voor A ≤ 50 mm²  ·  tot k_skin ≈ 1,05 bij 400 mm²  (verwaarloosbaar bij kleine doorsneden; relevant bij grote kabels)'
      : 'k_skin ≈ 1.00 for A ≤ 50 mm²  ·  up to k_skin ≈ 1.05 at 400 mm²  (negligible for small cross-sections; relevant for large cables)';
  String get catalogusRacSlot => isNL
      ? 'De R_AC waarden in de catalogus zijn typische fabriekswaarden en komen overeen met IEC 60228 / IEC 60502.'
      : 'The R_AC values in the catalogue are typical manufacturer values and correspond to IEC 60228 / IEC 60502.';
  String get catalogusIzTitel => isNL
      ? 'I_z C en I_z E  —  toelaatbare stromen  (IEC 60364-5-52)'
      : 'I_z C and I_z E  —  permissible currents  (IEC 60364-5-52)';
  String get catalogusIzIntro => isNL
      ? 'De catalogus gebruikt rechtstreeks de tabelwaarden uit IEC 60364-5-52 Tabel B.52.4 (PVC) en B.52.5 (XLPE), voor referentieomstandigheden θ_amb = 30 °C, enkelvoudig, geleider op maximale bedrijfstemperatuur:'
      : 'The catalogue uses directly the table values from IEC 60364-5-52 Table B.52.4 (PVC) and B.52.5 (XLPE), for reference conditions θ_amb = 30 °C, single, conductor at maximum operating temperature:';
  String get catalogusIzSingelBonus => isNL
      ? 'Bij 1-aderige kabels zonder naburige bron (enkelvoudig DC/1-fase) geldt een 5 % bonus: I_z = I_z(2-aderig) × 1,05.'
      : 'For single-core cables without adjacent source (single DC/1-phase) a 5% bonus applies: I_z = I_z(2-core) × 1.05.';
  String get catalogusDiamTitel => isNL
      ? 'Buitendiameter  —  geometrie  (IEC 60228 / fabrieksdata)'
      : 'Outer Diameter  —  geometry  (IEC 60228 / factory data)';
  String get catalogusDiamIntro => isNL
      ? 'Als basiswaarde geldt de typische buitendiameter van een 3-aderige kabel bij de betreffende doorsnede (fabrieksdata / IEC 60228). Voor andere ader-aantallen wordt een schalingsfactor toegepast:'
      : 'The base value is the typical outer diameter of a 3-core cable for the relevant cross-section (manufacturer data / IEC 60228). For other core counts a scaling factor is applied:';
  String get catalogusDiamColAders => isNL ? 'Aders' : 'Cores';
  String get catalogusDiamColFactor => isNL ? 'Factor t.o.v. 3-aderig' : 'Factor vs. 3-core';
  String get catalogusDiamColToel => isNL ? 'Toelichting' : 'Note';
  String get catalogusDiamSlot => isNL
      ? '⌀ = ⌀_3-aderig × factor   (+5 % voor XLPE t.o.v. PVC)'
      : '⌀ = ⌀_3-core × factor   (+5% for XLPE vs. PVC)';
  String get catalogusDiamSlotSub => isNL
      ? 'XLPE-isolatie is iets dikker dan PVC bij dezelfde doorsnede; vandaar een extra toeslag van 5 %'
      : 'XLPE insulation is slightly thicker than PVC at the same cross-section; hence an extra 5% supplement';
  String get catalogusDiamNote => isNL
      ? 'De buitendiameter is een benadering op basis van typische fabriekswaarden. Voor exacte bundelafmetingen altijd het fabrikants-datablad raadplegen.'
      : 'The outer diameter is an approximation based on typical manufacturer values. Always consult the manufacturer data sheet for exact bundle dimensions.';

  // ── THERMISCHE KERN ──────────────────────────────────────────────────────
  String get thermTitel => isNL
      ? 'Thermische kern — doorsnede vanuit IEC 60287'
      : 'Thermal Core — Cross-section from IEC 60287';
  String get thermIntro => isNL
      ? 'De IEC 60364-cataloguswaarden zijn afgeleid van de volledige IEC 60287-1-1 stroombelastingsformule. Hieronder staat de theoretische onderbouwing van de doorsnede-keuze.'
      : 'The IEC 60364 catalogue values are derived from the full IEC 60287-1-1 current carrying capacity formula. Below is the theoretical basis for the cross-section selection.';
  String get thermStroom1Titel => isNL
      ? '1  —  Toelaatbare stroom  (IEC 60287-1-1, vergelijking 1.1)'
      : '1  —  Permissible Current  (IEC 60287-1-1, equation 1.1)';
  String get thermStroom1Intro => isNL
      ? 'De continue toelaatbare stroom volgt direct uit de warmtebalans: het opgewekte verliesvermogen moet volledig worden afgevoerd via de thermische weerstanden T1–T4:'
      : 'The continuous permissible current follows directly from the heat balance: the generated loss power must be fully dissipated via the thermal resistances T1–T4:';
  String get thermFormule1 =>
      'I = √[ Δθ / (R_ac · (T₁ + T₂ + T₃ + T₄)) ]   [A]';
  String get thermFormule1Sub => isNL
      ? 'Δθ = θ_max − θ_amb  ·  R_ac = wisselstroomweerstand per meter [Ω/m]  ·  T₁–T₄ = thermische weerstanden [K·m/W]'
      : 'Δθ = θ_max − θ_amb  ·  R_ac = AC resistance per metre [Ω/m]  ·  T₁–T₄ = thermal resistances [K·m/W]';
  String get thermTVereenv => isNL
      ? 'Voor enkelvoudige kabels zonder bewapening geldt T₂ = T₃ = 0. De formule vereenvoudigt dan tot I = √(Δθ / (R_ac · (T₁ + T₄))).'
      : 'For single cables without armour T₂ = T₃ = 0. The formula then simplifies to I = √(Δθ / (R_ac · (T₁ + T₄))).';
  String get thermAC2Titel => isNL
      ? '2  —  AC-weerstand  (IEC 60287-1-1)'
      : '2  —  AC Resistance  (IEC 60287-1-1)';
  String get thermAC2Intro => isNL
      ? 'De wisselstroomweerstand is hoger dan de gelijkstroomweerstand door het skin-effect (ys) en het nabijheidseffect (yp):'
      : 'The AC resistance is higher than the DC resistance due to the skin effect (ys) and proximity effect (yp):';
  String get thermAC2Formule =>
      'R_ac = R_20 · [1 + α·(θ − 20)] · (1 + ys + yp)   [Ω/m]';
  String get thermAC2Sub => isNL
      ? 'R_20 = DC-weerstand bij 20°C [Ω/m]  ·  α = temperatuurcoëfficiënt  ·  ys = skin-effectfactor  ·  yp = nabijheidseffectfactor'
      : 'R_20 = DC resistance at 20°C [Ω/m]  ·  α = temperature coefficient  ·  ys = skin effect factor  ·  yp = proximity effect factor';
  String get thermSkinTitel => isNL
      ? 'Skin-effectfactor  ys  (IEC 60287-1-1 §2.1.2)'
      : 'Skin Effect Factor  ys  (IEC 60287-1-1 §2.1.2)';
  String get thermSkinSub => isNL
      ? 'Verwaarloosbaar voor A ≤ 50 mm² (xs² < 2,8 bij 50 Hz)'
      : 'Negligible for A ≤ 50 mm² (xs² < 2.8 at 50 Hz)';
  String get thermNabijTitel => isNL
      ? 'Nabijheidseffectfactor  yp  (IEC 60287-1-1 §2.1.3, 3-fase)'
      : 'Proximity Effect Factor  yp  (IEC 60287-1-1 §2.1.3, 3-phase)';
  String get thermNabijSub => isNL
      ? 'dc = geleidersdiameter [m]  ·  s = hart-op-hart afstand geleiders [m]  ·  Alleen van belang bij grote doorsneden (≥ 185 mm²)'
      : 'dc = conductor diameter [m]  ·  s = centre-to-centre distance conductors [m]  ·  Only relevant for large cross-sections (≥ 185 mm²)';
  String get thermT43Titel => isNL
      ? '3  —  T₄: thermische weerstand naar omgeving  (IEC 60287-2-1)'
      : '3  —  T₄: Thermal Resistance to Environment  (IEC 60287-2-1)';
  String get thermT4Grond => isNL
      ? 'In de grond (D1/D2  —  IEC 60287-2-1 §2.2.1):'
      : 'In the ground (D1/D2  —  IEC 60287-2-1 §2.2.1):';
  String get thermT4GrondFormule => 'T₄ = (ρs / 2π) · ln(4L / De)   [K·m/W]';
  String get thermT4GrondSub => isNL
      ? 'Benadering geldig voor L >> De/2  ·  ρs = thermische weerstand grond [K·m/W]  ·  L = diepte tot kabelhart [m]  ·  De = buitendiameter kabel [m]'
      : 'Approximation valid for L >> De/2  ·  ρs = thermal resistance soil [K·m/W]  ·  L = depth to cable centre [m]  ·  De = outer diameter cable [m]';
  String get thermT4Lucht => isNL
      ? 'In de lucht (methode E  —  vrije convectie):'
      : 'In air (method E  —  free convection):';
  String get thermT4LuchtFormule => 'T₄ = 1 / (π · De · h_conv)   [K·m/W]';
  String get thermT4LuchtSub => isNL
      ? 'h_conv ≈ 10 W/(m²·K) voor horizontale kabel in stilstaande lucht  ·  De = buitendiameter [m]'
      : 'h_conv ≈ 10 W/(m²·K) for horizontal cable in still air  ·  De = outer diameter [m]';
  String get thermT4Note => isNL
      ? 'De app gebruikt deze T₄-formules in de indicatieve temperatuurberekening (stap 6). De catalogus-I_z waarden zijn echter direct afgelezen uit IEC 60364-5-52 en zijn dus niet self-consistent met de vereenvoudigde T₁-formule.'
      : 'The app uses these T₄ formulas in the indicative temperature calculation (step 6). However, the catalogue I_z values are directly read from IEC 60364-5-52 and are therefore not self-consistent with the simplified T₁ formula.';
  String get thermA4Titel => isNL
      ? '4  —  Verband met de geleider-doorsnede A'
      : '4  —  Relationship with Conductor Cross-section A';
  String get thermT1Formule => 'T₁ = (ρi / 2π) · ln(1 + 2t / dc)   [K·m/W]';
  String get thermT1Sub => isNL
      ? 'ρi = thermische weerstand isolatie [K·m/W]  ·  t = isolatiedikte [m]  ·  dc = geleidersdiameter [m]'
      : 'ρi = thermal resistance insulation [K·m/W]  ·  t = insulation thickness [m]  ·  dc = conductor diameter [m]';
  String get thermA4Uitleg => isNL
      ? 'Grotere doorsnede → grotere dc → kleinere T₁ → hogere toelaatbare stroom. Tegelijk stijgt R_ac met A (dunnere geleider = hogere weerstand). Het optimum volgt uit de stroomformule:'
      : 'Larger cross-section → larger dc → smaller T₁ → higher permissible current. At the same time R_ac increases with A (thinner conductor = higher resistance). The optimum follows from the current formula:';
  String get thermA4Formule => 'I ∝ √(1 / (R_ac(A) · (T₁(A) + T₄)))';
  String get thermA4Slot => isNL
      ? 'Beide R_ac en T₁ dalen bij groter A; I stijgt niet lineair. Vandaar de niet-lineaire doorsnede-stroom relatie in de catalogus.'
      : 'Both R_ac and T₁ decrease with larger A; I does not increase linearly. Hence the non-linear cross-section-current relationship in the catalogue.';
  String get thermNote => isNL
      ? 'De minimaal benodigde doorsnede voor een gevraagde stroom I wordt in de app bepaald door iteratief de catalogus te doorzoeken (stap 4). De volledige IEC 60287 berekening (inclusief T₁–T₃ en exacte ys/yp) is voorbehouden aan gespecialiseerde kabeldimensioneringssoftware.'
      : 'The minimum required cross-section for a requested current I is determined in the app by iteratively searching the catalogue (step 4). The full IEC 60287 calculation (including T₁–T₃ and exact ys/yp) is reserved for specialised cable dimensioning software.';

  // ── SPANNINGSVAL ─────────────────────────────────────────────────────────
  String get svTitel => isNL
      ? 'Stap 5 — Spanningsval  (IEC 60364-5-52 §525)'
      : 'Step 5 — Voltage Drop  (IEC 60364-5-52 §525)';
  String get svIntro => isNL
      ? 'De spanningsval wordt berekend over de volledige kabellengte, rekening houdend met weerstand en reactantie bij bedrijfstemperatuur:'
      : 'The voltage drop is calculated over the full cable length, taking into account resistance and reactance at operating temperature:';
  String get svParallel => isNL
      ? 'Bij parallelle kabels: I per kabel = I/n. De spanningsval is gelijk voor alle parallelle kabels (aanname: gelijke impedantie en lengte).'
      : 'For parallel cables: I per cable = I/n. The voltage drop is equal for all parallel cables (assumption: equal impedance and length).';

  // ── TEMPERATUURSTIJGING ──────────────────────────────────────────────────
  String get tempStijgingTitel => isNL
      ? 'Stap 6 — Temperatuurstijging  (IEC 60287 vereenvoudigd)'
      : 'Step 6 — Temperature Rise  (IEC 60287 simplified)';
  String get tempStijgingIntro => isNL
      ? 'Het I²R-verlies verhoogt de geleidertemperatuur. De berekening is een vereenvoudiging van IEC 60287:'
      : 'The I²R loss increases the conductor temperature. The calculation is a simplification of IEC 60287:';
  String get tempStijgingFormuleVerlies => 'P = I² · R_DC(T_max)   [W/m]';
  String get tempStijgingFormuleVerliesSub => isNL
      ? 'Verliesvermogen per meter bij max. bedrijfstemperatuur'
      : 'Loss power per metre at max. operating temperature';
  String get tempStijgingBovengronds => isNL ? 'Bovengronds (vrije convectie):' : 'Above ground (free convection):';
  String get tempStijgingBovengrondsSub => isNL
      ? 'h_conv ≈ 10 W/(m²·K)  ·  D = buitendiameter kabel [m]'
      : 'h_conv ≈ 10 W/(m²·K)  ·  D = outer diameter cable [m]';
  String get tempStijgingGrond => isNL ? 'In de grond (IEC 60287-2-1):' : 'In the ground (IEC 60287-2-1):';
  String get tempStijgingGrondSub => isNL
      ? 'u = 2 · diepte  ·  D = buitendiameter  ·  diepte standaard 0,70 m'
      : 'u = 2 · depth  ·  D = outer diameter  ·  standard depth 0.70 m';
  String get tempStijgingGeleider => isNL
      ? 'Geleidertemperatuur:\nT_gel = θ_omg + ΔT  ≤  T_max isolatie'
      : 'Conductor temperature:\nT_cond = θ_amb + ΔT  ≤  T_max insulation';
  String get tempStijgingNote => isNL
      ? 'Dit is een indicatief thermisch model. Voor nauwkeurige grondberekeningen gebruik IEC 60287 volledig.'
      : 'This is an indicative thermal model. For accurate ground calculations use IEC 60287 in full.';

  // ── KORTSLUIT TOETS ──────────────────────────────────────────────────────
  String get ksToetsTitel => isNL
      ? 'Stap 7 — Kortsluittoets  (IEC 60949)'
      : 'Step 7 — Short-circuit Check  (IEC 60949)';
  String get ksToetsIntro => isNL
      ? 'Bij een kortsluit stijgt de geleidertemperatuur adiabatisch (geen warmteafvoer aangenomen tijdens de korte duur):'
      : 'During a short-circuit the conductor temperature rises adiabatically (no heat dissipation assumed during the short duration):';
  String get ksToetsFormule =>
      'ΔT_ks = (Ik²/n² · t_s) / (k² · A²)   [K]';
  String get ksToetsSub => isNL
      ? 'Ik/n = kortsluitstroom per kabel  ·  t_s = kortsluitduur [s]  ·  k = materiaalconstante (zie stap 3)  ·  A = doorsnede [mm²]'
      : 'Ik/n = short-circuit current per cable  ·  t_s = short-circuit duration [s]  ·  k = material constant (see step 3)  ·  A = cross-section [mm²]';
  String get ksToetsEind => 'T_eind = T_max + ΔT_ks   ≤   T_max,kortsluit';
  String get ksToetsParallel => isNL
      ? 'Bij parallelle kabels deelt elk kabel de kortsluitstroom: Ik per kabel = Ik_totaal / n.'
      : 'For parallel cables each cable shares the short-circuit current: Ik per cable = Ik_total / n.';

  // ── MAX. LEIDINGLENGTE ────────────────────────────────────────────────────
  String get maxLengteTitel => isNL
      ? 'Stap 7b — Max. leidinglengte (kortsluitbeveiliging)'
      : 'Step 7b — Max. Cable Length (short-circuit protection)';
  String get maxLengteIntro => isNL
      ? 'Om zeker te zijn dat een kortsluit aan het kabeluiteinde de beveiliging '
        'nog betrouwbaar activeert, moet de kortsluitstroom aan het einde van de '
        'leiding groter zijn dan de minimale activeringsstroom I_a van de '
        'beveiliging. Dit geeft een maximale leidinglengte L_max.'
      : 'To ensure that a short circuit at the cable end still reliably trips the '
        'protection device, the fault current at the end of the cable must exceed '
        'the minimum trip current I_a. This yields a maximum cable length L_max.';
  String get maxLengteSpanning => isNL
      ? 'Fase-naar-nul spanning U_c (maatgevend voor kortsluitstroom):'
      : 'Phase-to-neutral voltage U_c (governing for fault current):';
  String get maxLengteLusweerstand => isNL
      ? 'Lusweerststand per meter (bij maximale bedrijfstemperatuur):'
      : 'Loop resistance per metre (at maximum operating temperature):';
  String get maxLengteFormuleTitel => isNL
      ? 'Berekening L_max'
      : 'Calculation of L_max';
  String get maxLengteFormulaZonderIk =>
      'L_max = U_c / (I_a · R_lus/m)';
  String get maxLengteFormulaZonderIkSub => isNL
      ? 'Zonder bekende bronimpedantie (I_k onbekend): maximaal conservatief'
      : 'Without known source impedance (I_k unknown): maximally conservative';
  String get maxLengteFormulaMetIk =>
      'L_max = U_c · (I_k − I_a) / (I_k · I_a · R_lus/m)';
  String get maxLengteFormulaMetIkSub => isNL
      ? 'Met bekende kortsluitstroom I_k aan het begin van de leiding'
      : 'With known short-circuit current I_k at the start of the cable';
  String get maxLengteFormulaIkEind =>
      'I_k,eind = U_c / (U_c/I_k + R_lus/m · L)';
  String get maxLengteFormulaIkEindSub => isNL
      ? 'Kortsluitstroom aan het uiteinde bij de werkelijke kabellengte L'
      : 'Fault current at the end at the actual cable length L';
  String get maxLengteLusFormule =>
      'R_lus/m = 2 · ρ(T_max) / (A · n)   [Ω/m]';
  String get maxLengteLusFormuleSub => isNL
      ? 'ρ(T_max) = soortelijke weerstand bij maximale bedrijfstemperatuur  ·  '
        'A = doorsnede [mm²]  ·  n = parallelle kabels  ·  '
        'factor 2 = heen- + retourgeleider'
      : 'ρ(T_max) = resistivity at maximum operating temperature  ·  '
        'A = cross-section [mm²]  ·  n = parallel cables  ·  '
        'factor 2 = outgoing + return conductor';
  String get maxLengteIaLabel => isNL
      ? 'Minimale activeringsstroom I_a:'
      : 'Minimum trip current I_a:';
  String get maxLengteIaValues => isNL
      ? 'MCB type B: I_a = 5 × In  ·  Type C: I_a = 10 × In  ·  '
        'Type D: I_a = 20 × In  ·  Handmatig: I_a direct opgeven'
      : 'MCB type B: I_a = 5 × In  ·  Type C: I_a = 10 × In  ·  '
        'Type D: I_a = 20 × In  ·  Manual: enter I_a directly';
  String get maxLengteGgTitel => isNL
      ? 'gG patroon — minimale uitschakelstroom I_a (A) per IEC 60269'
      : 'gG fuse — minimum trip current I_a (A) per IEC 60269';
  String get maxLengteGgIntro => isNL
      ? 'De waarden zijn de minimale stromen waarbij de smeltzekering binnen de '
        'opgegeven tijd zeker doorsmelt (conservatieve ondergrens IEC 60269-1). '
        'Voor niet-standaard smeltwaarden wordt lineair geïnterpoleerd.'
      : 'Values are the minimum currents at which the fuse will definitely blow '
        'within the stated time (conservative lower bound IEC 60269-1). '
        'Non-standard ratings are linearly interpolated.';
  String get maxLengteGgEenheid => isNL
      ? 'Alle waarden in Ampère  ·  In = nominale smeltwaarde  ·  Ia = minimale uitschakelstroom'
      : 'All values in Amperes  ·  In = rated fuse current  ·  Ia = minimum trip current';

  String get maxLengteNorm => isNL
      ? 'Norm: NEN-HD 60364-4-41 / NEN 1010 artikel 411.4 — automatische '
        'uitschakeling bij indirecte aanraking. MCB-waarden per IEC 60898-1; '
        'gG-waarden per IEC 60269-1 tijdstroomkarakteristiek.'
      : 'Standard: NEN-HD 60364-4-41 / NEN 1010 article 411.4 — automatic '
        'disconnection on indirect contact. MCB values per IEC 60898-1; '
        'gG values per IEC 60269-1 time-current characteristic.';

  // ── WINDKOELING & PV LAAGPOSITIE ─────────────────────────────────────────
  String get windkoelingUitlegTitel => isNL
      ? 'Stap 2c — Windkoeling & PV-zonneinstraling  (IEC 60287-2-1 / IEC 60364-5-52)'
      : 'Step 2c — Wind Cooling & PV Solar Irradiance  (IEC 60287-2-1 / IEC 60364-5-52)';
  String get windkoelingUitlegIntro => isNL
      ? 'Voor PV-singels in kabelgoten op daken zijn twee extra thermische correcties '
        'beschikbaar: windkoeling (vermindert effectieve omgevingstemperatuur) en '
        'PV-laagpositie (vervangt de vlakke zonlichttoeslag met een laagafhankelijke ΔT).'
      : 'For PV single-core cables in cable trays on roofs, two additional thermal '
        'corrections are available: wind cooling (reduces effective ambient temperature) '
        'and PV layer position (replaces the flat solar supplement with a layer-dependent ΔT).';
  String get windkoelingUitlegModelTitel => isNL
      ? 'Windkoelingsmodel  (IEC 60287-2-1 convectiecoëfficiënt)'
      : 'Wind cooling model  (IEC 60287-2-1 convection coefficient)';
  String get windkoelingUitlegModelIntro => isNL
      ? 'Wind vergroot de convectiecoëfficiënt h [W/m²·K] van het kabeloppervlak naar de omgeving. '
        'Dit verlaagt de effectieve omgevingstemperatuur θ_eff, waardoor f_T stijgt en meer stroom '
        'toelaatbaar is. Modellering als temperatuuroffset ΔT_wind:'
      : 'Wind increases the convection coefficient h [W/m²·K] from cable surface to ambient. '
        'This lowers the effective ambient temperature θ_eff, raising f_T and allowing more current. '
        'Modelled as a temperature offset ΔT_wind:';
  String get windkoelingUitlegFormule =>
      'θ_eff = θ_omg + ΔT_zon + ΔT_wind\n'
      'ΔT_wind = ΔT_deksel − ΔT_wind_afkoeling';
  String get windkoelingUitlegTabelTitel => isNL
      ? 'ΔT-waarden per windsnelheid (IEC 60287-2-1 indicatief):'
      : 'ΔT values per wind speed (IEC 60287-2-1 indicative):';
  String get windkoelingUitlegDekselTitel => isNL
      ? 'Stalen deksel op goot:'
      : 'Steel lid on cable tray:';
  String get windkoelingUitlegDekselSub => isNL
      ? 'Stalen deksel beperkt convectie: penalty +5 K op effectieve omgevingstemperatuur'
      : 'Steel lid restricts convection: +5 K penalty on effective ambient temperature';
  String get pvLaagUitlegTitel => isNL
      ? 'PV-laagpositie zonneinstraling  (IEC 60364-5-52 / IEC 60287)'
      : 'PV layer position solar irradiance  (IEC 60364-5-52 / IEC 60287)';
  String get pvLaagUitlegIntro => isNL
      ? 'In een gestapelde PV-kabelgoot ontvangen niet alle lagen evenveel zonneinstraling. '
        'Wanneer het laagpositiemodel actief is, vervangt het de handmatige zonlicht-ΔT '
        'met een preset per positie in de stapel:'
      : 'In a stacked PV cable tray, not all layers receive the same solar irradiance. '
        'When the layer position model is active, it replaces the manual sunlight ΔT '
        'with a preset per position in the stack:';
  String get pvLaagUitlegNoot => isNL
      ? 'Maatgevend voor het ontwerp is de toplaag (bovenste 20 singels bij 20×8 configuratie). '
        'Activeer de toplaag voor het worst-case scenario; gebruik middenlaag voor de gemiddelde kabel.'
      : 'The top layer (top 20 singels in a 20×8 configuration) is governing for design. '
        'Activate top layer for worst-case scenario; use middle layer for the average cable.';
  String get overzichtWindkoeling => isNL
      ? 'Windkoeling / PV-laag ΔT'
      : 'Wind cooling / PV layer ΔT';
  String get overzichtWindkoelingSub => isNL
      ? 'θ_eff = θ_omg + ΔT_zon + ΔT_wind  (IEC 60287-2-1)'
      : 'θ_eff = θ_amb + ΔT_sun + ΔT_wind  (IEC 60287-2-1)';

  // ── EINDOORDEEL ──────────────────────────────────────────────────────────
  String get eindoordeelTitel => isNL ? 'Stap 8 — Eindoordeel' : 'Step 8 — Final Assessment';
  String get eindoordeelIntro => isNL
      ? 'Het resultaat is "Voldoet" als alle onderstaande criteria slagen. Gefaalde criteria verschijnen als fouten; indicatieve overschrijdingen als waarschuwingen.'
      : 'The result is "Passes" if all of the following criteria succeed. Failed criteria appear as errors; indicative exceedances as warnings.';
  String get eindoordeelNormen => isNL
      ? 'Normen: IEC 60364-5-52 (stroombelasting en correctiefactoren)  ·  IEC 60949 (kortsluit)  ·  IEC 60287 (thermisch grondmodel)  ·  NEN 1010 (Nederlandse aanvullingen incl. zonstraling).'
      : 'Standards: IEC 60364-5-52 (current carrying capacity and correction factors)  ·  IEC 60949 (short-circuit)  ·  IEC 60287 (thermal ground model)  ·  NEN 1010 (Dutch supplements incl. solar radiation).';
}
