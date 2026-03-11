# MijnKabelberekening — Code Documentation

> Auto-generated from Dart source files.
> Copyright (C) 2026 Jay Smeekes — Licensed under GPL-3.0.

---

## Table of Contents

- [lib/berekening/correctiefactoren.dart](#lib-berekening-correctiefactoren-dart)
- [lib/berekening/cyclisch.dart](#lib-berekening-cyclisch-dart)
- [lib/berekening/kortsluit.dart](#lib-berekening-kortsluit-dart)
- [lib/berekening/ontwerper.dart](#lib-berekening-ontwerper-dart)
- [lib/berekening/rapport.dart](#lib-berekening-rapport-dart)
- [lib/berekening/spanningsval.dart](#lib-berekening-spanningsval-dart)
- [lib/berekening/thermisch.dart](#lib-berekening-thermisch-dart)
- [lib/data/catalogus.dart](#lib-data-catalogus-dart)
- [lib/data/materiaal_data.dart](#lib-data-materiaal_data-dart)
- [lib/data/transformatoren.dart](#lib-data-transformatoren-dart)
- [lib/l10n/app_localizations.dart](#lib-l10n-app_localizations-dart)
- [lib/l10n/uitleg_localizations.dart](#lib-l10n-uitleg_localizations-dart)
- [lib/main.dart](#lib-main-dart)
- [lib/models/bundel_config.dart](#lib-models-bundel_config-dart)
- [lib/models/enums.dart](#lib-models-enums-dart)
- [lib/models/gebruiker.dart](#lib-models-gebruiker-dart)
- [lib/models/invoer.dart](#lib-models-invoer-dart)
- [lib/models/kabel_boom.dart](#lib-models-kabel_boom-dart)
- [lib/models/kabel_spec.dart](#lib-models-kabel_spec-dart)
- [lib/models/leiding_node.dart](#lib-models-leiding_node-dart)
- [lib/models/project.dart](#lib-models-project-dart)
- [lib/models/resultaten.dart](#lib-models-resultaten-dart)
- [lib/screens/boom_screen.dart](#lib-screens-boom_screen-dart)
- [lib/screens/catalogus_screen.dart](#lib-screens-catalogus_screen-dart)
- [lib/screens/correctiefactoren_screen.dart](#lib-screens-correctiefactoren_screen-dart)
- [lib/screens/gebruiker_selectie_screen.dart](#lib-screens-gebruiker_selectie_screen-dart)
- [lib/screens/home_screen.dart](#lib-screens-home_screen-dart)
- [lib/screens/invoer_screen.dart](#lib-screens-invoer_screen-dart)
- [lib/screens/kabel_toevoegen_dialog.dart](#lib-screens-kabel_toevoegen_dialog-dart)
- [lib/screens/privacy_screen.dart](#lib-screens-privacy_screen-dart)
- [lib/screens/project_detail_screen.dart](#lib-screens-project_detail_screen-dart)
- [lib/screens/projecten_screen.dart](#lib-screens-projecten_screen-dart)
- [lib/screens/resultaten_screen.dart](#lib-screens-resultaten_screen-dart)
- [lib/screens/uitleg_screen.dart](#lib-screens-uitleg_screen-dart)
- [lib/state/berekening_provider.dart](#lib-state-berekening_provider-dart)
- [lib/state/boom_provider.dart](#lib-state-boom_provider-dart)
- [lib/state/custom_catalogus_provider.dart](#lib-state-custom_catalogus_provider-dart)
- [lib/state/gebruikers_provider.dart](#lib-state-gebruikers_provider-dart)
- [lib/state/language_provider.dart](#lib-state-language_provider-dart)
- [lib/state/projecten_provider.dart](#lib-state-projecten_provider-dart)
- [lib/widgets/invoer_rij.dart](#lib-widgets-invoer_rij-dart)
- [lib/widgets/sectie_card.dart](#lib-widgets-sectie_card-dart)
- [test/widget_test.dart](#test-widget_test-dart)

---

## lib/berekening/correctiefactoren.dart {#lib-berekening-correctiefactoren-dart}

```
Path: lib/berekening/correctiefactoren.dart
```

### `class Correctiefactoren {`

Correctiefactoren voor toelaatbare stroom.
Alle factoren per IEC 60364-5-52.

Toelaatbare stroom: I_z = I_z0 · f_T · f_bundel · f_grond

### `class Correctiefactoren {`

### `static double fTemperatuur(`

Temperatuurcorrectiefactor — IEC 60364-5-52 §523.2

FORMULE (WORTEL, niet lineair!):
f_T = √[(θ_max − θ_amb) / (θ_max − θ_ref)]

Bij PVC (70°C, ref 30°C):
θ_amb=20°C → 1.118  |  θ_amb=40°C → 0.866  |  θ_amb=50°C → 0.707

#### `static double fTemperatuur(`

### `static double fHorizontaalBundeling(int nKabels) {`

Reductie voor n kabels naast elkaar in één laag.
IEC 60364-5-52 Tabel B.52.20

#### `static double fHorizontaalBundeling(int nKabels) {`

### `static double fVerticalStapeling(int nLagen) {`

Aanvullende reductiefactor voor gestapelde lagen.
IEC 60364-5-52 Tabel B.52.21

#### `static double fVerticalStapeling(int nLagen) {`

### `static double fLegging(Leggingswijze l, Isolatiemateriaal isolatie) =>`

Correctiefactor voor leggingswijze t.o.v. referentie Methode C.
IEC 60364-5-52 Tabel B.52.4 (gemiddelde factoren over typische doorsneden).

Methoden A1/A2/B1/B2: vaste factoren (kabeltemperatuur omgeving bepaalt).
Methoden E/F/G (vrije lucht): 1.25 voor PVC, 1.30 voor XLPE (=verhouding
izE/izC in catalogus, consistent met B.52.4 voor vrije-lucht condities).
Methoden C/D1/D2: 1.00 (catalogus-referentie; D1/D2: fGrond regelt grond).

#### `static double fLegging(Leggingswijze l, Isolatiemateriaal isolatie) =>`

### `static ({double fHarm, double iDesign, double iNeutraal}) fHarmonischen(`

Correctiefactor hogere harmonischen — NEN 1010 Bijlage 52.E.1 / IEC 60364-5-52 Tabel E.52.1.

Alleen toepasbaar bij 3-fase AC, 4- of 5-aderige kabels (4 belaste aders: 3L + N).

Bij dominante 3e harmonische geldt: I_N = 3 × I_h3 = 3 × (h3/100) × I_fase

| h3 (%)  | Grondslag   | f_harm |
|---------|-------------|--------|
| 0 – 15  | fasestroom  | 1,00   |
| 15 – 33 | fasestroom  | 0,86   |
| 33 – 45 | nulpuntsstroom | 0,86 |
| > 45    | nulpuntsstroom | 1,00 |

Returns record (fHarm, iDesign, iNeutraal):
fHarm     — correctiefactor op tabelwaarde (0.86 of 1.0)
iDesign   — maatgevende stroom voor kabelkeuze (fase of nulpuntsstroom)
iNeutraal — nulpuntsstroom I_N = 3 × (h3/100) × iFase

### `static double fBodemweerstand(double lambdaGrond) {`

Correctie bodemthermische weerstand voor grondkabels.
IEC 60364-5-52 Tabel B.52.16.
λ in K·m/W (typisch 0.5–2.5)

#### `static double fBodemweerstand(double lambdaGrond) {`


---

## lib/berekening/cyclisch.dart {#lib-berekening-cyclisch-dart}

```
Path: lib/berekening/cyclisch.dart
```

### `class CyclischeFactor {`

Cyclische reductiefactor M per NEN IEC 60583-1:2002 / NEN IEC 60287-2-1:2023.
Alleen van toepassing bij kabels in de grond (leggingswijze D1 of D2).

De factor M ≥ 1 geeft aan hoeveel meer stroom een kabel kan voeren
als de belasting niet continu maximaal is.

### `class CyclischeFactor {`

### `static double bereken({`

Berekent de cyclische factor M.

Parameters:
- profiel      : 24 waarden I/Imax per uur (uur 0..23), waarden 0..1
- De           : uitwendige diameter kabel/mantel in meters
- L            : legdiepte (m)
- xi           : thermische grondweerstand (K·m/W)
- tMax         : max geleidertemperatuur (°C)
- tGr          : grondtemperatuur (°C)
- W            : Joule-verliezen per kabel bij Tmax (W/m) = I²·R
- N            : aantal kringen in groep (≥1)
- dp1          : hart-op-hart afstand tussen kringen (m);
gebruik De voor aanliggende kabels (touching)
- aanliggend   : true → T4-formule voor aanliggende legging (touching);
false → gespreid (spaced)

Retourneert M ≥ 1.0; bij fouten of N=1 zonder naburige kringen: 1.0.

#### `static double bereken({`

#### `required List<double> profiel,`

#### `static double _gamma(double t, double de, double df, double delta,`

#### `static double _negEi(double x) {`

### `static double _t4Aanliggend(double u1, double xi) {`

T4 voor aanliggende kringen (touching) — NEN IEC 60287-2-1 formule.

#### `static double _t4Aanliggend(double u1, double xi) {`

### `static double _t4Gespreid(double u1, double xi) {`

T4 voor gespreide kringen (spaced) — NEN IEC 60287-2-1 formule.

#### `static double _t4Gespreid(double u1, double xi) {`

### `static double _diffusiviteit(double xi) {`

Lookup-tabel δ (m²/s) bij gegeven ξ (K·m/W) — conform Excel-tabel.

#### `static double _diffusiviteit(double xi) {`

#### `static const List<double> profielConstant = [`

#### `static const List<double> profielDagCyclus = [`


---

## lib/berekening/kortsluit.dart {#lib-berekening-kortsluit-dart}

```
Path: lib/berekening/kortsluit.dart
```

### `class Kortsluit {`

Thermische kortsluittoets per IEC 60949.

A_min = I_k · √t / k     [mm²]
ΔT    = (I_k² · t) / (k² · A²)

### `class Kortsluit {`

#### `static double kWaarde(Geleidermateriaal g, Isolatiemateriaal i) =>`

### `static double minDoorsnede(`

Minimale doorsnede vanuit kortsluitstroom.

#### `static double minDoorsnede(`

### `static double tempStijging(`

Adiabatische temperatuurstijging.

#### `static double tempStijging(`


---

## lib/berekening/ontwerper.dart {#lib-berekening-ontwerper-dart}

```
Path: lib/berekening/ontwerper.dart
```

### `class KabelOntwerper {`

Orkestreert de volledige kabelberekening.

Workflow:
1. Valideer invoer
2. Bepaal correctiefactoren
3. Bepaal min. doorsnede vanuit kortsluit
4. Zoek kleinste geschikte kabel (iteratief)
5. Bereken spanningsval
6. Bereken temperatuurstijging
7. Kortsluittoets
8. Eindoordeel

### `class KabelOntwerper {`

#### `Resultaten bereken() {`

#### `double mVoorKabel(KabelSpec k) {`


---

## lib/berekening/rapport.dart {#lib-berekening-rapport-dart}

```
Path: lib/berekening/rapport.dart
```

#### `String berekeningRapportTekst(Invoer inv, Resultaten r, AppLocalizations l10n) {`

#### `void lijn([int n = 64]) => buf.writeln('─' * n);`

#### `void titel(String t) { buf.writeln(); lijn(); buf.writeln(t); lijn(); }`

#### `void rij(String label, String waarde) =>`

#### `? switch (gpkR) {`

#### `? switch (gpkK) {`


---

## lib/berekening/spanningsval.dart {#lib-berekening-spanningsval-dart}

```
Path: lib/berekening/spanningsval.dart
```

### `class Spanningsval {`

Spanningsvalberekeningen voor AC en DC.

1-fase AC:  ΔU = 2·I·L·(R·cosφ + X·sinφ)   [factor 2 voor retour!]
3-fase AC:  ΔU = √3·I·L·(R·cosφ + X·sinφ)
DC 2-draad: ΔU = 2·I·R_DC·L
DC aardret: ΔU = I·R_DC·L

### `class Spanningsval {`

### `static double _rOpTemp(double rPerKm20C, Geleidermateriaal gel, double t) {`

Corrigeert AC-weerstand van 20°C naar bedrijfstemperatuur.

#### `static double _rOpTemp(double rPerKm20C, Geleidermateriaal gel, double t) {`

### `static (double, double) bereken(Invoer invoer, KabelSpec kabel,`

Berekent (ΔU_volt, ΔU_procent) voor het gegeven systeem.
[iOverride] vervangt invoer.effectieveStroom (gebruik voor parallel kabels: I/n).


---

## lib/berekening/thermisch.dart {#lib-berekening-thermisch-dart}

```
Path: lib/berekening/thermisch.dart
```

### `class Thermisch {`

Vereenvoudigd thermisch model (IEC 60287 benadering).

### `class Thermisch {`

#### `static double i2rVerlies(double I, double rPerM) => I * I * rPerM;`

### `static double tempStijgingLucht(double pPerM, double buitendiameterMm) {`

Temperatuurstijging in lucht via vrije convectie.
h_conv ≈ 10 W/(m²·K), omtrek = π·D

#### `static double tempStijgingLucht(double pPerM, double buitendiameterMm) {`

### `static double tempStijgingGrond(`

Temperatuurstijging in grond (IEC 60287-2-1 vereenvoudigd).
T_aard = (λ/2π)·ln(4u/d)

#### `static double tempStijgingGrond(`

### `static double rDcOpTemp(KabelSpec kabel) {`

Berekent R_dc per meter bij bedrijfstemperatuur.

#### `static double rDcOpTemp(KabelSpec kabel) {`


---

## lib/data/catalogus.dart {#lib-data-catalogus-dart}

```
Path: lib/data/catalogus.dart
```

#### `List<double> standaardDoorsnedes(Geleidermateriaal g) {`

### `List<int> adersOpties(Systeemtype s) => switch (s) {`

Beschikbare ader-aantallen per systeemtype.

#### `List<int> adersOpties(Systeemtype s) => switch (s) {`

### `int defaultAders(Systeemtype s) => switch (s) {`

Standaard aantal aders voor een systeemtype.

#### `int defaultAders(Systeemtype s) => switch (s) {`

### `String adersLabel(int n) => switch (n) {`

Leesbaar label voor het ader-aantal.

#### `String adersLabel(int n) => switch (n) {`

### `String _fa(double a) => a % 1 == 0 ? '${a.toInt()}' : '$a';`

Doorsnede-formatter: "1.5" of "25" (geen onnodige decimaal).

#### `String _fa(double a) => a % 1 == 0 ? '${a.toInt()}' : '$a';`


---

## lib/data/materiaal_data.dart {#lib-data-materiaal_data-dart}

```
Path: lib/data/materiaal_data.dart
```

### `class IsolatieProp {`

Isolatie-eigenschappen per IEC 60502 / 60228.

### `class IsolatieProp {`

### `class GeleiderProp {`

Geleider-eigenschappen: ρ₂₀ in Ω·mm²/m, α₂₀ in 1/K.

### `class GeleiderProp {`

#### `double rhoOpTemp(double t) => rho20 * (1 + alpha20 * (t - 20));`

### `double rDc(double doorsnedemm2, double lengteM, {double t = 20}) {`

DC-weerstand: R = ρ(T) · L / A  [Ω]

#### `double rDc(double doorsnedemm2, double lengteM, {double t = 20}) {`

### `double iec60228R20PerM(Geleidermateriaal geleider, double doorsnedemm2) {`

R20 per meter per NEN-EN-IEC 60228:2005 Tabel 1 [Ω/m].
Valt terug op soortelijke weerstand als doorsnede niet in de tabel staat.

#### `double iec60228R20PerM(Geleidermateriaal geleider, double doorsnedemm2) {`


---

## lib/data/transformatoren.dart {#lib-data-transformatoren-dart}

```
Path: lib/data/transformatoren.dart
```

### `class TransformatorSpec {`

Specificatie van een distributietransformator (10 kV / 0,4 kV).
Conform IEC 60076-5 en Nederlandse distributienetwerk-standaard.

### `class TransformatorSpec {`

### `double zbOhm({double uSecV = 400.0}) =>`

Kortsluitimpedantie per fase, verwezen naar secundaire zijde (0,4 kV) [Ω].

Z_b = (u_cc / 100) × (U²_sec / S_n)

Primaire impedantie wordt verwaarloosd (stijf netwerk / ∞ Sk).

#### `double zbOhm({double uSecV = 400.0}) =>`

### `class BronImpedantie {`

Hulpfuncties voor bronimpedantieberekening.

### `class BronImpedantie {`

### `static double ik3f({required double zbOhm, required double uLlV}) =>`

Driefasige kortsluitstroom aan bron [A].
I_k3f = U_LL / (√3 × Z_b)

#### `static double ik3f({required double zbOhm, required double uLlV}) =>`

### `static double ik1fBron({required double zbOhm, required double uLnV}) =>`

Enkelfasige lus-kortsluitstroom aan bron [A] voor TN-stelsel.
I_k1f = U_LN / (2 × Z_b)   (fase + N/PE beide door transformator)

#### `static double ik1fBron({required double zbOhm, required double uLnV}) =>`

### `static double ik1fEind({`

Enkelfasige lus-kortsluitstroom aan kabeluiteinde [A].
I_k1f_eind = U_LN / (2×Z_b + Z_kabel_lus)

#### `static double ik1fEind({`

### `static double skMva({required double zbOhm, double uLlV = 400.0}) =>`

Kortsluitvermogen aan transformatorklemmen [MVA].
S_k = U_LL² / Z_b

#### `static double skMva({required double zbOhm, double uLlV = 400.0}) =>`

### `static double zNetOhm({required double skNetMva, double uSecV = 400.0}) =>`

Netwerkimpedantie verwezen naar secundaire zijde [Ω] (bij eindig Sk_net).
Z_net = U_sec² / S_k_net

#### `static double zNetOhm({required double skNetMva, double uSecV = 400.0}) =>`


---

## lib/l10n/app_localizations.dart {#lib-l10n-app_localizations-dart}

```
Path: lib/l10n/app_localizations.dart
```

### `extension AppLocalizationsExt on BuildContext {`

### `class AppLocalizations {`

#### `String singelTotaalLabel(int nParallel, int geleidersPerKring) => isNL`

#### `String parallelTotaalLabel(String iTotaal, int nParallel, String iPerKabel) =>`

#### `String kabeldiameterInfo(String d) {`

#### `String bundelTotaalInfo(int totaal, int r, int c) => isNL`

#### `String _twiceD(String d) {`

#### `String iPerKabelLabel(String i) => isNL ? 'I per kabel: $i A' : 'I per cable: $i A';`

#### `String hartOpHartAanliggend(String d) =>`

#### `String hartOpHart2xd(String d) =>`

#### `String kabelsParallel(int n) => isNL ? '$n kabels parallel' : '$n cables parallel';`

#### `String catalogusLegenda(int aders) => isNL`

#### `String dlgKabelVerwijderenInhoud(String naam) => isNL`

#### `String grondsoortLabel(double lam) {`

#### `String cyclischProfielNaam(String naam) {`

#### `static const List<String> privacy1BulletsNL = ['Naam', 'E-mailadres', 'Telefoonnummer', 'Locatiegegevens', 'IP-adres', 'Accountinformatie'];`

#### `static const List<String> privacy1BulletsEN = ['Name', 'Email address', 'Phone number', 'Location data', 'IP address', 'Account information'];`

#### `static const List<String> privacy2BulletsNL = ['analytics- of trackingdiensten', 'advertentienetwerken', 'cookies of vergelijkbare technologieën', 'externe servers voor gegevensopslag'];`

#### `static const List<String> privacy2BulletsEN = ['analytics or tracking services', 'advertising networks', 'cookies or similar technologies', 'external servers for data storage'];`

#### `String berekeningen(int n) => isNL`

#### `String berekeningSamenvatting(String systeem, double stroom, double lengte) =>`

#### `String rapportCyclischIngeschakeld(int n, bool aanliggend) => isNL`

#### `String rapportBelNrVan(int nr, String of) => isNL`

#### `String rapportSVNr(int nr) => isNL ? '$nr. SPANNINGSVAL' : '$nr. VOLTAGE DROP';`

#### `String rapportTempNr(int nr) =>`

#### `String rapportKSNr(int nr) =>`

#### `String rapportCyclischNr(int nr) =>`

#### `String rapportHarmNr(int nr) =>`

#### `String zbBerekend(String zbMohm) =>`

#### `String ikBronInfo(String ik) =>`

#### `String zUpstreamInfo(String mohm) =>`

#### `String aardingsstelselHint(String code) {`

#### `String ikEindInfo(String ik) =>`


---

## lib/l10n/uitleg_localizations.dart {#lib-l10n-uitleg_localizations-dart}

```
Path: lib/l10n/uitleg_localizations.dart
```

### `extension UitlegLocalizations on AppLocalizations {`

Extension met alle vertalingen voor uitleg_screen.dart

### `extension UitlegLocalizations on AppLocalizations {`


---

## lib/main.dart {#lib-main-dart}

```
Path: lib/main.dart
```

#### `void main() async {`

### `class KabelberekeningApp extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _AppRouter extends StatelessWidget {`

Switches between GebruikerSelectieScreen and HomeScreen based on
whether a user is active. This is the sole widget that watches
GebruikersProvider for routing purposes — keeping MaterialApp.home
constant avoids the "_dependents.isEmpty" assertion.

### `class _AppRouter extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/models/bundel_config.dart {#lib-models-bundel_config-dart}

```
Path: lib/models/bundel_config.dart
```

### `class BundelConfig {`

Bundel-configuratie voor meerdere kabels (rechthoekige stapeling).
De bundelfactoren worden berekend door de Correctiefactoren-klasse in berekening/.

### `class BundelConfig {`


---

## lib/models/enums.dart {#lib-models-enums-dart}

```
Path: lib/models/enums.dart
```

### `enum Aardingsstelsel {`

Aardingsstelsel conform NEN 1010 / IEC 60364-1 §312.

### `enum Aardingsstelsel {`

### `enum Systeemtype {`

### `enum Geleidermateriaal {`

### `enum Isolatiemateriaal {`

### `enum Leggingswijze {`

### `enum BeveiligingType {`

#### `double berekenIa(double waarde) {`

### `double _ggOpzoeken(double inA, Map<double, double> tabel) {`

Lineaire interpolatie/extrapolatie op gesorteerde tabel.

#### `double _ggOpzoeken(double inA, Map<double, double> tabel) {`


---

## lib/models/gebruiker.dart {#lib-models-gebruiker-dart}

```
Path: lib/models/gebruiker.dart
```

### `class Gebruiker {`

#### `Gebruiker copyWith({String? naam}) => Gebruiker(`


---

## lib/models/invoer.dart {#lib-models-invoer-dart}

```
Path: lib/models/invoer.dart
```

### `class Invoer {`

Volledige invoer voor de kabelberekening.

### `class Invoer {`

#### `Invoer copyWith({`


---

## lib/models/kabel_boom.dart {#lib-models-kabel_boom-dart}

```
Path: lib/models/kabel_boom.dart
```

### `class KabelBoom {`

Een kabelnet-boomstructuur met één gedeelde bronimpedantie.
De bronimpedantie-instellingen gelden voor de hele boom; elke [LeidingNode]
erft de stroomopwaartse lusimpedantie automatisch van zijn ouderknoop.

### `class KabelBoom {`

### `double zbOhm(double spanningV) {`

Bronimpedantie [Ω] per fase bij de gegeven spanning [V].

#### `double zbOhm(double spanningV) {`

### `double ik3fBron(double spanningV) {`

Driefasige kortsluitstroom aan de bron [A] (informatief).

#### `double ik3fBron(double spanningV) {`

#### `KabelBoom copyWith({`


---

## lib/models/kabel_spec.dart {#lib-models-kabel_spec-dart}

```
Path: lib/models/kabel_spec.dart
```

### `class KabelSpec {`

Kabelspecificatie uit catalogus.
Stroomwaarden gelden voor θ_amb = 30°C.
Belaste aders: 1–2 aderige kabels → 2 belaste aders; ≥3 aderige → 3 belaste aders.

### `class KabelSpec {`


---

## lib/models/leiding_node.dart {#lib-models-leiding_node-dart}

```
Path: lib/models/leiding_node.dart
```

### `class LeidingNode {`

Eén kabel in de kabelnet-boomstructuur.
Slaat de door de gebruiker ingestelde [invoer] op (zonder upstream-Z —
die wordt altijd dynamisch berekend vanuit de ouderknoop).
[resultaten] zijn geldig na de laatste berekening; null = nog niet berekend.

### `class LeidingNode {`

#### `LeidingNode copyWith({`

### `Map<String, dynamic> toJson() => {`

Serialisatie: resultaten worden NIET opgeslagen (herberekend bij laden).


---

## lib/models/project.dart {#lib-models-project-dart}

```
Path: lib/models/project.dart
```

### `class OpgeslaanBerekening {`

Een opgeslagen berekening binnen een project (snapshot van invoer).

### `class OpgeslaanBerekening {`

### `class Project {`

Een project dat meerdere berekeningen groepeert.

### `class Project {`

#### `Project copyWith({`


---

## lib/models/resultaten.dart {#lib-models-resultaten-dart}

```
Path: lib/models/resultaten.dart
```

### `class Resultaten {`

Volledige berekeningsresultaten.

### `class Resultaten {`


---

## lib/screens/boom_screen.dart {#lib-screens-boom_screen-dart}

```
Path: lib/screens/boom_screen.dart
```

### `class BoomScreen extends StatefulWidget {`

#### `State<BoomScreen> createState() => _BoomScreenState();`

### `class _BoomScreenState extends State<BoomScreen> {`

#### `void initState() {`

#### `void dispose() {`

#### `void _onBerekeningChange() {`

#### `void _selecteerNode(String nodeId) {`

#### `Future<void> _voegRootToe() async {`

#### `Future<void> _voegKindToe(String parentId) async {`

#### `Future<void> _verwijderNode(String nodeId) async {`

#### `Future<String?> _vraagNaam(BuildContext ctx, String titel) async {`

#### `Widget build(BuildContext context) {`

#### `? _geenBoom(l10n)`

#### `Widget _geenBoom(AppLocalizations l10n) => Center(`

#### `Future<void> _maakNieuwKabelnet(BuildContext ctx) async {`

#### `Widget _boomLayout(`

#### `Widget _bronHeader(BuildContext context, KabelBoom boom) {`

#### `Widget _nodeItem(`

#### `? Text(context.l10n.ikEindInfo(ik1f.toStringAsFixed(0)),`

#### `Widget _geenSelectie(AppLocalizations l10n) => Center(`

#### `void _toonBronConfigDialog(BuildContext context, KabelBoom boom) {`

### `class _BronConfigDialog extends StatefulWidget {`

#### `State<_BronConfigDialog> createState() => _BronConfigDialogState();`

### `class _BronConfigDialogState extends State<_BronConfigDialog> {`

#### `void initState() {`

#### `Widget build(BuildContext context) {`


---

## lib/screens/catalogus_screen.dart {#lib-screens-catalogus_screen-dart}

```
Path: lib/screens/catalogus_screen.dart
```

### `class CatalogusScreen extends StatefulWidget {`

#### `State<CatalogusScreen> createState() => _CatalogusScreenState();`

### `class _CatalogusScreenState extends State<CatalogusScreen> {`

#### `Future<void> _toevoegen() async {`

#### `Future<void> _verwijder(KabelSpec kabel) async {`

#### `Widget build(BuildContext context) {`

#### `Widget _buildTabel(ThemeData theme, List<(KabelSpec, bool)> rijen, AppLocalizations l10n) {`

#### `? Row(`

#### `Future<void> _bewerken(KabelSpec kabel) async {`

#### `String _fmtA(double v) =>`

### `class _FilterSegment<T> extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/screens/correctiefactoren_screen.dart {#lib-screens-correctiefactoren_screen-dart}

```
Path: lib/screens/correctiefactoren_screen.dart
```

### `class CorrectiefactorenScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `Widget _bron(BuildContext context, String tekst) => Text(`

### `class _TemperatuurSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `List<DataRow> _buildRows(ThemeData theme) {`

#### `? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)`

#### `TextStyle? _kleurStijl(double? f, ThemeData theme) {`

### `class _BundelingSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)`

### `class _StapelingSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)`

### `class _BodemweerstandSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)`

### `class _CyclischeSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `DataRow _mRij(ThemeData theme, String naam, double piek, double mu, double m, AppLocalizations l10n) {`

#### `? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)`

### `class _HarmonischenSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)`

#### `? TextStyle(color: theme.colorScheme.tertiary)`

#### `? TextStyle(color: theme.colorScheme.error)`

#### `Widget _legenda(ThemeData theme) {`

#### `Widget _legendaItem(ThemeData theme, Color? kleur, String label) {`


---

## lib/screens/gebruiker_selectie_screen.dart {#lib-screens-gebruiker_selectie_screen-dart}

```
Path: lib/screens/gebruiker_selectie_screen.dart
```

### `class GebruikerSelectieScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? Center(`

#### `static Future<void> _toonNieuwGebruikerDialog(`

### `class _GebruikerTegel extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _MenuKnop extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `await _hernoemen(context);`

#### `await _verwijderen(context);`

#### `Future<void> _hernoemen(BuildContext context) async {`

#### `Future<void> _verwijderen(BuildContext context) async {`

### `enum _MenuActie { hernoemen, verwijderen }`


---

## lib/screens/home_screen.dart {#lib-screens-home_screen-dart}

```
Path: lib/screens/home_screen.dart
```

### `class HomeScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `Widget _catalogusKnop(BuildContext context) => IconButton(`

#### `Widget _correctiefactorenKnop(BuildContext context) => IconButton(`

#### `Widget _uitlegKnop(BuildContext context) => IconButton(`

#### `Widget _privacyKnop(BuildContext context) => IconButton(`

#### `Widget _projectenKnop(BuildContext context) => IconButton(`

#### `Widget _boomKnop(BuildContext context) => IconButton(`

### `class _GebruikerKnop extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `Widget _taalKnop(BuildContext context) {`

### `class _BreedLayout extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _SmalLayout extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/screens/invoer_screen.dart {#lib-screens-invoer_screen-dart}

```
Path: lib/screens/invoer_screen.dart
```

### `class InvoerScreen extends StatefulWidget {`

#### `State<InvoerScreen> createState() => _InvoerScreenState();`

### `class _InvoerScreenState extends State<InvoerScreen> {`

#### `void initState() {`

#### `void didChangeDependencies() {`

#### `void _initFrom(Invoer inv) {`

#### `static List<int> _geleidersOpties(Systeemtype s) =>`

#### `static int _geleidersDefault(Systeemtype s) =>`

#### `static String _geleidersLabel(int n, Systeemtype s) {`

#### `void _update(Invoer nieuw) {`

#### `void _mcbAutoVulKortsluit(Invoer nieuw) {`

#### `void _bereken() {`

#### `String _leggingLabel(Leggingswijze l, AppLocalizations l10n) {`

#### `Widget build(BuildContext context) {`

#### `? _boomUpstreamInfo()`

#### `Widget _systeemSectie() {`

#### `? _geleidersDefault(v)`

#### `Widget _belastingSectie() {`

#### `Widget _kabelSectie() {`

#### `? _geleidersDefault(_inv.systeem)`

#### `Widget _omgevingSectie() {`

#### `Widget _bundelSectie() {`

#### `Widget _cyclischSectie() {`

#### `void setProfiel(List<double> p) =>`

#### `Widget _profielGrid(List<double> profiel, AppLocalizations l10n) {`

#### `Widget _uurVeld(int uur, double waarde, ValueChanged<double> onChanged) {`

#### `Widget _eisenSectie() {`

#### `Widget _bronimpedantieToggle() {`

#### `Widget _boomUpstreamInfo() {`

#### `Widget _berekenKnop() => SizedBox(`

#### `Widget _kortsluitSectie() {`

#### `Widget _maxLengteSectie() {`

#### `Widget _bronimpedantieSectie() {`

#### `Widget _harmonischenSectie() {`


---

## lib/screens/kabel_toevoegen_dialog.dart {#lib-screens-kabel_toevoegen_dialog-dart}

```
Path: lib/screens/kabel_toevoegen_dialog.dart
```

### `class KabelToevoegenDialog extends StatefulWidget {`

#### `State<KabelToevoegenDialog> createState() => _KabelToevoegenDialogState();`

### `class _KabelToevoegenDialogState extends State<KabelToevoegenDialog> {`

#### `void initState() {`

#### `void dispose() {`

#### `String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();`

#### `double _parseDouble(String s) => double.parse(s.replaceAll(',', '.'));`

#### `void _opslaan() {`

#### `Widget build(BuildContext context) {`

#### `Widget _sectieLabel(BuildContext context, String tekst) => Padding(`

#### `Widget _dropdownRij<T>({`

#### `required List<T> opties,`

#### `required ValueChanged<T> onChanged,`

#### `Widget _getalVeld({`

#### `Widget _tekstVeld({`

#### `String? _valideerPositief(String? v, AppLocalizations l10n) {`

#### `String? _valideerNietNegatief(String? v, AppLocalizations l10n) {`


---

## lib/screens/privacy_screen.dart {#lib-screens-privacy_screen-dart}

```
Path: lib/screens/privacy_screen.dart
```

### `class PrivacyScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _Sectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _BulletRij extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/screens/project_detail_screen.dart {#lib-screens-project_detail_screen-dart}

```
Path: lib/screens/project_detail_screen.dart
```

### `class ProjectDetailScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? Center(`

#### `static void _kopieerAlles(`

#### `? _trunc(res.kabel!.naam, 19).padRight(20)`

#### `static String _trunc(String s, int max) =>`

### `class _BerekeningTegel extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `Future<void> _laden(BuildContext context, Invoer invoer) async {`

#### `Future<void> _verwijderen(BuildContext context) async {`

#### `String _datumLabel(DateTime dt) {`


---

## lib/screens/projecten_screen.dart {#lib-screens-projecten_screen-dart}

```
Path: lib/screens/projecten_screen.dart
```

### `class ProjectenScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `? Center(`

#### `static Future<void> _toonNieuwProjectDialog(`

### `class _ProjectTegel extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `String _datumLabel(DateTime dt) {`

### `class _MenuKnop extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `await _hernoemen(context);`

#### `await _verwijderen(context);`

#### `Future<void> _hernoemen(BuildContext context) async {`

#### `Future<void> _verwijderen(BuildContext context) async {`

### `enum _MenuActie { hernoemen, verwijderen }`


---

## lib/screens/resultaten_screen.dart {#lib-screens-resultaten_screen-dart}

```
Path: lib/screens/resultaten_screen.dart
```

### `class ResultatenScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

#### `Widget _opslaanKnop(BuildContext context, AppLocalizations l10n) {`

#### `Future<void> _toonOpslaanDialog(`

#### `await _toonOpslaanDialog(context, l10n);`

#### `Widget _eindoordeel(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `Widget _kabelGegevens(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `String singelConfigLabel() {`

#### `Widget _correctiefactoren(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `Widget _belastbaarheid(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `else if (r.nParallel == 1)`

#### `Widget _bundelPosities(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `String margeStr(double m) =>`

#### `Color margeKleur(double m) =>`

#### `Widget kop(String tekst) => Expanded(`

#### `Widget cel(String tekst, {Color? kleur, bool vet = false}) => Expanded(`

#### `Widget rij(String label, String warm, String koud,`

#### `Widget _spanningsval(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `Widget _temperatuur(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `Widget _kortsluit(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `Widget _maxLengte(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `Widget _bronimpedantie(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

#### `String fmt(double ohm) {`

#### `String fmtA(double a) => a >= 1000`

#### `Widget rij(String label, String waarde, {bool vet = false, Color? kleur}) =>`

#### `bool isNL(AppLocalizations l10n) => l10n.isNL;`

#### `Widget _foutMeldingen(BuildContext ctx, Resultaten r, AppLocalizations l10n) =>`

#### `Widget _waarschuwingen(BuildContext ctx, Resultaten r, AppLocalizations l10n) =>`

#### `Widget _kopieerKnop(BuildContext ctx, Resultaten r, AppLocalizations l10n) {`

### `class _OpslaanInProjectDialog extends StatefulWidget {`

#### `State<_OpslaanInProjectDialog> createState() =>`

### `class _OpslaanInProjectDialogState extends State<_OpslaanInProjectDialog> {`

#### `void initState() {`

#### `void dispose() {`

#### `Widget build(BuildContext context) {`

### `class _NieuwProjectEnOpslaanDialog extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/screens/uitleg_screen.dart {#lib-screens-uitleg_screen-dart}

```
Path: lib/screens/uitleg_screen.dart
```

### `class UitlegScreen extends StatelessWidget {`

Uitlegpagina — hoe worden alle berekeningen uitgevoerd?

### `class UitlegScreen extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _Formule extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _Noot extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _Rij extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _OverzichtSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _StroombepaalSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _CorrectiefactorenSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _CyclischeSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _HarmonischenSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _KortsluitMinSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _KabelkeuzeSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _CatalogusWaardenSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _ThermischeKernSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _SpanningsvalSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _TemperatuurSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _KortsluitToetsSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _MaxLengteSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class _EindoordeelSectie extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/state/berekening_provider.dart {#lib-state-berekening_provider-dart}

```
Path: lib/state/berekening_provider.dart
```

### `class BerekeningProvider extends ChangeNotifier {`

#### `void setIsBoomModus(bool v) {`

### `void berekenMet(Invoer nieuw) {`

Slaat de nieuwe invoer op en voert de berekening altijd opnieuw uit.
Eén notifyListeners() zodat het scherm altijd ververst.

#### `void berekenMet(Invoer nieuw) {`

#### `void updateInvoer(Invoer nieuw) {`

#### `void reset() {`


---

## lib/state/boom_provider.dart {#lib-state-boom_provider-dart}

```
Path: lib/state/boom_provider.dart
```

### `class BoomProvider extends ChangeNotifier {`

#### `List<LeidingNode> rootNodes() =>`

#### `List<LeidingNode> childrenVan(String parentId) =>`

#### `LeidingNode? nodeById(String id) =>`

#### `Future<void> maakNieuweBoom(String naam) async {`

#### `await _slaOp();`

#### `void setActiefNode(String? id) {`

#### `Future<void> updateBoomConfig(KabelBoom nieuw) async {`

#### `await _slaOp();`

#### `Future<void> hernoemBoom(String naam) async {`

#### `await _slaOp();`

#### `Future<void> verwijderBoom() async {`

#### `await _slaOp();`

#### `Future<String> voegNodeToe({String? parentId, String naam = 'Leiding'}) async {`

#### `await _slaOp();`

#### `Future<void> hernoemNode(String nodeId, String naam) async {`

#### `await _slaOp();`

#### `Future<void> verwijderNode(String nodeId) async {`

#### `await _slaOp();`

### `Future<void> opslaanNodeResultaten(`

Sla invoer + resultaten op voor [nodeId].
Nakomelingen worden ongeldig verklaard (hun upstream-Z is veranderd).

#### `Future<void> opslaanNodeResultaten(`

#### `await _slaOp();`

#### `Future<void> herberekenAlles() async {`

#### `await _slaOp();`

### `Invoer invoerVoorNode(String nodeId) {`

Geeft de invoer voor [nodeId] aangevuld met de automatisch berekende
stroomopwaartse lusimpedantie en de bron-aardingsstelsel.

#### `Invoer invoerVoorNode(String nodeId) {`

#### `Future<void> laad() async {`

#### `Future<void> _slaOp() async {`

#### `int _nodeIdx(String nodeId) =>`

#### `Set<String> _alleNakomelingsIds(String nodeId) {`

### `double? _upstreamMohm(String nodeId) =>`

Upstream lus-Z [mΩ] voor [nodeId], op basis van [_boom!.nodes].

#### `double? _upstreamMohm(String nodeId) =>`

### `double? _upstreamMohmFromList(String nodeId, List<LeidingNode> nodes) {`

Upstream lus-Z [mΩ] voor [nodeId], op basis van een willekeurige [nodes]-lijst
(voor gebruik tijdens cascade-herberekening).

#### `double? _upstreamMohmFromList(String nodeId, List<LeidingNode> nodes) {`

#### `int diepteVan(String nodeId) {`


---

## lib/state/custom_catalogus_provider.dart {#lib-state-custom_catalogus_provider-dart}

```
Path: lib/state/custom_catalogus_provider.dart
```

### `class CustomCatalogusProvider extends ChangeNotifier {`

Beheert door de gebruiker toegevoegde kabels.
Custom kabels worden opgeslagen in SharedPreferences en bij opstarten
samengevoegd met de standaard [kabelCatalogus].

### `class CustomCatalogusProvider extends ChangeNotifier {`

#### `bool isCustom(`

### `Future<void> laad() async {`

Laad opgeslagen custom kabels en voeg ze toe aan [kabelCatalogus].

#### `Future<void> laad() async {`

#### `void _voegToeLokaal(KabelSpec kabel) {`

### `void voegToe(KabelSpec kabel) {`

Voeg een nieuwe kabel toe aan de catalogus en sla op.

#### `void voegToe(KabelSpec kabel) {`

### `void verwijder(KabelSpec kabel) {`

Verwijder een custom kabel en herstel eventuele standaard entry.

#### `void verwijder(KabelSpec kabel) {`

#### `Future<void> _sla() async {`


---

## lib/state/gebruikers_provider.dart {#lib-state-gebruikers_provider-dart}

```
Path: lib/state/gebruikers_provider.dart
```

### `class GebruikersProvider extends ChangeNotifier {`

#### `Future<void> laad() async {`

#### `Future<void> _slaOp() async {`

#### `Future<void> maakGebruiker(String naam) async {`

#### `await _slaOp();`

#### `await selecteerGebruiker(gebruiker.id);`

#### `Future<void> selecteerGebruiker(String id) async {`

#### `await _slaOp();`

#### `Future<void> wisselGebruiker() async {`

#### `await _slaOp();`

#### `Future<void> hernoemGebruiker(String id, String naam) async {`

#### `await _slaOp();`

#### `Future<void> verwijderGebruiker(String id) async {`

#### `await _slaOp();`


---

## lib/state/language_provider.dart {#lib-state-language_provider-dart}

```
Path: lib/state/language_provider.dart
```

### `class LanguageProvider extends ChangeNotifier {`

#### `Future<void> laad() async {`

#### `Future<void> setLocale(Locale locale) async {`


---

## lib/state/projecten_provider.dart {#lib-state-projecten_provider-dart}

```
Path: lib/state/projecten_provider.dart
```

### `class ProjectenProvider extends ChangeNotifier {`

#### `Future<void> laadVoorGebruiker(String gebruikerId) async {`

#### `void leegmaak() {`

#### `Future<void> _slaOp() async {`

#### `Future<void> maakProject(String naam) async {`

#### `await _slaOp();`

#### `Future<void> hernoemProject(String projectId, String nieuwNaam) async {`

#### `await _slaOp();`

#### `Future<void> verwijderProject(String projectId) async {`

#### `await _slaOp();`

#### `Future<void> voegBerekeningToe(`

#### `await _slaOp();`

#### `Future<void> verwijderBerekening(`

#### `await _slaOp();`


---

## lib/widgets/invoer_rij.dart {#lib-widgets-invoer_rij-dart}

```
Path: lib/widgets/invoer_rij.dart
```

### `class GetalVeld extends StatefulWidget {`

Label + TextFormField voor getallen.
Stateful zodat de TextEditingController synchroon blijft met [waarde]
wanneer de parent de waarde programmatisch wijzigt (bijv. na een reset).

### `class GetalVeld extends StatefulWidget {`

#### `State<GetalVeld> createState() => _GetalVeldState();`

### `class _GetalVeldState extends State<GetalVeld> {`

#### `void initState() {`

#### `void didUpdateWidget(covariant GetalVeld old) {`

#### `void dispose() {`

#### `Widget build(BuildContext context) {`

### `class DropdownRij<T> extends StatelessWidget {`

Label + DropdownButtonFormField.
Gebruikt [key: ValueKey(waarde)] zodat het FormField opnieuw wordt
aangemaakt — en de weergave wordt bijgewerkt — wanneer [waarde]
programmatisch wijzigt (bijv. na reset door systeemtype-wisseling).

### `class DropdownRij<T> extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class SchakelaarRij extends StatelessWidget {`

Schakelaar met label.

### `class SchakelaarRij extends StatelessWidget {`

#### `Widget build(BuildContext context) {`

### `class ResultaatRij extends StatelessWidget {`

Resultaatrij met label, waarde en optionele kleur.

### `class ResultaatRij extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## lib/widgets/sectie_card.dart {#lib-widgets-sectie_card-dart}

```
Path: lib/widgets/sectie_card.dart
```

### `class SectieCard extends StatelessWidget {`

#### `Widget build(BuildContext context) {`


---

## test/widget_test.dart {#test-widget_test-dart}

```
Path: test/widget_test.dart
```

#### `void main() {`


---

