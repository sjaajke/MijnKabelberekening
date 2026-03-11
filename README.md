# MijnKabelberekening

Flutter app voor het berekenen van kabeldoorsneden conform **IEC 60364-5-52** en **NEN 1010**.
Beschikbaar voor **Windows**, **macOS** en **iOS**.

---

## Functies

- Berekening van minimale kabeldoorsnede op basis van:
  - Belastingsstroom en omgevingstemperatuur
  - Correctiefactoren (bundeling, grond, temperatuur)
  - Maximale spanningsval
  - Kortsluitbeveiliging (thermisch en dynamisch)
- **Bronimpedantie module** — transformatorgegevens (50–2000 kVA) of handmatige invoer:
  - Kortsluitstroom aan de bron (Ik3f, Ik1f)
  - Kortsluitstroom aan het kabeluiteinde
  - Aardingsstelsel selectie (TN-S, TN-C, TN-C-S, TT, IT) met NEN 1010 hints
- Kabelcatalogus met eigen kabels toevoegen
- Projectenbeheer — meerdere berekeningen per project
- Boomberekening — meerdere aftakkingen in één overzicht
- Tweetalig: Nederlands en Engels
- Meerdere gebruikersprofielen

---

## Download

De nieuwste Windows-versie (.zip met .exe) is te vinden onder [Releases](../../releases).

Download, uitpakken en `kabelberekening.exe` starten — geen installatie nodig.

---

## Bouwen vanuit broncode

Vereisten: [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)

```bash
git clone <repository-url>
cd kabelberekening
flutter pub get

# macOS
flutter build macos --release

# Windows
flutter create --platforms=windows .
flutter build windows --release

# iOS
flutter build ios --release
```

---

## Normen

Berekeningen zijn gebaseerd op:
- IEC 60364-5-52 — Selectie en installatie van elektrisch materieel
- NEN 1010 — Veiligheidsbepalingen voor laagspanningsinstallaties
- IEC 60076-5 — Transformatoren, kortsluitvastheid

---

## Licentie

Privégebruik. Zie [Privacy Policy](lib/screens/privacy_screen.dart) in de app.
