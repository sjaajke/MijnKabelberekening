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

/// Handleiding-teksten (quickstart) voor handleiding_screen.dart.
extension HandleidingLocalizations on AppLocalizations {
  // ── ALGEMEEN ──────────────────────────────────────────────────────────────
  String get hdlTitel =>
      isNL ? 'Handleiding — Quickstart' : 'User Guide — Quick Start';

  String get hdlIntroTitel =>
      isNL ? 'Welkom bij MijnKabelberekening' : 'Welcome to MijnKabelberekening';

  String get hdlIntroTekst => isNL
      ? 'MijnKabelberekening dimensioneert installatiekabels en -leidingen '
        'conform NEN 1010 / IEC 60364-5-52. De app bepaalt automatisch de '
        'minimaal benodigde doorsnede en toetst spanningsval, temperatuur en '
        'kortsluitbeveiliging.\n\n'
        'Deze quickstart legt de basisbediening uit. Voor de achterliggende '
        'formules: zie de knop Berekeningswijze (📖) in de menubalk.'
      : 'MijnKabelberekening sizes installation cables and conductors in '
        'accordance with NEN 1010 / IEC 60364-5-52. The app automatically '
        'determines the minimum required cross-section and checks voltage drop, '
        'temperature and short-circuit protection.\n\n'
        'This quick start explains the basic operation. For the underlying '
        'formulas, see the Calculation Method button (📖) in the menu bar.';

  String get hdlIntroAfb =>
      isNL ? 'Hoofdscherm — Invoer links, Resultaten rechts'
           : 'Main screen — Input left, Results right';

  // ── STAP 1: SYSTEEM ───────────────────────────────────────────────────────
  String get hdlSysteemTitel =>
      isNL ? 'Stap 1 — Systeem' : 'Step 1 — System';

  String get hdlSysteemTekst => isNL
      ? 'Stel in de sectie Systeem het volgende in:\n\n'
        '• Spanning (V) — netspanning, bijv. 230 V (1-fase) of 400 V (3-fase)\n'
        '• Systeemtype — AC 1-fase, AC 3-fase of DC\n'
        '• Aantal aders — 2, 3, 4 of 5 (bepaalt de tabel-I_z)\n'
        '• Max. spanningsval (%) — norm: 3 % voor verlichting, 5 % voor kracht\n\n'
        'Tip: bij een 3-fasen circuit met één ader per fase kies je "1 ader '
        '(singel in 3-fase circuit)" — de app past dan automatisch de juiste '
        'I_z-kolom toe.'
      : 'Set the following in the System section:\n\n'
        '• Voltage (V) — mains voltage, e.g. 230 V (1-phase) or 400 V (3-phase)\n'
        '• System type — AC 1-phase, AC 3-phase or DC\n'
        '• Number of cores — 2, 3, 4 or 5 (determines the table I_z)\n'
        '• Max. voltage drop (%) — standard: 3 % for lighting, 5 % for power\n\n'
        'Tip: for a 3-phase circuit with one conductor per phase, choose '
        '"1 core (single in 3-phase circuit)" — the app automatically applies '
        'the correct I_z column.';

  String get hdlSysteemAfb =>
      isNL ? 'Systeemsectie — spanning, type en aders'
           : 'System section — voltage, type and cores';

  // ── STAP 2: BELASTING ─────────────────────────────────────────────────────
  String get hdlBelastingTitel =>
      isNL ? 'Stap 2 — Belasting' : 'Step 2 — Load';

  String get hdlBelastingTekst => isNL
      ? 'Voer de belasting in. Je kunt kiezen uit twee invoermethoden:\n\n'
        '• Stroom (A) — voer de belastingsstroom direct in\n'
        '• Vermogen (W of kW) + cosφ — de app berekent de stroom automatisch: '
        'I = P / (U · cosφ)\n\n'
        'Wissel met de schakelaar "Invoer via vermogen" bovenaan de sectie.\n\n'
        'Parallel kabels: stel "Aantal parallel kabels" in bij zware '
        'belastingen. De totaalstroom wordt dan gelijkmatig verdeeld.'
      : 'Enter the load. You can choose between two input methods:\n\n'
        '• Current (A) — enter the load current directly\n'
        '• Power (W or kW) + cosφ — the app calculates the current automatically: '
        'I = P / (U · cosφ)\n\n'
        'Switch with the "Input via power" toggle at the top of the section.\n\n'
        'Parallel cables: set "Number of parallel cables" for heavy loads. '
        'The total current is then distributed evenly.';

