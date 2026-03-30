---
layout: home
title: MijnKabelberekening
---

# MijnKabelberekening

**Professional cable cross-section calculation** for electrical installations,
compliant with **IEC 60364-5-52** and **NEN 1010**.

---

## Download

<div class="download-buttons">

  <a href="https://github.com/sjaajke/MijnKabelberekening/releases/latest" class="btn btn-windows">
    ⬇ Windows (.exe)
  </a>

  <a href="https://github.com/sjaajke/MijnKabelberekening/releases/latest" class="btn btn-macos">
    ⬇ macOS (.dmg)
  </a>

  <a href="#" class="btn btn-android">
    ▶ Google Play Store
    <span class="badge">Coming soon</span>
  </a>

  <a href="https://apps.apple.com/nl/app/mijnkabelberekening/id6760185317MijnKabelberekening" class="btn btn-ios">
    ⬇ Apple App Store
  </a>

</div>

---

## What does it do?

MijnKabelberekening calculates the **minimum required cable cross-section** for electrical installations based on:

- **Load current** and ambient temperature
- **Correction factors** — bundling, ground installation, temperature
- **Maximum voltage drop** (configurable %)
- **Short-circuit protection** — thermal and dynamic verification
- **Source impedance** — transformer data (50–2000 kVA) or manual entry

---

## Features

### Cable Calculation
Calculate the correct cable cross-section in seconds. The app checks:
- Current-carrying capacity (IEC 60364-5-52 Table B.52.4/B.52.5)
- Voltage drop across the cable
- Short-circuit withstand capability

### Source Impedance Module
Enter transformer specifications or connect to a network source:
- Short-circuit current at source (Ik3f, Ik1f)
- Short-circuit current at cable end
- Earthing system selection: TN-S, TN-C, TN-C-S, TT, IT
- NEN 1010 compliance hints per earthing system

### Cable Catalogue
Built-in catalogue with copper and aluminium cables (PVC/XLPE insulation).
Add your own custom cables and share them across projects.

### Project Management
Organise calculations per project. Each project stores all input parameters
and results for future reference or printing.

### Tree Calculation
Model branching cable networks — calculate multiple branches simultaneously
in a single overview.

### Bundle Position Comparison
For cables in cable trays with multiple layers, the app compares four characteristic positions:

| Position | Solar | fH | fV |
|---|---|---|---|
| Bundle centre | None (shielded) | fH(nH) | fV(nV) |
| Top layer, centre ☀ | Full (+25 K) | fH(nH) | fV(2) |
| Top layer, corner ☀ | Full (+25 K) | fH(2) | fV(2) |
| Lower layers, corner | None (shielded) | fH(2) | fV(2) |

Solar irradiance only affects the top layer — lower layers are shielded by cables above them.

### Wind Cooling & PV Layer Position
For PV single-core cables in rooftop cable trays:
- **Wind cooling** (IEC 60287-2-1): reduces effective ambient temperature by 3–15 K depending on wind speed; steel lid adds +5 K penalty
- **PV layer position** (IEC 60364-5-52): layer-dependent solar ΔT (+25 K top, +12 K 2nd, +5 K middle, 0 K bottom)

### Correction Factors
Interactive table for:
- Installation method (A1, A2, B1, B2, C, D, E, F, G)
- Ambient temperature
- Grouping / bundling factor
- Ground temperature and thermal resistivity

---

## Standards

| Standard | Description |
|---|---|
| IEC 60364-5-52 | Selection and erection of electrical equipment — wiring systems |
| IEC 60287-2-1 | Electric cables — thermal resistance / wind cooling model |
| NEN 1010 | Safety requirements for low-voltage installations |
| IEC 60076-5 | Power transformers — ability to withstand short circuit |

---

## Platforms

| Platform | Status |
|---|---|
| Windows 10/11 | Available — [download here](https://github.com/sjaajke/MijnKabelberekening/releases/latest) |
| macOS | Available — [download here](https://github.com/sjaajke/MijnKabelberekening/releases/latest) |
| Android | Coming soon |
| iOS / iPadOS | Coming soon |

---

[Api documentation](./api/) trakaka

---

## License

MijnKabelberekening is open source software, licensed under the
[GNU General Public License v3.0](https://github.com/sjaajke/MijnKabelberekening/blob/main/LICENSE).

© 2026 Jay Smeekes
