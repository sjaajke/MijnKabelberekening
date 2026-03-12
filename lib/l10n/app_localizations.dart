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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/language_provider.dart';

extension AppLocalizationsExt on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations(Provider.of<LanguageProvider>(this).locale);
}

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  bool get isNL => locale.languageCode == 'nl';

  // ── APP ──────────────────────────────────────────────────────────────────
  String get appTitle => 'MijnKabelberekening  —  IEC 60364-5-52 / NEN 1010';
  String get appTitleShort => 'MijnKabelberekening';

  // ── NAVIGATIE / HOME ─────────────────────────────────────────────────────
  String get navKabelcatalogus => isNL ? 'Kabelcatalogus' : 'Cable Catalogue';
  String get navCorrectiefactoren =>
      isNL ? 'Correctiefactoren' : 'Correction Factors';
  String get navBerekeningswijze =>
      isNL ? 'Berekeningswijze' : 'Calculation Method';
  String get navPrivacy => 'Privacy Policy';
  String get tabInvoer => isNL ? 'Invoer' : 'Input';
  String get tabResultaten => isNL ? 'Resultaten' : 'Results';
  String get taalWisselen => isNL ? 'Taal' : 'Language';

  // ── SYSTEEM & SPANNING ───────────────────────────────────────────────────
  String get sectSysteem => isNL ? 'Systeem & Spanning' : 'System & Voltage';
  String get lblSysteemtype => isNL ? 'Systeemtype' : 'System Type';
  String get lblSpanning => isNL ? 'Nominale spanning' : 'Nominal Voltage';
  String get lblCosPhi => isNL ? 'Arbeidsfactor cos φ' : 'Power Factor cos φ';

  // ── BELASTING ────────────────────────────────────────────────────────────
  String get sectBelasting => isNL ? 'Belasting' : 'Load';
  String get lblVermogenSchakelaar =>
      isNL ? 'Vermogen opgeven (in plaats van stroom)' : 'Enter Power (instead of current)';
  String get lblVermogen => isNL ? 'Vermogen' : 'Power';
  String get lblStroom => isNL ? 'Stroom' : 'Current';
  String get lblKabellengte => isNL ? 'Kabellengte' : 'Cable Length';

  // ── KABEL & LEGGING ──────────────────────────────────────────────────────
  String get sectKabel => isNL ? 'Kabel & Legging' : 'Cable & Installation';
  String get lblGeleidermateriaal =>
      isNL ? 'Geleidermateriaal' : 'Conductor Material';
  String get lblIsolatiemateriaal =>
      isNL ? 'Isolatiemateriaal' : 'Insulation Material';
  String get lblLeggingswijze =>
      isNL ? 'Leggingswijze' : 'Installation Method';
  String get lblAantalAders => isNL ? 'Aantal aders' : 'Number of Cores';
  String get lblGeleidersPerKring =>
      isNL ? 'Geleiders per kring' : 'Conductors per Circuit';
  String get lblDoorsnedeForce => isNL ? 'Doorsnede forceren' : 'Force Cross-section';
  String get lblDoorsnede => isNL ? 'Doorsnede' : 'Cross-section';
  String get lblParallelKabels =>
      isNL ? 'Parallel kabels per fase' : 'Parallel Cables per Phase';
  String get eenheidStuks => isNL ? 'stuks' : 'pcs';
  String get eenheidLagen => isNL ? 'lagen' : 'layers';

  String singelTotaalLabel(int nParallel, int geleidersPerKring) => isNL
      ? 'Totaal: ${nParallel * geleidersPerKring} singels'
          '  ($nParallel× kring × $geleidersPerKring geleiders)'
      : 'Total: ${nParallel * geleidersPerKring} singles'
          '  ($nParallel× circuit × $geleidersPerKring conductors)';

  String parallelTotaalLabel(String iTotaal, int nParallel, String iPerKabel) =>
      isNL
          ? 'Totale I per fase: $iTotaal A  →  $iPerKabel A per kabel'
          : 'Total I per phase: $iTotaal A  →  $iPerKabel A per cable';

  // ── OMGEVING & BUNDEL ────────────────────────────────────────────────────
  String get sectOmgeving => isNL ? 'Omgeving & Bundel' : 'Environment & Bundle';
  String get lblOmgevingstemp => isNL ? 'Omgevingstemperatuur' : 'Ambient Temperature';
  String get lblLegdiepte => isNL ? 'Legdiepte' : 'Burial Depth';
  String get lblGrondtemp => isNL ? 'Grondtemperatuur' : 'Ground Temperature';
  String get lblLambdaGrond =>
      isNL ? 'Bodemthermische weerstand (λ)' : 'Soil Thermal Resistivity (λ)';
  String get lblCyclisch =>
      isNL ? 'Cyclische belasting (NEN IEC 60583-1)' : 'Cyclic Load (NEN IEC 60583-1)';
  String get lblZonlicht =>
      isNL ? 'Kabel in direct zonlicht (NEN 1010)' : 'Cable in Direct Sunlight (NEN 1010)';
  String get lblZonlichtToeslag =>
      isNL ? 'Temperatuurtoeslag zonlicht' : 'Temperature Supplement Sunlight';
  String get lblBundel =>
      isNL ? 'Meerdere kabels (bundel)' : 'Multiple Cables (Bundle)';

  // ── BUNDEL CONFIGURATIE ──────────────────────────────────────────────────
  String get sectBundel => isNL ? 'Bundelconfiguratie' : 'Bundle Configuration';
  String get lblKabelsNaast => isNL ? 'Kabels naast elkaar' : 'Cables Side by Side';
  String get lblLagenHoog => isNL ? 'Lagen hoog' : 'Layers High';
  String get lblHartOpHart => isNL ? 'Hart-op-hart afstand' : 'Centre-to-Centre Distance';
  String kabeldiameterInfo(String d) {
    final d2 = _twiceD(d);
    return isNL
        ? 'Kabeldiameter: $d mm  →  aanliggend: $d mm  |  2×d: $d2 mm'
        : 'Cable diameter: $d mm  →  touching: $d mm  |  2×d: $d2 mm';
  }
  String bundelTotaalInfo(int totaal, int r, int c) => isNL
      ? 'Totaal: $totaal kabels  |  Maatgevende positie: ($r, $c)'
      : 'Total: $totaal cables  |  Governing position: ($r, $c)';
  String _twiceD(String d) {
    final v = double.tryParse(d);
    return v != null ? (2 * v).toStringAsFixed(0) : '—';
  }

  // ── CYCLISCH ─────────────────────────────────────────────────────────────
  String get sectCyclisch =>
      isNL ? 'Cyclische belasting  (NEN IEC 60583-1)' : 'Cyclic Load  (NEN IEC 60583-1)';
  String get lblBelastingsprofiel =>
      isNL ? 'Belastingsprofiel' : 'Load Profile';
  String get profielConstant => isNL ? 'Constant  (I/Imax = 1,0)' : 'Constant  (I/Imax = 1.0)';
  String get profielDagNacht => isNL ? 'Dag-nacht cyclus  (IEC voorbeeld)' : 'Day-night cycle  (IEC example)';
  String get profielEigen => isNL ? 'Eigen profiel' : 'Custom Profile';
  String get lblIMaxPerUur => isNL ? 'I/Imax per uur  (0–23):' : 'I/Imax per hour  (0–23):';
  String get lblAantalKringen =>
      isNL ? 'Aantal kringen in groep  (N)' : 'Number of Circuits in Group  (N)';
  String get lblLiggingKringen => isNL ? 'Ligging kringen' : 'Circuit Arrangement';
  String get optAanliggend => isNL ? 'Aanliggend  (touching)' : 'Touching';
  String get optGespreid => isNL ? 'Gespreid  (spaced)' : 'Spaced';
  String get lblHartOpHartKringen =>
      isNL ? 'Hart-op-hart afstand kringen' : 'Centre-to-Centre Distance Circuits';
  String get hint0mmAanliggend =>
      isNL ? '0 mm = aanliggend (hart-op-hart = kabeldiameter)' : '0 mm = touching (c-t-c = cable diameter)';

  // ── EISEN & NORM ─────────────────────────────────────────────────────────
  String get sectEisen => isNL ? 'Eisen & Norm' : 'Requirements & Standard';
  String get lblMaxSpanningsval => isNL ? 'Max. spanningsval' : 'Max. Voltage Drop';
  String get lblKortsluitToets =>
      isNL ? 'Kortsluittoets uitvoeren' : 'Perform Short-circuit Test';
  String get lblHarmonischen =>
      isNL ? 'Hogere harmonischen (NEN 1010 Bijlage 52.E.1)' : 'Higher Harmonics (NEN 1010 Annex 52.E.1)';

  // ── HARMONISCHEN ─────────────────────────────────────────────────────────
  String get sectHarmonischen =>
      isNL ? 'Hogere Harmonischen  (NEN 1010 Bijlage 52.E.1)' : 'Higher Harmonics  (NEN 1010 Annex 52.E.1)';
  String get lblDerdeHarm => isNL ? '3e harmonische' : '3rd Harmonic';
  String get lblZone => isNL ? 'Zone: ' : 'Zone: ';
  String get harmGeenCorrectie => isNL ? 'Geen correctie' : 'No correction';
  String get harmFasestroom => isNL ? 'f = 1,00  |  grondslag: fasestroom' : 'f = 1.00  |  basis: phase current';
  String get harmFasestroomReductie =>
      isNL ? 'f = 0,86  |  grondslag: fasestroom' : 'f = 0.86  |  basis: phase current';
  String get harmNulpuntsstroom =>
      isNL ? 'f = 0,86  |  grondslag: nulpuntsstroom' : 'f = 0.86  |  basis: neutral current';
  String get harmNulpuntsstroomHoog =>
      isNL ? 'f = 1,00  |  grondslag: nulpuntsstroom' : 'f = 1.00  |  basis: neutral current';

  // ── BEREKENEN ────────────────────────────────────────────────────────────
  String get btnBerekenen => isNL ? 'Berekenen' : 'Calculate';

  // ── KORTSLUIT INVOER ─────────────────────────────────────────────────────
  String get sectKortsluit => isNL ? 'Kortsluitgegevens' : 'Short-circuit Data';
  String get lblKortsluitstroom => isNL ? 'Kortsluitstroom I_k' : 'Short-circuit Current I_k';
  String get lblKortsluitduur => isNL ? 'Kortsluitduur' : 'Short-circuit Duration';

  // ── MAXIMALE LEIDINGLENGTE (KORTSLUITBEVEILIGING) ─────────────────────────
  String get lblMaxLengte => isNL ? 'Maximale leidinglengte toetsen' : 'Check Maximum Cable Length';
  String get lblBeveiligingType => isNL ? 'Beveiligingstype' : 'Protection Type';
  String get lblBeveiligingWaarde =>
      isNL ? 'Nominale stroom In (MCB/gG) / Ia (handmatig)' : 'Rated Current In (MCB/gG) / Ia (manual)';
  String get sectMaxLengte =>
      isNL ? 'Max. leidinglengte (kortsluitbeveiliging)' : 'Max. Cable Length (short-circuit protection)';
  String get lblMaxLengteResultaat => isNL ? 'Max. toelaatbare lengte' : 'Max. Allowable Length';
  String get lblIkEind => isNL ? 'I_k aan kabeluiteinde' : 'I_k at cable end';
  String get maxLengteOk => isNL ? 'Lengte voldoet' : 'Length OK';
  String get maxLengteFout => isNL ? 'Lengte overschreden' : 'Length Exceeded';
  String get rapportMaxLengte =>
      isNL ? 'MAX. LEIDINGLENGTE  (kortsluitbeveiliging)' : 'MAX. CABLE LENGTH  (short-circuit protection)';

  // ── RESULTATEN LEEG ──────────────────────────────────────────────────────
  String get resultatenLeeg =>
      isNL ? 'Vul de invoer in en druk op Berekenen' : 'Fill in the input and press Calculate';

  // ── EINDOORDEEL ──────────────────────────────────────────────────────────
  String get eindVoldoet => isNL ? 'VOLDOET AAN ALLE EISEN' : 'MEETS ALL REQUIREMENTS';
  String get eindGefaald => isNL ? 'CONTROLES GEFAALD' : 'CHECKS FAILED';
  String iPerKabelLabel(String i) => isNL ? 'I per kabel: $i A' : 'I per cable: $i A';

  // ── GESELECTEERDE KABEL ──────────────────────────────────────────────────
  String get sectGeselecteerdeKabel =>
      isNL ? 'Geselecteerde Kabel' : 'Selected Cable';
  String get lblType => isNL ? 'Type' : 'Type';
  String get lblSingelConfig =>
      isNL ? 'Singel-configuratie' : 'Single-core Configuration';
  String get lblTotaalSingels =>
      isNL ? 'Totaal benodigde singels' : 'Total Required Singles';
  String get lblGeleider => isNL ? 'Geleider' : 'Conductor';
  String get lblIsolatie => isNL ? 'Isolatie' : 'Insulation';
  String get lblBuitendiameter => isNL ? 'Buitendiameter' : 'Outer Diameter';
  String hartOpHartAanliggend(String d) =>
      isNL ? '$d mm  (= kabeldiameter, min.)' : '$d mm  (= cable diameter, min.)';
  String hartOpHart2xd(String d) =>
      isNL ? '$d mm  (aanbevolen)' : '$d mm  (recommended)';

  // ── CORRECTIEFACTOREN RESULTAAT ──────────────────────────────────────────
  String get sectCorrectiefactoren =>
      isNL ? 'Correctiefactoren  (IEC 60364-5-52)' : 'Correction Factors  (IEC 60364-5-52)';
  String get lblThetaEff => isNL ? 'θ_eff  (omgeving)' : 'θ_eff  (ambient)';
  String get inclZonlicht => isNL ? '  (incl. zonlicht)' : '  (incl. sunlight)';
  String get lblMaatgevendeKabel =>
      isNL ? '  Maatgevende kabel' : '  Governing Cable';
  String get centrumBundel => isNL ? 'centrum bundel' : 'bundle centre';
  String get grondslagFasestroom => isNL ? 'fasestroom' : 'phase current';
  String get grondslagNulpuntsstroom =>
      isNL ? 'nulpuntsstroom  (h3 > 33%)' : 'neutral current  (h3 > 33%)';

  // ── BELASTBAARHEID RESULTAAT ─────────────────────────────────────────────
  String get sectBelastbaarheid =>
      isNL ? 'Belastbaarheid' : 'Current Carrying Capacity';
  String get lblConfiguratie => isNL ? 'Configuratie' : 'Configuration';
  String kabelsParallel(int n) => isNL ? '$n kabels parallel' : '$n cables parallel';
  String get lblITotaal => isNL ? 'I_totaal' : 'I_total';
  String get lblIGevraagd => isNL ? 'I_gevraagd' : 'I_required';
  String get lblINMaatgevend => isNL ? 'I_N  (maatgevend)' : 'I_N  (governing)';
  String get lblIFase => isNL ? 'I_fase' : 'I_phase';
  String get lblVeiligheidsmarge => isNL ? 'Veiligheidsmarge' : 'Safety Margin';
  String get perKabelSuffix => isNL ? '  per kabel' : '  per cable';

  // ── BUNDEL POSITIEVERGELIJKING ───────────────────────────────────────────
  String get sectBundelPosities =>
      isNL ? 'Bundel: positievergelijking' : 'Bundle: Position Comparison';
  String get colCentrum => isNL ? 'Centrum\n(warmst)' : 'Centre\n(hottest)';
  String get colHoek => isNL ? 'Hoek\n(koudst)' : 'Corner\n(coolest)';
  String get rowMarge => isNL ? 'Marge' : 'Margin';
  String get rowTGeleider => isNL ? 'T geleider (°C)' : 'T conductor (°C)';
  String get bundelGelijkwaardig =>
      isNL ? 'Bij dit bundelformaat zijn alle posities thermisch gelijkwaardig.'
           : 'For this bundle size, all positions are thermally equivalent.';
  String get bundelTempIndicatief =>
      isNL ? 'Temperatuur indicatief: T_eff = T_max − (T_max − T_omg)·f_bundel²  +  ΔT_eigen (I²R)'
           : 'Temperature indicative: T_eff = T_max − (T_max − T_amb)·f_bundle²  +  ΔT_own (I²R)';

  // ── SPANNINGSVAL ─────────────────────────────────────────────────────────
  String get sectSpanningsval => isNL ? 'Spanningsval' : 'Voltage Drop';
  String get lblDeltaUAbs => isNL ? 'ΔU (absoluut)' : 'ΔU (absolute)';
  String get lblDeltaUPct => isNL ? 'ΔU (procent)' : 'ΔU (percent)';
  String get lblStatus => isNL ? 'Status' : 'Status';
  String get statusVoldoet => isNL ? '✓  VOLDOET' : '✓  PASSES';
  String get statusOverschreden => isNL ? '✗  OVERSCHREDEN' : '✗  EXCEEDED';

  // ── TEMPERATUUR ──────────────────────────────────────────────────────────
  String get sectTemperatuur =>
      isNL ? 'Temperatuurverhoging  (vereenvoudigd)' : 'Temperature Rise  (simplified)';
  String get lblI2RVerlies => isNL ? 'I²R-verlies' : 'I²R Loss';
  String get lblTempStijging => isNL ? 'Temperatuurstijging' : 'Temperature Rise';
  String get lblGeleidertemp => isNL ? 'Geleidertemperatuur' : 'Conductor Temperature';
  String get lblMaximum => isNL ? 'Maximum' : 'Maximum';
  String get lblMarge => isNL ? 'Marge' : 'Margin';

  // ── KORTSLUITVASTHEID ────────────────────────────────────────────────────
  String get sectKortsluitvastheid =>
      isNL ? 'Kortsluitvastheid  (IEC 60949)' : 'Short-circuit Withstand  (IEC 60949)';
  String get lblEindtemperatuur => isNL ? 'Eindtemperatuur' : 'Final Temperature';
  String get lblMaxToegestaan => isNL ? 'Max. toegestaan' : 'Max. Permitted';
  String get statusVoldoetKort => isNL ? '✓  VOLDOET' : '✓  PASSES';
  String get statusFaalt => isNL ? '✗  FAALT' : '✗  FAILS';

  // ── FOUTEN / WAARSCHUWINGEN ──────────────────────────────────────────────
  String get lblFouten => isNL ? 'FOUTEN' : 'ERRORS';
  String get lblWaarschuwingen => isNL ? 'WAARSCHUWINGEN' : 'WARNINGS';

  // ── RAPPORT KOPIËREN ─────────────────────────────────────────────────────
  String get btnRapportKopieren => isNL ? 'Rapport kopiëren' : 'Copy Report';
  String get snackRapportGekopieerd =>
      isNL ? 'Rapport gekopieerd naar klembord' : 'Report copied to clipboard';

  // ── CATALOGUS ────────────────────────────────────────────────────────────
  String get sectCatalogus => isNL ? 'Kabelcatalogus' : 'Cable Catalogue';
  String get ttKabelToevoegen => isNL ? 'Kabel toevoegen' : 'Add Cable';
  String get lblFilterGeleider => isNL ? 'Geleider' : 'Conductor';
  String get lblFilterIsolatie => isNL ? 'Isolatie' : 'Insulation';
  String get lblFilterAders => isNL ? 'Aders' : 'Cores';
  String catalogusLegenda(int aders) => isNL
      ? 'I_z C = methode C (in buis/wand)  ·  I_z E = methode E (vrije lucht)  ·  '
          'θ_ref = 30 °C  ·  '
          '${aders <= 2 ? "2 belaste aders (1-fase/DC)" : "3 belaste aders (3-fase)"}  ·  '
          'Bron: IEC 60364-5-52 B.52.4/B.52.5'
      : 'I_z C = method C (in conduit/wall)  ·  I_z E = method E (free air)  ·  '
          'θ_ref = 30 °C  ·  '
          '${aders <= 2 ? "2 loaded cores (1-phase/DC)" : "3 loaded cores (3-phase)"}  ·  '
          'Source: IEC 60364-5-52 B.52.4/B.52.5';
  String get lblEigenKabel => isNL ? 'Eigen kabel' : 'Custom Cable';
  String get ttBewerken => isNL ? 'Bewerken' : 'Edit';
  String get ttVerwijderen => isNL ? 'Verwijderen' : 'Delete';
  String get dlgKabelVerwijderenTitel =>
      isNL ? 'Kabel verwijderen' : 'Delete Cable';
  String dlgKabelVerwijderenInhoud(String naam) => isNL
      ? 'Weet je zeker dat je "$naam" wilt verwijderen?'
      : 'Are you sure you want to delete "$naam"?';
  String get btnAnnuleren => isNL ? 'Annuleren' : 'Cancel';
  String get btnVerwijderen => isNL ? 'Verwijderen' : 'Delete';

  // Catalogus tabel tooltips
  String get ttDoorsnede => isNL ? 'Nominale doorsnede per geleider' : 'Nominal cross-section per conductor';
  String get ttAders => isNL ? 'Aantal fysieke aders in de kabel' : 'Number of physical cores in the cable';
  String get ttRAc => isNL ? 'AC-weerstand bij 20 °C (incl. skin-effect bij Cu)' : 'AC resistance at 20 °C (incl. skin effect for Cu)';
  String get ttX => isNL ? 'Inductieve reactantie bij 50 Hz' : 'Inductive reactance at 50 Hz';
  String get ttIzC => isNL ? 'Toelaatbare stroom — methode C (in buis of aanliggend aan wand)' : 'Permissible current — method C (in conduit or touching wall)';
  String get ttIzE => isNL ? 'Toelaatbare stroom — methode E (vrije lucht, 1 D van oppervlak)' : 'Permissible current — method E (free air, 1 D from surface)';
  String get ttBuiten => isNL ? 'Typische buitendiameter (fabrikants-/IEC 60228-waarden)' : 'Typical outer diameter (manufacturer/IEC 60228 values)';

  // ── KABEL TOEVOEGEN DIALOG ───────────────────────────────────────────────
  String get dlgKabelBewerken => isNL ? 'Kabel bewerken' : 'Edit Cable';
  String get dlgKabelToevoegen => isNL ? 'Kabel toevoegen' : 'Add Cable';
  String get dlgSectIdentificatie => isNL ? 'Identificatie' : 'Identification';
  String get dlgSectElektrisch => isNL ? 'Elektrische eigenschappen' : 'Electrical Properties';
  String get dlgSectStroom => isNL ? 'Toelaatbare stroom  (θ_ref = 30 °C)' : 'Permissible Current  (θ_ref = 30 °C)';
  String get dlgSectGeometrie => isNL ? 'Geometrie' : 'Geometry';
  String get dlgLblNaam => isNL ? 'Naam (optioneel)' : 'Name (optional)';
  String get dlgHintNaam => isNL ? 'Automatisch gegenereerd als leeg' : 'Auto-generated if empty';
  String get dlgHintDoorsnede => isNL ? 'bijv. 1.5 of 25' : 'e.g. 1.5 or 25';
  String get dlgHintRac => isNL ? 'bijv. 1.21' : 'e.g. 1.21';
  String get dlgHintX => isNL ? 'bijv. 0.075  (0 voor DC)' : 'e.g. 0.075  (0 for DC)';
  String get dlgHintIzC => isNL ? 'In buis / aanliggend aan wand' : 'In conduit / touching wall';
  String get dlgHintIzE => isNL ? 'Vrije lucht' : 'Free air';
  String get dlgHintIz3Fase => isNL ? '0 als niet van toepassing' : '0 if not applicable';
  String get dlgIzC3Fase => isNL ? 'I_z C  (3-fase, 3 bel. aders)' : 'I_z C  (3-phase, 3 loaded cores)';
  String get dlgIzE3Fase => isNL ? 'I_z E  (3-fase, 3 bel. aders)' : 'I_z E  (3-phase, 3 loaded cores)';
  String get dlgHintBuiten => isNL ? 'bijv. 17.5' : 'e.g. 17.5';
  String get btnOpslaan => isNL ? 'Opslaan' : 'Save';
  String get btnToevoegen => isNL ? 'Toevoegen' : 'Add';
  String get valideerVerplichtVeld => isNL ? 'Verplicht veld' : 'Required field';
  String get valideerVerplicht => isNL ? 'Verplicht' : 'Required';
  String get valideerOngeldigGetal => isNL ? 'Ongeldig getal' : 'Invalid number';
  String get valideerGroterDanNul => isNL ? 'Moet > 0 zijn' : 'Must be > 0';
  String get valideerNietNegatief => isNL ? 'Moet ≥ 0 zijn' : 'Must be ≥ 0';

  // ── CORRECTIEFACTOREN SCHERM ─────────────────────────────────────────────
  String get uitlegCorrectiefactoren => isNL
      ? 'IEC 60364-5-52 / NEN 1010. Combineer door te vermenigvuldigen:\n'
          'I_z = I_z0 · f_T · f_bundel · f_grond [· M] [· f_harm]'
      : 'IEC 60364-5-52 / NEN 1010. Combine by multiplying:\n'
          'I_z = I_z0 · f_T · f_bundle · f_ground [· M] [· f_harm]';

  String get sectTempFactor =>
      isNL ? 'Temperatuurcorrectiefactor  f_T  —  §523.2'
           : 'Temperature Correction Factor  f_T  —  §523.2';
  String get ttOmgevingstemp => isNL ? 'Omgevingstemperatuur' : 'Ambient Temperature';
  String get ttPVC => isNL ? 'PVC-isolatie, max. geleidertemperatuur 70 °C' : 'PVC insulation, max. conductor temperature 70 °C';
  String get ttXLPE => isNL ? 'XLPE/EPR-isolatie, max. geleidertemperatuur 90 °C' : 'XLPE/EPR insulation, max. conductor temperature 90 °C';

  String get sectBundelingFactor =>
      isNL ? 'Bundelingsfactor  f_bundel  —  Tabel B.52.20'
           : 'Grouping Factor  f_group  —  Table B.52.20';
  String get uitlegBundeling => isNL
      ? 'Reductie voor n kabels naast elkaar in één laag (horizontale bundeling)'
      : 'Reduction for n cables side by side in one layer (horizontal grouping)';
  String get ttNKabels => isNL ? 'Aantal kabels naast elkaar' : 'Number of cables side by side';
  String get ttReductiefactor => isNL ? 'Reductiefactor op de toelaatbare stroom' : 'Reduction factor on permissible current';
  String get ttEffectief => isNL ? 'Effectief toelaatbare stroom t.o.v. enkelvoudig' : 'Effectively permissible current vs. single';

  String get sectStapelingFactor =>
      isNL ? 'Stapelingsfactor  f_stapel  —  Tabel B.52.21'
           : 'Stacking Factor  f_stack  —  Table B.52.21';
  String get uitlegStapeling => isNL
      ? 'Aanvullende reductie voor gestapelde lagen (combineer met f_bundel)'
      : 'Additional reduction for stacked layers (combine with f_group)';
  String get ttNLagen => isNL ? 'Aantal gestapelde lagen' : 'Number of stacked layers';
  String get ttReductiefactorStapel =>
      isNL ? 'Reductiefactor per IEC 60364-5-52 B.52.21' : 'Reduction factor per IEC 60364-5-52 B.52.21';

  String get sectBodemweerstand =>
      isNL ? 'Bodemweerstandsfactor  f_grond  —  Tabel B.52.16'
           : 'Soil Resistance Factor  f_ground  —  Table B.52.16';
  String get uitlegBodem => isNL
      ? 'Alleen van toepassing bij grondlegging (D1/D2). '
          'Referentie: λ = 1,0 K·m/W (factor = 1,00).'
      : 'Only applicable for underground installation (D1/D2). '
          'Reference: λ = 1.0 K·m/W (factor = 1.00).';
  String get ttLambda => isNL ? 'Thermische weerstand van de grond in K·m/W' : 'Thermal resistance of the soil in K·m/W';
  String get ttFgrond => isNL ? 'Correctiefactor op de toelaatbare stroom' : 'Correction factor on permissible current';
  String get ttGrondsoort => isNL ? 'Grondsoort (typisch)' : 'Soil Type (typical)';
  String grondsoortLabel(double lam) {
    if (lam <= 0.5) return isNL ? 'Vochtig/nat zand, klei' : 'Wet/moist sand, clay';
    if (lam <= 0.7) return isNL ? 'Vochtige grond' : 'Moist soil';
    if (lam <= 1.0) return isNL ? 'Standaard (referentie)' : 'Standard (reference)';
    if (lam <= 1.5) return isNL ? 'Gemiddeld droge grond' : 'Moderately dry soil';
    if (lam <= 2.0) return isNL ? 'Droge zandgrond' : 'Dry sandy soil';
    return isNL ? 'Zeer droog zand/grind' : 'Very dry sand/gravel';
  }

  String get sectCyclischFactor =>
      isNL ? 'Cyclische belastingsfactor  M  —  NEN IEC 60583-1:2002'
           : 'Cyclic Load Factor  M  —  NEN IEC 60583-1:2002';
  String get uitlegCyclisch => isNL
      ? 'Alleen grondkabels (D1/D2). '
          'M ≥ 1,0 verhoogt de toelaatbare stroom wanneer de kabel '
          'niet continu volledig belast is.'
      : 'Underground cables only (D1/D2). '
          'M ≥ 1.0 increases the permissible current when the cable '
          'is not continuously fully loaded.';
  String get lblInvoerparameters => isNL ? 'Invoerparameters:' : 'Input Parameters:';
  String get cyclischBelastingsprofiel => isNL ? 'Belastingsprofiel' : 'Load profile';
  String get cyclischLegdiepte => isNL ? 'Legdiepte L' : 'Burial depth L';
  String get cyclischAfstandKabelhart => isNL ? 'Afstand tot kabelhart [m]' : 'Distance to cable centre [m]';
  String get cyclischBodemweerstand => isNL ? 'Bodemweerstand ξ' : 'Soil resistance ξ';
  String get cyclischBodemweerstandEenheid => isNL ? 'Thermische weerstand grond [K·m/W]' : 'Thermal resistance of soil [K·m/W]';
  String get cyclischKabeldiameter => isNL ? 'Kabeldiameter De' : 'Cable diameter De';
  String get cyclischKabeldiameterEenheid => isNL ? 'Buitendiameter kabel [m]  — per kandidaat-kabel' : 'Outer diameter cable [m]  — per candidate cable';
  String get cyclischJoule => isNL ? 'Joule-verlies W' : 'Joule loss W';
  String get cyclischJouleEenheid => isNL ? 'W = I² · R_DC  [W/m]  — per kandidaat-kabel' : 'W = I² · R_DC  [W/m]  — per candidate cable';
  String get cyclischNKringen => isNL ? 'Aantal kringen N' : 'Number of circuits N';
  String get cyclischNKringenEenheid => isNL ? 'Kabels in de groep (voor beeldfactor F)' : 'Cables in the group (for image factor F)';
  String get cyclischLigging => isNL ? 'Ligging' : 'Arrangement';
  String get cyclischLiggingEenheid => isNL ? 'Aanliggend (touching) of gespreid (spaced)' : 'Touching or spaced';
  String get cyclischTypischeTitel => isNL
      ? 'Typische M-waarden (IEC voorbeeldprofiel, Cu 35 mm², 0,70 m):'
      : 'Typical M values (IEC example profile, Cu 35 mm², 0.70 m):';
  String get cyclischColProfiel => isNL ? 'Profiel' : 'Profile';
  String get cyclischMworden => isNL
      ? 'M wordt per kandidaat-kabel opnieuw berekend omdat het Joule-verlies '
          'W = I²·R en de buitendiameter De kabelspecifiek zijn.'
      : 'M is recalculated per candidate cable because the Joule loss '
          'W = I²·R and outer diameter De are cable-specific.';
  String cyclischProfielNaam(String naam) {
    if (naam.startsWith('Continu')) return isNL ? 'Continu (1,0)' : 'Continuous (1.0)';
    if (naam.startsWith('IEC')) return isNL ? 'IEC dagprofiel' : 'IEC day profile';
    if (naam.startsWith('Nacht')) return isNL ? 'Nacht-piek' : 'Night-peak';
    if (naam.startsWith('Laag')) return isNL ? 'Laag (0,5 max)' : 'Low (0.5 max)';
    return naam;
  }

  String get sectHarmonischenFactor =>
      isNL ? 'Harmonischencorrectie  f_harm  —  NEN 1010 Bijlage 52.E.1'
           : 'Harmonics Correction  f_harm  —  NEN 1010 Annex 52.E.1';
  String get uitlegHarmonischen => isNL
      ? 'Alleen AC 3-fase met 4- of 5-aderige kabel (3L + N). '
          'Grondslag kabelkeuze wisselt bij h₃ > 33%: nulpuntsstroom I_N = 3·h₃·I_fase.'
      : 'Only AC 3-phase with 4- or 5-core cable (3L + N). '
          'Cable selection basis changes at h₃ > 33%: neutral current I_N = 3·h₃·I_phase.';
  String get ttH3 => isNL ? '3e harmonische als % van de fasestroom' : '3rd harmonic as % of phase current';
  String get ttFharm => isNL ? 'Correctiefactor op de tabelwaarde I_z0' : 'Correction factor on table value I_z0';
  String get ttGrondslag => isNL ? 'Stroom die als grondslag dient voor kabelkeuze' : 'Current used as basis for cable selection';
  String get ttINFase => isNL ? 'Nulpuntsstroom als veelvoud van fasestroom' : 'Neutral current as multiple of phase current';
  String get harmNulpuntsstroom2 => isNL ? 'nulpuntsstroom' : 'neutral current';
  String get harmFasestroom2 => isNL ? 'fasestroom' : 'phase current';
  String get legendH3Zone1 => isNL ? 'h₃ ≤ 15%  f=1,00  fasestroom' : 'h₃ ≤ 15%  f=1.00  phase current';
  String get legendH3Zone2 => isNL ? 'h₃ 15–33%  f=0,86  fasestroom' : 'h₃ 15–33%  f=0.86  phase current';
  String get legendH3Grens => isNL ? 'h₃ = 33% / 45%  grenszones' : 'h₃ = 33% / 45%  boundary zones';
  String get legendH3NulNul => isNL ? 'h₃ > 33%  nulpuntsstroom maatgevend' : 'h₃ > 33%  neutral current governing';

  // ── UITLEG SCHERM ────────────────────────────────────────────────────────
  String get uitlegAppBarTitel =>
      isNL ? 'Berekeningswijze  —  IEC 60364 / NEN 1010'
           : 'Calculation Method  —  IEC 60364 / NEN 1010';

  // Sectie titels
  String get uitlegSectOverzicht => isNL ? 'Overzicht berekeningsstappen' : 'Overview of Calculation Steps';
  String get uitlegSectStroom => isNL ? '1. Stroombepaling' : '1. Current Determination';
  String get uitlegSectCorrectiefactoren => isNL ? '2. Correctiefactoren' : '2. Correction Factors';
  String get uitlegSectCyclisch => isNL ? '3. Cyclische belastingsfactor M' : '3. Cyclic Load Factor M';
  String get uitlegSectHarmonischen => isNL ? '4. Hogere harmonischen' : '4. Higher Harmonics';
  String get uitlegSectKortsluitMin => isNL ? '5. Min. kortsluitvastheid (adiabatisch)' : '5. Min. Short-circuit Withstand (adiabatic)';
  String get uitlegSectKabelkeuze => isNL ? '6. Kabelkeuze' : '6. Cable Selection';
  String get uitlegSectCatalogus => isNL ? '7. Cataloguswaarden' : '7. Catalogue Values';
  String get uitlegSectThermisch => isNL ? '8. Thermische kerntemperatuur' : '8. Thermal Core Temperature';
  String get uitlegSectSpanningsval => isNL ? '9. Spanningsval' : '9. Voltage Drop';
  String get uitlegSectTemperatuur => isNL ? '10. Temperatuurverhoging' : '10. Temperature Rise';
  String get uitlegSectKortsluitToets => isNL ? '11. Kortsluittoets' : '11. Short-circuit Check';
  String get uitlegSectEindoordeel => isNL ? '12. Eindoordeel' : '12. Final Assessment';

  // ── PRIVACY SCHERM ───────────────────────────────────────────────────────
  String get privacyTitel => isNL ? 'Privacy Policy' : 'Privacy Policy';
  String get privacyBijgewerkt => isNL ? 'Laatst bijgewerkt: 8 maart 2026' : 'Last updated: 8 March 2026';
  String get privacyIntro => isNL
      ? 'Deze Privacy Policy beschrijft het privacybeleid voor deze applicatie, ontwikkeld door Inspectieportal.'
      : 'This Privacy Policy describes the privacy policy for this application, developed by Inspectieportal.';

  String get privacy1Titel => isNL ? 'Geen verzameling van persoonsgegevens' : 'No Collection of Personal Data';
  String get privacy1Intro => isNL
      ? 'De App verzamelt, bewaart of verwerkt geen persoonlijke gegevens van gebruikers.\nWij vragen geen informatie zoals:'
      : 'The App does not collect, store or process any personal data of users.\nWe do not request information such as:';
  static const List<String> privacy1BulletsNL = ['Naam', 'E-mailadres', 'Telefoonnummer', 'Locatiegegevens', 'IP-adres', 'Accountinformatie'];
  static const List<String> privacy1BulletsEN = ['Name', 'Email address', 'Phone number', 'Location data', 'IP address', 'Account information'];
  List<String> get privacy1Bullets => isNL ? privacy1BulletsNL : privacy1BulletsEN;
  String get privacy1Slot => isNL
      ? 'De App kan volledig worden gebruikt zonder dat persoonlijke gegevens worden verstrekt.'
      : 'The App can be used fully without providing any personal data.';

  String get privacy2Titel => isNL ? 'Geen automatische gegevensverzameling' : 'No Automatic Data Collection';
  String get privacy2Intro => isNL ? 'De App maakt geen gebruik van:' : 'The App does not use:';
  static const List<String> privacy2BulletsNL = ['analytics- of trackingdiensten', 'advertentienetwerken', 'cookies of vergelijkbare technologieën', 'externe servers voor gegevensopslag'];
  static const List<String> privacy2BulletsEN = ['analytics or tracking services', 'advertising networks', 'cookies or similar technologies', 'external servers for data storage'];
  List<String> get privacy2Bullets => isNL ? privacy2BulletsNL : privacy2BulletsEN;
  String get privacy2Slot => isNL
      ? 'Er worden geen gebruiksgegevens of technische gegevens verzameld.'
      : 'No usage data or technical data is collected.';

  String get privacy3Titel => isNL ? 'Gegevens op het apparaat' : 'Data on the Device';
  String get privacy3Body => isNL
      ? 'Indien de App gegevens opslaat, gebeurt dit uitsluitend lokaal op het apparaat van de gebruiker. '
          'Deze gegevens worden niet verzonden naar ons of naar derden.'
      : 'If the App stores data, this is done exclusively locally on the user\'s device. '
          'This data is not transmitted to us or to third parties.';

  String get privacy4Titel => isNL ? 'Delen van informatie' : 'Sharing of Information';
  String get privacy4Body => isNL
      ? 'Omdat wij geen gegevens verzamelen, delen wij ook geen gegevens met derden.'
      : 'Since we do not collect any data, we also do not share any data with third parties.';

  String get privacy5Titel => isNL ? 'Privacy van kinderen' : 'Children\'s Privacy';
  String get privacy5Body => isNL
      ? 'Aangezien de App geen persoonsgegevens verzamelt, is er geen verwerking van gegevens van kinderen.'
      : 'Since the App does not collect personal data, there is no processing of children\'s data.';

  String get privacy6Titel => isNL ? 'Wijzigingen in dit privacybeleid' : 'Changes to this Privacy Policy';
  String get privacy6Body => isNL
      ? 'Wij kunnen dit privacybeleid van tijd tot tijd bijwerken. '
          'Eventuele wijzigingen worden gepubliceerd via deze pagina met een bijgewerkte datum.'
      : 'We may update this privacy policy from time to time. '
          'Any changes will be published on this page with an updated date.';

  String get privacy7Titel => isNL ? 'Contact' : 'Contact';
  String get privacy7Body => isNL
      ? 'Als u vragen heeft over deze Privacy Policy, kunt u contact opnemen via:\n\n'
          'Ontwikkelaar: Inspectieportal\n'
          'E-mail: support@inspectieportal.nl'
      : 'If you have questions about this Privacy Policy, you can contact us via:\n\n'
          'Developer: Inspectieportal\n'
          'Email: support@inspectieportal.nl';

  // ── PROJECTEN ─────────────────────────────────────────────────────────────
  String get navProjecten => isNL ? 'Projecten' : 'Projects';
  String get projectenLeeg => isNL
      ? 'Geen projecten\nMaak een project aan om\nberekeningen op te slaan.'
      : 'No projects\nCreate a project to\nsave calculations.';
  String get projectNieuw => isNL ? 'Nieuw project' : 'New project';
  String get projectNaam => isNL ? 'Projectnaam' : 'Project name';
  String get projectHernoemen => isNL ? 'Hernoemen' : 'Rename';
  String get projectVerwijderen => isNL ? 'Project verwijderen' : 'Delete project';
  String get projectVerwijderenVraag => isNL
      ? 'Weet je zeker dat je dit project wilt verwijderen? Alle opgeslagen berekeningen gaan verloren.'
      : 'Are you sure you want to delete this project? All saved calculations will be lost.';
  String berekeningen(int n) => isNL
      ? '$n berekening${n == 1 ? '' : 'en'}'
      : '$n calculation${n == 1 ? '' : 's'}';
  String get berekeningSlaOp => isNL ? 'Opslaan in project' : 'Save to project';
  String get berekeningNaam => isNL ? 'Naam voor deze berekening' : 'Name for this calculation';
  String get berekeningNaamHint => isNL ? 'bijv. Aanvoer verdieping 1' : 'e.g. Supply floor 1';
  String get berekeningLeeg => isNL
      ? 'Geen berekeningen opgeslagen.\nVoer een berekening uit en sla hem op.'
      : 'No calculations saved.\nRun a calculation and save it.';
  String get berekeningLaden => isNL ? 'Berekening laden' : 'Load calculation';
  String get berekeningLadenVraag => isNL
      ? 'Huidige invoer wordt overschreven. Doorgaan?'
      : 'Current input will be overwritten. Continue?';
  String get berekeningVerwijderen => isNL ? 'Berekening verwijderen' : 'Delete calculation';
  String get berekeningToevoegenAan => isNL ? 'Toevoegen aan project' : 'Add to project';
  String get projectKiezen => isNL ? 'Kies een project' : 'Choose a project';
  String berekeningSamenvatting(String systeem, double stroom, double lengte) =>
      '$systeem  ·  ${stroom.toStringAsFixed(1)} A  ·  ${lengte.toStringAsFixed(0)} m';
  String get gewijzigd => isNL ? 'Gewijzigd' : 'Modified';
  String get geen => isNL ? 'geen' : 'none';
  String get projectKopieerAlles => isNL ? 'Kopieer alle berekeningen' : 'Copy all calculations';
  String get snackProjectGekopieerd => isNL ? 'Berekeningen gekopieerd' : 'Calculations copied';
  String get projectRapportHeader => isNL ? 'PROJECT RAPPORT' : 'PROJECT REPORT';
  String get projectRapportGeen => isNL ? 'Geen berekeningen in dit project.' : 'No calculations in this project.';

  // ── GEBRUIKERS ────────────────────────────────────────────────────────────
  String get gebruikerSelectieTitel => isNL ? 'Wie ben jij?' : 'Who are you?';
  String get gebruikerSelectieLeeg => isNL
      ? 'Nog geen gebruikers.\nMaak een nieuw profiel aan.'
      : 'No users yet.\nCreate a new profile.';
  String get gebruikerNieuw => isNL ? 'Nieuw profiel' : 'New profile';
  String get gebruikerNaam => isNL ? 'Naam' : 'Name';
  String get gebruikerHernoemen => isNL ? 'Hernoemen' : 'Rename';
  String get gebruikerVerwijderen => isNL ? 'Profiel verwijderen' : 'Delete profile';
  String get gebruikerVerwijderenVraag => isNL
      ? 'Weet je zeker dat je dit profiel wilt verwijderen? Alle projecten en berekeningen van dit profiel gaan verloren.'
      : 'Are you sure you want to delete this profile? All projects and calculations for this profile will be lost.';
  String get gebruikerWisselen => isNL ? 'Wisselen van gebruiker' : 'Switch user';
  String get gebruikerActief => isNL ? 'Actief profiel' : 'Active profile';

  // ── LEGGINGSWIJZE LABELS ─────────────────────────────────────────────────
  String get leggingA1 => isNL
      ? 'A1  — In isolerende buis, ingebouwd in thermisch isolerende wand'
      : 'A1  — In insulating conduit, built into thermally insulating wall';
  String get leggingA2 => isNL
      ? 'A2  — In isolerende buis, ingebouwd in gemetselde wand'
      : 'A2  — In insulating conduit, built into masonry wall';
  String get leggingB1 => isNL
      ? 'B1  — In kabelkanaal/buis op/in wand (meerkabelig)'
      : 'B1  — In cable duct/conduit on/in wall (multi-core)';
  String get leggingB2 => isNL
      ? 'B2  — In kabelkanaal/buis op/in wand (eénkabelig)'
      : 'B2  — In cable duct/conduit on/in wall (single-core)';
  String get leggingC => isNL
      ? 'C   — Aanliggend aan wand/plafond (direct op oppervlak)'
      : 'C   — Clipped to wall/ceiling (directly on surface)';
  String get leggingD1 => isNL
      ? 'D1  — Direct ingegraven (in grond)'
      : 'D1  — Direct buried (in ground)';
  String get leggingD2 => isNL ? 'D2  — In buis ingegraven' : 'D2  — Buried in conduit';
  String get leggingE => isNL
      ? 'E   — In vrije lucht (1 D van oppervlak)'
      : 'E   — In free air (1 D from surface)';
  String get leggingF => isNL ? 'F   — Op kabelgoot (touching)' : 'F   — On cable tray (touching)';
  String get leggingG => isNL ? 'G   — Op kabelgoot (spaced, 1 D)' : 'G   — On cable tray (spaced, 1 D)';

  // ── SYSTEEMTYPE LABELS ───────────────────────────────────────────────────
  String get systAc1Fase => 'AC 1-fase (L + N)';
  String get systAc3Fase => 'AC 3-fase (3L + PE)';
  String get systDc2Draad => 'DC 2-draad (+ / −)';
  String get systDcAarde => isNL ? 'DC met aardretour' : 'DC with earth return';

  // ── RAPPORT TEKST ────────────────────────────────────────────────────────
  String get rapportSamenvatting => isNL ? 'SAMENVATTING' : 'SUMMARY';
  String get rapportTitel => isNL ? 'KABELBEREKENINGSRAPPORT' : 'CABLE CALCULATION REPORT';
  String get rapportNorm => isNL
      ? 'Norm : IEC 60364-5-52 / IEC 60949 / NEN 1010'
      : 'Standard: IEC 60364-5-52 / IEC 60949 / NEN 1010';
  String get rapportDatum => isNL ? 'Datum' : 'Date';
  String get rapportInvoer => isNL ? '1. INVOER' : '1. INPUT';
  String get rapportKabel => isNL ? '2. GESELECTEERDE KABEL' : '2. SELECTED CABLE';
  String get rapportCF => isNL ? '3. CORRECTIEFACTOREN  (IEC 60364-5-52)' : '3. CORRECTION FACTORS  (IEC 60364-5-52)';
  String get rapportBelastbaarheid => isNL ? 'BELASTBAARHEID' : 'CURRENT CARRYING CAPACITY';
  String get rapportSpanningsval => isNL ? 'SPANNINGSVAL' : 'VOLTAGE DROP';
  String get rapportTemp => isNL ? 'TEMPERATUURVERHOGING  (vereenvoudigd model)' : 'TEMPERATURE RISE  (simplified model)';
  String get rapportKortsluit => isNL ? 'KORTSLUITVASTHEID  (IEC 60949)' : 'SHORT-CIRCUIT WITHSTAND  (IEC 60949)';
  String get rapportEindVoldoet => isNL ? 'EINDOORDEEL: VOLDOET AAN ALLE EISEN' : 'FINAL ASSESSMENT: MEETS ALL REQUIREMENTS';
  String get rapportEindGefaald => isNL ? 'EINDOORDEEL: CONTROLES GEFAALD' : 'FINAL ASSESSMENT: CHECKS FAILED';
  String get rapportFooter => isNL
      ? 'Berekend met: Kabelberekening — IEC 60364-5-52 / IEC 60949 / NEN 1010'
      : 'Calculated with: Cable Calculation — IEC 60364-5-52 / IEC 60949 / NEN 1010';
  String get rapportGeenKabel => isNL
      ? 'Geen kabel geselecteerd (zie fouten hieronder).'
      : 'No cable selected (see errors below).';
  String get rapportFouten => isNL ? 'FOUTEN:' : 'ERRORS:';
  String get rapportWaarschuwingen => isNL ? 'WAARSCHUWINGEN:' : 'WARNINGS:';
  String get rapportKortsluitNiet => isNL ? 'niet uitgevoerd' : 'not performed';
  String get rapportVoldoet => isNL ? 'VOLDOET' : 'PASSES';
  String get rapportOverschreden => isNL ? 'OVERSCHREDEN' : 'EXCEEDED';
  String get rapportFaalt => isNL ? 'FAALT' : 'FAILS';
  String get rapportWaarschuwingTemp => isNL ? 'WAARSCHUWING  (zie opmerkingen)' : 'WARNING  (see notes)';
  String get rapportAanliggend => isNL ? 'aanliggend' : 'touching';
  String get rapportGespreid => isNL ? 'gespreid' : 'spaced';
  String rapportCyclischIngeschakeld(int n, bool aanliggend) => isNL
      ? 'Ingeschakeld  (N=$n, ${aanliggend ? "aanliggend" : "gespreid"})'
      : 'Enabled  (N=$n, ${aanliggend ? "touching" : "spaced"})';
  String get rapportAanliggendKabeldiameter =>
      isNL ? 'aanliggend (= kabeldiameter)' : 'touching (= cable diameter)';
  String get rapportParallelKabels => isNL ? 'stuks per fase' : 'pcs per phase';
  String get rapportNulpuntsstroom => isNL ? 'nulpuntsstroom  I_N=' : 'neutral current  I_N=';
  String get rapportFasestroom => isNL ? 'fasestroom' : 'phase current';
  String get rapportMHogerBelasting => isNL
      ? 'M > 1 betekent hogere toelaatbare stroom bij niet-continue belasting'
      : 'M > 1 means higher permissible current for non-continuous loading';
  String rapportBelNrVan(int nr, String of) => isNL
      ? '$nr. BELASTBAARHEID'
      : '$nr. CURRENT CARRYING CAPACITY';
  String rapportSVNr(int nr) => isNL ? '$nr. SPANNINGSVAL' : '$nr. VOLTAGE DROP';
  String rapportTempNr(int nr) =>
      isNL ? '$nr. TEMPERATUURVERHOGING  (vereenvoudigd model)' : '$nr. TEMPERATURE RISE  (simplified model)';
  String rapportKSNr(int nr) =>
      isNL ? '$nr. KORTSLUITVASTHEID  (IEC 60949)' : '$nr. SHORT-CIRCUIT WITHSTAND  (IEC 60949)';
  String rapportCyclischNr(int nr) =>
      isNL ? '$nr. CYCLISCHE BELASTINGSFACTOR  (NEN IEC 60583-1:2002)' : '$nr. CYCLIC LOAD FACTOR  (NEN IEC 60583-1:2002)';
  String rapportHarmNr(int nr) =>
      isNL ? '$nr. HOGERE HARMONISCHEN  (NEN 1010 Bijlage 52.E.1)' : '$nr. HIGHER HARMONICS  (NEN 1010 Annex 52.E.1)';

  // ── BRONIMPEDANTIE INVOER ─────────────────────────────────────────────────
  String get sectBronimpedantie =>
      isNL ? 'Bronimpedantie  (transformator / net)' : 'Source Impedance  (transformer / grid)';
  String get lblBronimpedantie =>
      isNL ? 'Bronimpedantie berekenen' : 'Calculate Source Impedance';
  String get lblTransformatorSelectie =>
      isNL ? 'Transformatorselectie' : 'Transformer Selection';
  String get lblTransformatorHandmatig =>
      isNL ? 'Handmatige invoer Ucc / S_n' : 'Manual entry Ucc / S_n';
  String get lblTransformatorKva =>
      isNL ? 'Transformatorvermogen S_n' : 'Transformer Rating S_n';
  String get lblTransformatorUcc =>
      isNL ? 'Kortsluitspanning u_cc' : 'Short-circuit Voltage u_cc';
  String get lblAardingsstelsel =>
      isNL ? 'Aardingsstelsel' : 'Earthing System';
  String get lblSkNet =>
      isNL ? 'Kortsluitvermogen distributienet S_k' : 'Grid Short-circuit Power S_k';
  String get lblSkNetOneindig =>
      isNL ? 'Primair net: oneindig stijf (Z_net = 0)' : 'Primary grid: infinite stiff (Z_net = 0)';
  String get lblSkNetAangepast =>
      isNL ? 'Kortsluitvermogen primair net S_k' : 'Primary Grid Short-circuit Power S_k';
  String get hintTransformatorSelecteer =>
      isNL ? 'Kies transformator uit databank' : 'Select transformer from database';
  String get hintUccPct => isNL ? 'bijv. 4 of 6' : 'e.g. 4 or 6';
  String zbBerekend(String zbMohm) =>
      isNL ? 'Z_b = $zbMohm mΩ (per fase)' : 'Z_b = $zbMohm mΩ (per phase)';
  String ikBronInfo(String ik) =>
      isNL ? 'I_k bron (enkelfasig lus) ≈ $ik A' : 'I_k source (single-phase loop) ≈ $ik A';
  String get lblZUpstreamHandmatig =>
      isNL ? 'Handmatige Z_upstream (ketenberekening)' : 'Manual Z_upstream (chained calculation)';
  String get lblZUpstreamMohm =>
      isNL ? 'Stroomopwaartse lusimpedantie Z_upstream' : 'Upstream loop impedance Z_upstream';
  String get hintZUpstream =>
      isNL ? 'Kopieer Z_totaal van bovenliggende kabel' : 'Copy Z_total from parent cable';
  String zUpstreamInfo(String mohm) =>
      isNL ? 'Z_upstream = $mohm mΩ  (½ per fase = ${(double.parse(mohm) / 2).toStringAsFixed(2)} mΩ)'
           : 'Z_upstream = $mohm mΩ  (½ per phase = ${(double.parse(mohm) / 2).toStringAsFixed(2)} mΩ)';

  // Aardingsstelsel hints (NEN 1010 compliance)
  String aardingsstelselHint(String code) {
    switch (code) {
      case 'TN-S':
        return isNL
            ? 'TN-S: aparte N en PE. Standaard in Nederlandse laagspanningsnetten. '
                'Beveiliging via OCP (NEN 1010 §4.1.2.1).'
            : 'TN-S: separate N and PE. Standard in Dutch LV networks. '
                'Protection via OCP (NEN 1010 §4.1.2.1).';
      case 'TN-C':
        return isNL
            ? 'TN-C: gecombineerde PEN. Niet toegestaan bij A < 10 mm² Cu / '
                '16 mm² Al, noch in flexibele kabels (NEN 1010 §5.4.2).'
            : 'TN-C: combined PEN. Not permitted at A < 10 mm² Cu / '
                '16 mm² Al, nor in flexible cables (NEN 1010 §5.4.2).';
      case 'TN-C-S':
        return isNL
            ? 'TN-C-S: PEN in voeding, N+PE gescheiden in installatie. '
                'Gangbaar bij aansluiting op distributienet (NEN 1010 §3.7).'
            : 'TN-C-S: PEN in supply, N+PE separated in installation. '
                'Common at connection to distribution network (NEN 1010 §3.7).';
      case 'TT':
        return isNL
            ? 'TT: eigen aarding verbruiker. RCD (aardlekschakelaar) vereist voor '
                'foutbescherming; geen betrouwbare OCP-beveiliging (NEN 1010 §4.1.2.2).'
            : 'TT: own earth at consumer. RCD required for fault protection; '
                'OCP protection not reliable (NEN 1010 §4.1.2.2).';
      case 'IT':
        return isNL
            ? 'IT: isolé of hoge-impedantie aarding. Aardfoutdetectie/-bewaking '
                'verplicht (NEN 1010 §2.4.7). Eerste aardingsfout ≈ geen kortsluit.'
            : 'IT: isolated or high-impedance earth. Earth fault detection/monitoring '
                'mandatory (NEN 1010 §2.4.7). First earth fault ≈ no short-circuit.';
      default:
        return '';
    }
  }

  // ── BRONIMPEDANTIE RESULTATEN ─────────────────────────────────────────────
  String get sectBronimpedantieResultaat =>
      isNL ? 'Bronimpedantie  (IEC/TS 61200-53 / NEN 1010)' : 'Source Impedance  (IEC/TS 61200-53 / NEN 1010)';
  String get lblZbPerFase =>
      isNL ? 'Z_b  (transformator, per fase)' : 'Z_b  (transformer, per phase)';
  String get lblZbNet =>
      isNL ? 'Z_net  (primair net, verwezen naar sec.)' : 'Z_net  (primary grid, referred to sec.)';
  String get lblZbTotaal =>
      isNL ? 'Z_bron  (Z_trafo + Z_net, per fase)' : 'Z_source  (Z_trafo + Z_net, per phase)';
  String get lblIk3fBron =>
      isNL ? 'I_k3f  (driefasige kortsluitstroom bron)' : 'I_k3f  (3-phase fault current source)';
  String get lblIk1fBron =>
      isNL ? 'I_k1f  (enkelfasige lusstroom bron, TN)' : 'I_k1f  (single-phase loop current source, TN)';
  String get lblZKabelLus =>
      isNL ? 'Z_kabel  (lusimpedantie bij opgegeven lengte)' : 'Z_cable  (loop impedance at given length)';
  String get lblZTotaalLus =>
      isNL ? 'Z_totaal  (2×Z_b + Z_kabel, luslus)' : 'Z_total  (2×Z_b + Z_cable, loop)';
  String get lblIk1fEind =>
      isNL ? 'I_k1f  (enkelfasige lusstroom kabeluiteinde)' : 'I_k1f  (single-phase loop current cable end)';
  String get lblZUpstreamResultaat =>
      isNL ? 'Z_upstream  (handmatig, totale lus)' : 'Z_upstream  (manual, total loop)';
  String get bronimpedantieFormule =>
      isNL ? 'Z_b = (u_cc/100) × (U²_sec / S_n)  |  U_sec = 400 V  |  Primaire Z_net verwaarloosd (∞ Sk)'
           : 'Z_b = (u_cc/100) × (U²_sec / S_n)  |  U_sec = 400 V  |  Primary Z_net neglected (∞ Sk)';
  String get bronimpedantieFormuleNet =>
      isNL ? 'Z_b = Z_trafo + Z_net  |  Z_net = U²_sec / S_k_net'
           : 'Z_b = Z_trafo + Z_net  |  Z_net = U²_sec / S_k_net';

  // ── BOOMBEREKENING ────────────────────────────────────────────────────────
  String get navBoomberekening =>
      isNL ? 'Kabelnet (boomstructuur)' : 'Cable Network (tree)';
  String get titBoomScreen =>
      isNL ? 'Kabelnet' : 'Cable Network';
  String get btnNieuwKabelnet =>
      isNL ? 'Nieuw kabelnet' : 'New cable network';
  String get btnVerwijderBoom =>
      isNL ? 'Kabelnet verwijderen' : 'Delete network';
  String get btnHerberekenAlles =>
      isNL ? 'Herbereken alles' : 'Recalculate all';
  String get lblBoomNaam =>
      isNL ? 'Naam kabelnet' : 'Cable network name';
  String get lblBoomTransformator =>
      isNL ? 'Transformator (bron)' : 'Transformer (source)';
  String get lblLeidingNaam =>
      isNL ? 'Naam leiding' : 'Cable name';
  String get btnVoegLeidingToe =>
      isNL ? 'Leiding toevoegen' : 'Add cable';
  String get btnVoegKindToe =>
      isNL ? 'Kind toevoegen' : 'Add child';
  String get lblNietBerekend =>
      isNL ? 'Niet berekend' : 'Not calculated';
  String get lblNodenvereistBerekening =>
      isNL ? 'Ouder niet berekend — selecteer ouder en bereken eerst.'
           : 'Parent not calculated — select parent and calculate first.';
  String get sectBronimpedantieBoom =>
      isNL ? 'Bron (boom, automatisch)' : 'Source (tree, automatic)';
  String get boomUpstreamHint =>
      isNL ? 'Z_upstream automatisch overgenomen van bovenliggende leiding.'
           : 'Z_upstream automatically inherited from parent cable.';
  String get lblSelecteerNode =>
      isNL ? 'Selecteer een leiding in de boomstructuur links.'
           : 'Select a cable in the tree on the left.';
  String get lblGeenBoom =>
      isNL ? 'Nog geen kabelnet aangemaakt.' : 'No cable network yet.';
  String ikEindInfo(String ik) =>
      isNL ? 'I_k1f einde = $ik A' : 'I_k1f end = $ik A';

  // ── WINDKOELING (IEC 60287-2-1) ──────────────────────────────────────────
  String get lblWindkoeling =>
      isNL ? 'Windkoeling PV-goot (IEC 60287-2-1)' : 'Wind Cooling PV Tray (IEC 60287-2-1)';
  String get sectWindkoeling =>
      isNL ? 'Windkoeling  (IEC 60287-2-1 / NEN 1010)' : 'Wind Cooling  (IEC 60287-2-1 / NEN 1010)';
  String get lblWindsnelheid =>
      isNL ? 'Windsnelheid op dakoppervlak' : 'Wind Speed at Roof Surface';
  String get lblGootMetDeksel =>
      isNL ? 'Stalen deksel op kabelgoot' : 'Steel Lid on Cable Tray';
  String get lblDakOrientatie =>
      isNL ? 'Dakoriëntatie' : 'Roof Orientation';
  String get lblDakhelling =>
      isNL ? 'Dakhelling' : 'Roof Slope';
  String windkoelingInfo(String dtK, String tEffC) => isNL
      ? 'ΔT_wind = $dtK K  →  T_effectief = $tEffC °C  (IEC 60287-2-1 convectie-correctie)'
      : 'ΔT_wind = $dtK K  →  T_effective = $tEffC °C  (IEC 60287-2-1 convection correction)';

  String get lblPvLaagModel =>
      isNL ? 'PV-laagpositie zonneinstraling (IEC 60364-5-52)' : 'PV Layer Position Solar Irradiance (IEC 60364-5-52)';
  String get lblPvLaagPositie =>
      isNL ? 'Positie maatgevende kabel in stapel' : 'Position of determining cable in stack';
  String pvLaagHint(String dtK) => isNL
      ? 'Zoninstralingstoeslag: +$dtK K op omgevingstemperatuur  (vervangt handmatige zonlicht-ΔT)'
      : 'Solar irradiance correction: +$dtK K above ambient  (replaces manual sunlight ΔT)';
}