  String get hdlBelastingAfb =>
      isNL ? 'Belastingsectie — stroom of vermogen'
           : 'Load section — current or power';

  // ── STAP 3: KABEL ─────────────────────────────────────────────────────────
  String get hdlKabelTitel =>
      isNL ? 'Stap 3 — Kabel' : 'Step 3 — Cable';

  String get hdlKabelTekst => isNL
      ? 'Stel de kabelparameters in:\n\n'
        '• Geleider — Koper (Cu) of Aluminium (Al)\n'
        '• Isolatie — PVC (max. 70 °C) of XLPE/EPR (max. 90 °C)\n'
        '• Leidingwijze — bijv. in buis in wand (B1), op kabelgoot (E), '
        'direct in grond (D1). De leidingwijze bepaalt de correctiefactor '
        'f_legging en daarmee de belastbaarheid.\n'
        '• Lengte (m) — de werkelijke kabellengte (één richting)\n\n'
        'Doorsnede forceren: laat de schakelaar uit voor automatische keuze. '
        'Zet hem aan om een vaste doorsnede op te leggen — handig bij '
        'vervanging of uitbreiding.'
      : 'Set the cable parameters:\n\n'
        '• Conductor — Copper (Cu) or Aluminium (Al)\n'
        '• Insulation — PVC (max. 70 °C) or XLPE/EPR (max. 90 °C)\n'
        '• Installation method — e.g. in conduit in wall (B1), on cable tray (E), '
        'direct in ground (D1). The installation method determines the correction '
        'factor f_installation and hence the current capacity.\n'
        '• Length (m) — the actual cable length (one direction)\n\n'
        'Force cross-section: leave the toggle off for automatic selection. '
        'Switch it on to impose a fixed cross-section — useful for replacement '
        'or extension.';

  String get hdlKabelAfb =>
      isNL ? 'Kabelsectie — geleider, isolatie, leidingwijze en lengte'
           : 'Cable section — conductor, insulation, installation method and length';

  // ── STAP 4: BEREKEN ───────────────────────────────────────────────────────
  String get hdlBerekenTitel =>
      isNL ? 'Stap 4 — Bereken' : 'Step 4 — Calculate';

  String get hdlBerekenTekst => isNL
      ? 'Tik op de knop Bereken onderaan de invoerpagina (of tik op het '
        'tabblad Resultaten op een smal scherm).\n\n'
        'De app doorloopt automatisch alle stappen:\n'
        '① Correctiefactoren bepalen\n'
        '② Kleinste doorsnede selecteren (stroombelastbaarheid + kortsluiteis)\n'
        '③ Spanningsval berekenen\n'
        '④ Temperatuur toetsen\n'
        '⑤ Kortsluittoets en max. leidinglengte'
      : 'Tap the Calculate button at the bottom of the input page (or tap the '
        'Results tab on a narrow screen).\n\n'
        'The app automatically runs all steps:\n'
        '① Determine correction factors\n'
        '② Select smallest cross-section (current capacity + short-circuit requirement)\n'
        '③ Calculate voltage drop\n'
        '④ Check temperature\n'
        '⑤ Short-circuit check and max. cable length';

  String get hdlBerekenAfb =>
      isNL ? 'Knop Bereken onderaan het invoerpaneel'
           : 'Calculate button at the bottom of the input panel';

  // ── STAP 5: RESULTATEN ────────────────────────────────────────────────────
  String get hdlResultatenTitel =>
      isNL ? 'Stap 5 — Resultaten lezen' : 'Step 5 — Reading the Results';

  String get hdlResultatenTekst => isNL
      ? 'Het resultatenvenster toont de uitkomst per categorie:\n\n'
        '• Kabel — gekozen doorsnede (mm²), type en I_z gecorrigeerd\n'
        '• Correctiefactoren — f_T, f_legging, f_bundel, f_grond, f_totaal\n'
        '• Spanningsval — ΔU in volt en procent; groen = OK, rood = overschreden\n'
        '• Temperatuur — geleidertemperatuur bij bedrijfsstroom\n'
        '• Kortsluit — temperatuurstijging bij kortsluitstroom\n'
        '• Max. leidinglengte — maximale lengte voor werking beveiliging\n\n'
        'Groen vinkje = voldoet. Oranje driehoek = waarschuwing. '
        'Rood kruis = fout die de berekening ongeldig maakt.'
      : 'The results panel shows the outcome per category:\n\n'
        '• Cable — selected cross-section (mm²), type and corrected I_z\n'
        '• Correction factors — f_T, f_installation, f_bundle, f_ground, f_total\n'
        '• Voltage drop — ΔU in volts and percent; green = OK, red = exceeded\n'
        '• Temperature — conductor temperature at operating current\n'
        '• Short-circuit — temperature rise at short-circuit current\n'
        '• Max. cable length — maximum length for protection to operate\n\n'
        'Green tick = passes. Orange triangle = warning. '
        'Red cross = error that invalidates the calculation.';

  String get hdlResultatenAfb =>
      isNL ? 'Resultatenvenster met eindoordeel'
           : 'Results panel with final assessment';

  // ── EXTRA: BRONIMPEDANTIE ─────────────────────────────────────────────────
  String get hdlBronTitel =>
      isNL ? 'Extra — Bronimpedantie' : 'Extra — Source Impedance';

  String get hdlBronTekst => isNL
      ? 'Schakel Bronimpedantie aan (knop bovenaan de invoerpagina) voor een '
        'volledige kortsluitstroomberekening:\n\n'
        '• Kies een transformator uit de databank (50–2000 kVA) of voer '
        'u_cc en S_n handmatig in\n'
        '• Alternatief: voer R en X van de bronimpedantie direct in (mΩ)\n'
        '• Stel het aardingsstelsel in (TN-S, TN-C, TN-CS, TT of IT)\n'
        '• Optioneel: voer het netwerk-kortsluitvermogen Sk in (niet-oneindig net)\n\n'
        'De app berekent dan:\n'
        '  Z_b  — bronimpedantie [mΩ]\n'
        '  I_k3f — driefasige kortsluitstroom aan de bron [A]\n'
        '  I_k1f — enkelfasige kortsluitstroom aan het kabeluiteinde [A]\n\n'
        'De I_k1f aan het einde wordt gebruikt als effectieve kortsluitstroom '
        'voor de kortsluittoets en de max. leidinglengte.'
      : 'Switch on Source Impedance (button at the top of the input page) for '
        'a full short-circuit current calculation:\n\n'
        '• Choose a transformer from the database (50–2000 kVA) or enter '
        'u_cc and S_n manually\n'
        '• Alternative: enter R and X of the source impedance directly (mΩ)\n'
        '• Set the earthing system (TN-S, TN-C, TN-CS, TT or IT)\n'
        '• Optional: enter the network short-circuit power Sk (non-infinite grid)\n\n'
        'The app then calculates:\n'
        '  Z_b  — source impedance [mΩ]\n'
        '  I_k3f — three-phase short-circuit current at the source [A]\n'
        '  I_k1f — single-phase short-circuit current at the cable end [A]\n\n'
        'The I_k1f at the end is used as the effective short-circuit current '
        'for the short-circuit check and the maximum cable length.';

  String get hdlBronAfb =>
      isNL ? 'Bronimpedantie-sectie met transformatorkeuze en samenvatting'
           : 'Source impedance section with transformer selection and summary';

  // ── EXTRA: KABELNET ───────────────────────────────────────────────────────
  String get hdlKabelnetTitel =>
      isNL ? 'Extra — Kabelnet (boomberekening)' : 'Extra — Cable Network (Tree Calculation)';

  String get hdlKabelnetTekst => isNL
      ? 'Met de kabelnetfunctie (pictogram 🌳 in de menubalk) kun je meerdere '
        'leidingen in serie berekenen — bijv. voedingskabel → aftakking → eindgroep.\n\n'
        '① Maak een nieuw kabelnet aan via "Nieuw kabelnet"\n'
        '② Stel de bronimpedantie in het linkerpaneel in '
        '(transformator, aardingsstelsel, Sk-net)\n'
        '③ Voeg leidingen toe met de knop "+ Leiding toevoegen"\n'
        '④ Selecteer een leiding → vul de invoer in rechts → tik Bereken\n'
        '⑤ Voeg kindleidingen toe vanuit een berekende leiding '
        '(de kortsluitstroom aan het einde wordt automatisch doorgegeven)\n\n'
        'Opslaan en hergebruiken:\n\n'
        '⑥ Sla het kabelnet op in een project via het opslaan-icoon (💾) in de '
        'titelbalk. Kies een bestaand project uit de lijst.\n'
        '⑦ Open een opgeslagen kabelnet via het mapicoon (📁) → selecteer het '
        'project → tik op het kabelnet onder "Kabelnetten". Het hele net '
        '(alle leidingen + bronimpedantie) wordt hersteld en je kunt direct '
        'verder berekenen of leidingen toevoegen.\n\n'
        'Let op: het kabelnet wordt ook automatisch tijdelijk bewaard zolang je '
        'de app open hebt. Bij het aanmaken van een nieuw kabelnet gaat het '
        'huidige verloren als het niet in een project is opgeslagen.'
      : 'The cable network function (🌳 icon in the menu bar) lets you calculate '
        'multiple conductors in series — e.g. supply cable → branch → final circuit.\n\n'
        '① Create a new cable network via "New cable network"\n'
        '② Set the source impedance in the left panel '
        '(transformer, earthing system, Sk-network)\n'
        '③ Add conductors using the "+ Add conductor" button\n'
        '④ Select a conductor → fill in the input on the right → tap Calculate\n'
        '⑤ Add child conductors from a calculated conductor '
        '(the short-circuit current at the end is passed on automatically)\n\n'
        'Saving and reusing:\n\n'
        '⑥ Save the cable network to a project via the save icon (💾) in the '
        'title bar. Choose an existing project from the list.\n'
        '⑦ Open a saved cable network via the folder icon (📁) → select the '
        'project → tap the cable network under "Cable Networks". The entire '
        'network (all conductors + source impedance) is restored and you can '
        'continue calculating or adding conductors.\n\n'
        'Note: the cable network is also temporarily preserved as long as the '
        'app is open. Creating a new cable network will discard the current one '
        'if it has not been saved to a project.';

  String get hdlKabelnetAfb =>
      isNL ? 'Kabelnetscherm met boomstructuur links en invoer/resultaten rechts'
           : 'Cable network screen with tree structure left and input/results right';

  // ── EXTRA: PROJECTEN ──────────────────────────────────────────────────────
  String get hdlProjectenTitel =>
      isNL ? 'Extra — Projecten' : 'Extra — Projects';

  String get hdlProjectenTekst => isNL
      ? 'Sla berekeningen en kabelnetten op in projecten (mapicoon 📁 in de '
        'menubalk):\n\n'
        '• Maak een nieuw project aan via de + knop\n'
        '• Sla de huidige berekening op via "Opslaan in project" onderaan de '
        'resultatenkaart\n'
        '• Open een opgeslagen berekening door erop te tikken in het '
        'projectdetailscherm — alle invoervelden worden hersteld\n'
        '• Kabelnetten verschijnen apart onder de sectie Kabelnetten\n\n'
        'Tip: gebruik meerdere gebruikersprofielen (cirkel met initiaal in de '
        'menubalk) om berekeningen per persoon of project te scheiden.'
      : 'Save calculations and cable networks in projects (folder icon 📁 in '
        'the menu bar):\n\n'
        '• Create a new project with the + button\n'
        '• Save the current calculation via "Save to project" at the bottom of '
        'the results card\n'
        '• Open a saved calculation by tapping it in the project detail screen '
        '— all input fields are restored\n'
        '• Cable networks appear separately under the Cable Networks section\n\n'
        'Tip: use multiple user profiles (circle with initial in the menu bar) '
        'to separate calculations per person or project.';

  String get hdlProjectenAfb =>
      isNL ? 'Projectenlijst met opgeslagen berekeningen en kabelnetten'
           : 'Project list with saved calculations and cable networks';

  // ── TIPS ──────────────────────────────────────────────────────────────────
  String get hdlTipsTitel => isNL ? 'Handige tips' : 'Useful Tips';

  String get hdlTip1 => isNL
      ? '📖  Berekeningswijze — bekijk de volledige wiskundige onderbouwing '
        'via het boekicoon in de menubalk.'
      : '📖  Calculation Method — view the full mathematical basis via the '
        'book icon in the menu bar.';

  String get hdlTip2 => isNL
      ? '📊  Correctiefactoren — zie alle correctiefactortabellen (IEC 60364-5-52) '
        'via het rekenmachineicoon.'
      : '📊  Correction factors — see all correction factor tables (IEC 60364-5-52) '
        'via the calculator icon.';

  String get hdlTip3 => isNL
      ? '🌙  Donker thema — schakel het donkere thema in via het maan/zon-icoon.'
      : '🌙  Dark theme — switch to dark theme via the moon/sun icon.';

  String get hdlTip4 => isNL
      ? '🔁  Herbereken — wijzig een invoerveld en tik opnieuw op Bereken; '
        'de resultaten worden direct bijgewerkt.'
      : '🔁  Recalculate — modify an input field and tap Calculate again; '
        'the results are immediately updated.';

  String get hdlTip5 => isNL
      ? '🇳🇱/🇬🇧  Taal wisselen — tik op NL of EN in de menubalk.'
      : '🇳🇱/🇬🇧  Switch language — tap NL or EN in the menu bar.';
}
