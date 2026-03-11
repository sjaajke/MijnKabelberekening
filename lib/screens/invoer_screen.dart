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
import '../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../models/invoer.dart';
import '../models/bundel_config.dart';
import '../data/catalogus.dart' show standaardDoorsnedes, adersOpties, adersLabel, defaultAders;
import '../data/transformatoren.dart';
import '../state/berekening_provider.dart';
import '../state/custom_catalogus_provider.dart';
import '../widgets/sectie_card.dart';
import '../widgets/invoer_rij.dart';
import '../berekening/cyclisch.dart' show CyclischeFactor;

class InvoerScreen extends StatefulWidget {
  const InvoerScreen({super.key});

  @override
  State<InvoerScreen> createState() => _InvoerScreenState();
}

class _InvoerScreenState extends State<InvoerScreen> {
  late Invoer _inv;
  bool _gebruikVermogen = false;
  bool _gebruikBundel = false;
  bool _gebruikKortsluit = false;
  bool _gebruikMaxLengte = false;
  bool _gebruikZonlicht = false;
  bool _gebruikForceer = false;
  bool _gebruikCyclisch = false;
  int _cyclischPreset = 1;
  bool _gebruikHarmonischen = false;
  bool _gebruikBronimpedantie = false;

  @override
  void initState() {
    super.initState();
    _initFrom(context.read<BerekeningProvider>().invoer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Detecteer een extern geladen invoer (bijv. vanuit een project).
    // Vergelijking op referentie: berekenMet() slaat exact _inv op,
    // dus bij een externe load is de referentie altijd anders.
    final providerInvoer = Provider.of<BerekeningProvider>(context).invoer;
    if (providerInvoer != _inv) {
      setState(() => _initFrom(providerInvoer));
    }
  }

  void _initFrom(Invoer inv) {
    _inv = inv;
    _gebruikVermogen = inv.vermogenW != null;
    _gebruikBundel = inv.bundel != null;
    _gebruikKortsluit = inv.kortsluitstroomA > 0;
    _gebruikMaxLengte = inv.beveiligingType != null;
    _gebruikZonlicht = inv.zonlichtToeslagK > 0;
    _gebruikForceer = inv.forceerDoorsnedemm2 != null;
    _gebruikCyclisch = inv.cyclischProfiel != null;
    _gebruikHarmonischen = inv.derdeHarmonischePct > 0;
    _gebruikBronimpedantie = inv.bronimpedantieActief;
  }

  static List<int> _geleidersOpties(Systeemtype s) =>
      s == Systeemtype.ac3Fase ? [3, 4, 5] : [2, 3];

  static int _geleidersDefault(Systeemtype s) =>
      s == Systeemtype.ac3Fase ? 5 : 2;

  static String _geleidersLabel(int n, Systeemtype s) {
    if (s == Systeemtype.ac3Fase) {
      return switch (n) {
        3 => '3  (L1 + L2 + L3)',
        4 => '4  (L1 + L2 + L3 + N)',
        _ => '5  (L1 + L2 + L3 + N + PE)',
      };
    }
    return n == 2 ? '2  (L + N)' : '3  (L + N + PE)';
  }

  void _update(Invoer nieuw) {
    setState(() => _inv = nieuw);
  }

  void _mcbAutoVulKortsluit(Invoer nieuw) {
    final type = nieuw.beveiligingType;
    final heeftBeveiliging = type != null && nieuw.beveiligingWaarde != null;
    if (!heeftBeveiliging) {
      _update(nieuw);
      return;
    }
    // Automatisch kortsluittoets inschakelen en waarden vullen.
    // kortsluitstroomA = Ia (minimale aanspreekstroom om beveiliging te laten trippen).
    // kortsluitduurMs = maximale uitschakeltijd per geselecteerd patroon.
    final duur = switch (type) {
      BeveiligingType.mcbB ||
      BeveiligingType.mcbC ||
      BeveiligingType.mcbD   => 100.0,
      BeveiligingType.gg02   => 200.0,
      BeveiligingType.gg04   => 400.0,
      BeveiligingType.gg1    => 1000.0,
      BeveiligingType.gg5    => 5000.0,
      BeveiligingType.handmatig => nieuw.kortsluitduurMs,
    };
    final ia = nieuw.beveiligingIa ?? 0.0;
    setState(() => _gebruikKortsluit = true);
    _update(nieuw.copyWith(
      kortsluitduurMs: duur,
      kortsluitstroomA: ia > 0 ? ia : nieuw.kortsluitstroomA,
    ));
  }

  void _bereken() {
    context.read<BerekeningProvider>().berekenMet(_inv);
    DefaultTabController.of(context).animateTo(1);
  }

  String _leggingLabel(Leggingswijze l, AppLocalizations l10n) {
    return switch (l) {
      Leggingswijze.a1 => l10n.leggingA1,
      Leggingswijze.a2 => l10n.leggingA2,
      Leggingswijze.b1 => l10n.leggingB1,
      Leggingswijze.b2 => l10n.leggingB2,
      Leggingswijze.c  => l10n.leggingC,
      Leggingswijze.d1 => l10n.leggingD1,
      Leggingswijze.d2 => l10n.leggingD2,
      Leggingswijze.e  => l10n.leggingE,
      Leggingswijze.f  => l10n.leggingF,
      Leggingswijze.g  => l10n.leggingG,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (!context.watch<BerekeningProvider>().isBoomModus)
            _bronimpedantieToggle(),
          if (_gebruikBronimpedantie)
            context.watch<BerekeningProvider>().isBoomModus
                ? _boomUpstreamInfo()
                : _bronimpedantieSectie(),
          _systeemSectie(),
          _belastingSectie(),
          _kabelSectie(),
          _omgevingSectie(),
          if (_gebruikBundel) _bundelSectie(),
          if (_gebruikCyclisch && _inv.isGrondkabel) _cyclischSectie(),
          if (_gebruikHarmonischen &&
              _inv.systeem == Systeemtype.ac3Fase &&
              (_inv.aantalAders == 4 || _inv.aantalAders == 5))
            _harmonischenSectie(),
          _eisenSectie(),
          if (_gebruikMaxLengte) _maxLengteSectie(),
          if (_gebruikKortsluit) _kortsluitSectie(),
          const SizedBox(height: 12),
          _berekenKnop(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── SYSTEEM ────────────────────────────────────────────────────────────────
  Widget _systeemSectie() {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.sectSysteem,
      icoon: Icons.electrical_services,
      children: [
        DropdownRij<Systeemtype>(
          label: l10n.lblSysteemtype,
          waarde: _inv.systeem,
          opties: Systeemtype.values,
          display: (s) => switch (s) {
            Systeemtype.ac1Fase => l10n.systAc1Fase,
            Systeemtype.ac3Fase => l10n.systAc3Fase,
            Systeemtype.dc2Draad => l10n.systDc2Draad,
            Systeemtype.dcAarde  => l10n.systDcAarde,
          },
          onChanged: (v) {
            final geldigeAders = adersOpties(v).contains(_inv.aantalAders)
                ? _inv.aantalAders
                : defaultAders(v);
            final gpkOpties = _geleidersOpties(v);
            final geldigeGpk =
                (geldigeAders == 1 && v.isAC && !gpkOpties.contains(_inv.geleidersPerKring))
                    ? _geleidersDefault(v)
                    : _inv.geleidersPerKring;
            final geldigeSpanning = switch (v) {
              Systeemtype.ac3Fase => 400.0,
              Systeemtype.ac1Fase => 230.0,
              _ => _inv.spanningV,
            };
            _update(_inv.copyWith(systeem: v, aantalAders: geldigeAders, geleidersPerKring: geldigeGpk, spanningV: geldigeSpanning));
          },
        ),
        const SizedBox(height: 4),
        GetalVeld(
          label: l10n.lblSpanning,
          eenheid: 'V',
          waarde: _inv.spanningV,
          onChanged: (v) => _update(_inv.copyWith(spanningV: v)),
          min: 1,
          decimalen: 0,
        ),
        if (_inv.systeem.isAC) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblCosPhi,
            eenheid: '',
            waarde: _inv.cosPhi,
            onChanged: (v) => _update(_inv.copyWith(cosPhi: v)),
            min: 0.1,
            max: 1.0,
            decimalen: 3,
          ),
        ],
      ],
    );
  }

  // ── BELASTING ──────────────────────────────────────────────────────────────
  Widget _belastingSectie() {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.sectBelasting,
      icoon: Icons.bolt,
      children: [
        SchakelaarRij(
          label: l10n.lblVermogenSchakelaar,
          waarde: _gebruikVermogen,
          onChanged: (v) => setState(() {
            _gebruikVermogen = v;
            if (v) {
              _update(_inv.copyWith(vermogenW: 10000, stroomA: 0));
            } else {
              _update(_inv.copyWith(stroomA: 32, clearVermogen: true));
            }
          }),
        ),
        const SizedBox(height: 4),
        if (_gebruikVermogen)
          GetalVeld(
            label: l10n.lblVermogen,
            eenheid: 'W',
            waarde: _inv.vermogenW ?? 10000,
            onChanged: (v) => _update(_inv.copyWith(vermogenW: v)),
            min: 1,
            decimalen: 0,
          )
        else
          GetalVeld(
            label: l10n.lblStroom,
            eenheid: 'A',
            waarde: _inv.stroomA,
            onChanged: (v) => _update(_inv.copyWith(stroomA: v)),
            min: 0.1,
            decimalen: 1,
          ),
        const SizedBox(height: 4),
        GetalVeld(
          label: l10n.lblKabellengte,
          eenheid: 'm',
          waarde: _inv.lengteM,
          onChanged: (v) => _update(_inv.copyWith(lengteM: v)),
          min: 0.1,
          decimalen: 1,
        ),
      ],
    );
  }

  // ── KABEL ──────────────────────────────────────────────────────────────────
  Widget _kabelSectie() {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.sectKabel,
      icoon: Icons.cable,
      children: [
        DropdownRij<Geleidermateriaal>(
          label: l10n.lblGeleidermateriaal,
          waarde: _inv.geleider,
          opties: Geleidermateriaal.values,
          display: (g) => g.label,
          onChanged: (v) => _update(_inv.copyWith(geleider: v)),
        ),
        const SizedBox(height: 4),
        DropdownRij<Isolatiemateriaal>(
          label: l10n.lblIsolatiemateriaal,
          waarde: _inv.isolatie,
          opties: [Isolatiemateriaal.pvc, Isolatiemateriaal.xlpe],
          display: (i) => i.label,
          onChanged: (v) => _update(_inv.copyWith(isolatie: v)),
        ),
        const SizedBox(height: 4),
        DropdownRij<Leggingswijze>(
          label: l10n.lblLeggingswijze,
          waarde: _inv.legging,
          opties: Leggingswijze.values,
          display: (l) => _leggingLabel(l, l10n),
          onChanged: (v) => _update(_inv.copyWith(legging: v)),
        ),
        const SizedBox(height: 4),
        DropdownRij<int>(
          label: l10n.lblAantalAders,
          waarde: _inv.aantalAders,
          opties: adersOpties(_inv.systeem),
          display: adersLabel,
          onChanged: (v) {
            final gpkOpties = _geleidersOpties(_inv.systeem);
            final geldigeGpk = (v == 1 && !gpkOpties.contains(_inv.geleidersPerKring))
                ? _geleidersDefault(_inv.systeem)
                : _inv.geleidersPerKring;
            _update(_inv.copyWith(aantalAders: v, geleidersPerKring: geldigeGpk));
          },
        ),
        if (_inv.aantalAders == 1 && _inv.systeem.isAC) ...[
          const SizedBox(height: 4),
          DropdownRij<int>(
            label: l10n.lblGeleidersPerKring,
            waarde: _geleidersOpties(_inv.systeem).contains(_inv.geleidersPerKring)
                ? _inv.geleidersPerKring
                : _geleidersDefault(_inv.systeem),
            opties: _geleidersOpties(_inv.systeem),
            display: (n) => _geleidersLabel(n, _inv.systeem),
            onChanged: (v) => _update(_inv.copyWith(geleidersPerKring: v)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              l10n.singelTotaalLabel(_inv.nParallel, _inv.geleidersPerKring),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: 4),
        SchakelaarRij(
          label: l10n.lblDoorsnedeForce,
          waarde: _gebruikForceer,
          onChanged: (v) => setState(() {
            _gebruikForceer = v;
            if (!v) {
              _update(_inv.copyWith(clearForceer: true));
            } else {
              final eerste = standaardDoorsnedes(_inv.geleider).first;
              _update(_inv.copyWith(forceerDoorsnedemm2: eerste));
            }
          }),
        ),
        if (_gebruikForceer) ...[
          const SizedBox(height: 4),
          Builder(builder: (ctx) {
            final custom = ctx.watch<CustomCatalogusProvider>();
            final customDoorsnedes = custom.customKabels
                .where((k) => k.geleider == _inv.geleider)
                .map((k) => k.doorsnedemm2)
                .toSet();
            final alles = ({
              ...standaardDoorsnedes(_inv.geleider),
              ...customDoorsnedes,
            }.toList()..sort());
            final huidige = _inv.forceerDoorsnedemm2 ?? alles.first;
            final geldig = alles.contains(huidige) ? huidige : alles.first;
            return DropdownRij<double>(
              label: l10n.lblDoorsnede,
              waarde: geldig,
              opties: alles,
              display: (a) => '${a % 1 == 0 ? a.toInt() : a} mm²',
              onChanged: (v) =>
                  _update(_inv.copyWith(forceerDoorsnedemm2: v)),
            );
          }),
        ],
        if (_inv.systeem.isAC) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblParallelKabels,
            eenheid: l10n.eenheidStuks,
            waarde: _inv.nParallel.toDouble(),
            onChanged: (v) =>
                _update(_inv.copyWith(nParallel: v.round().clamp(1, 20))),
            min: 1,
            max: 20,
            decimalen: 0,
          ),
          if (_inv.nParallel > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.parallelTotaalLabel(
                  _inv.effectieveStroom.toStringAsFixed(1),
                  _inv.nParallel,
                  (_inv.effectieveStroom / _inv.nParallel).toStringAsFixed(1),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }

  // ── OMGEVING ───────────────────────────────────────────────────────────────
  Widget _omgevingSectie() {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.sectOmgeving,
      icoon: Icons.thermostat,
      children: [
        GetalVeld(
          label: l10n.lblOmgevingstemp,
          eenheid: '°C',
          waarde: _inv.omgevingstempC,
          onChanged: (v) => _update(_inv.copyWith(omgevingstempC: v)),
          min: -30,
          max: 70,
          decimalen: 0,
        ),
        if (_inv.legging.isGrond) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblLegdiepte,
            eenheid: 'm',
            waarde: _inv.diepteM,
            onChanged: (v) => _update(_inv.copyWith(diepteM: v)),
            min: 0.3,
            max: 3.0,
            decimalen: 2,
          ),
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblGrondtemp,
            eenheid: '°C',
            waarde: _inv.grondtempC,
            onChanged: (v) => _update(_inv.copyWith(grondtempC: v)),
            min: 0,
            max: 40,
            decimalen: 0,
          ),
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblLambdaGrond,
            eenheid: 'K·m/W',
            waarde: _inv.lambdaGrond,
            onChanged: (v) => _update(_inv.copyWith(lambdaGrond: v)),
            min: 0.3,
            max: 3.0,
            decimalen: 2,
          ),
          const SizedBox(height: 4),
          SchakelaarRij(
            label: l10n.lblCyclisch,
            waarde: _gebruikCyclisch,
            onChanged: (v) => setState(() {
              _gebruikCyclisch = v;
              if (!v) {
                _update(_inv.copyWith(clearCyclisch: true));
              } else {
                _cyclischPreset = 1;
                _update(_inv.copyWith(
                  cyclischProfiel: CyclischeFactor.profielDagCyclus,
                  cyclischNKringen: 1,
                  cyclischAanliggend: true,
                  cyclischHartOpHartMm: 0,
                ));
              }
            }),
          ),
        ],
        const SizedBox(height: 4),
        SchakelaarRij(
          label: l10n.lblZonlicht,
          waarde: _gebruikZonlicht,
          onChanged: (v) => setState(() {
            _gebruikZonlicht = v;
            _update(_inv.copyWith(
                zonlichtToeslagK: v ? 15.0 : 0.0));
          }),
        ),
        if (_gebruikZonlicht) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblZonlichtToeslag,
            eenheid: 'K',
            waarde: _inv.zonlichtToeslagK,
            onChanged: (v) =>
                _update(_inv.copyWith(zonlichtToeslagK: v)),
            min: 1,
            max: 40,
            decimalen: 0,
          ),
        ],
        const SizedBox(height: 4),
        SchakelaarRij(
          label: l10n.lblBundel,
          waarde: _gebruikBundel,
          onChanged: (v) => setState(() {
            _gebruikBundel = v;
            if (!v) {
              _update(_inv.copyWith(clearBundel: true));
            } else {
              final kabel = context.read<BerekeningProvider>().resultaten?.kabel;
              final d = kabel != null ? kabel.buitendiameter.roundToDouble() : 60.0;
              _update(_inv.copyWith(
                  bundel: BundelConfig(nHorizontaal: 2, nVerticaal: 1, hartOpHartMm: d)));
            }
          }),
        ),
      ],
    );
  }

  // ── BUNDEL ─────────────────────────────────────────────────────────────────
  Widget _bundelSectie() {
    final l10n = context.l10n;
    final b = _inv.bundel ?? const BundelConfig(nHorizontaal: 2, nVerticaal: 1, hartOpHartMm: 60);
    return SectieCard(
      titel: l10n.sectBundel,
      icoon: Icons.grid_view,
      children: [
        GetalVeld(
          label: l10n.lblKabelsNaast,
          eenheid: l10n.eenheidStuks,
          waarde: b.nHorizontaal.toDouble(),
          onChanged: (v) => _update(_inv.copyWith(
              bundel: BundelConfig(
                  nHorizontaal: v.round(),
                  nVerticaal: b.nVerticaal,
                  hartOpHartMm: b.hartOpHartMm))),
          min: 1,
          max: 100,
          decimalen: 0,
        ),
        const SizedBox(height: 4),
        GetalVeld(
          label: l10n.lblLagenHoog,
          eenheid: l10n.eenheidLagen,
          waarde: b.nVerticaal.toDouble(),
          onChanged: (v) => _update(_inv.copyWith(
              bundel: BundelConfig(
                  nHorizontaal: b.nHorizontaal,
                  nVerticaal: v.round(),
                  hartOpHartMm: b.hartOpHartMm))),
          min: 1,
          max: 50,
          decimalen: 0,
        ),
        const SizedBox(height: 4),
        GetalVeld(
          label: l10n.lblHartOpHart,
          eenheid: 'mm',
          waarde: b.hartOpHartMm,
          onChanged: (v) => _update(_inv.copyWith(
              bundel: BundelConfig(
                  nHorizontaal: b.nHorizontaal,
                  nVerticaal: b.nVerticaal,
                  hartOpHartMm: v))),
          min: 10,
          max: 500,
          decimalen: 0,
        ),
        Builder(builder: (ctx) {
          final kabel = ctx.read<BerekeningProvider>().resultaten?.kabel;
          if (kabel == null) return const SizedBox.shrink();
          final d = kabel.buitendiameter;
          return Padding(
            padding: const EdgeInsets.only(top: 2, left: 2),
            child: Text(
              l10n.kabeldiameterInfo(d.toStringAsFixed(1)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          l10n.bundelTotaalInfo(
            b.totaalKabels,
            b.slechtstePositie.$1,
            b.slechtstePositie.$2,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // ── CYCLISCH ───────────────────────────────────────────────────────────────
  Widget _cyclischSectie() {
    final l10n = context.l10n;
    final profiel = _inv.cyclischProfiel ?? CyclischeFactor.profielDagCyclus;
    final hartOpHart = _inv.cyclischHartOpHartMm;

    void setProfiel(List<double> p) =>
        _update(_inv.copyWith(cyclischProfiel: List<double>.from(p)));

    return SectieCard(
      titel: l10n.sectCyclisch,
      icoon: Icons.show_chart,
      children: [
        DropdownRij<int>(
          label: l10n.lblBelastingsprofiel,
          waarde: _cyclischPreset,
          opties: const [0, 1, 2],
          display: (i) => switch (i) {
            0 => l10n.profielConstant,
            1 => l10n.profielDagNacht,
            _ => l10n.profielEigen,
          },
          onChanged: (v) => setState(() {
            _cyclischPreset = v;
            if (v == 0) setProfiel(CyclischeFactor.profielConstant);
            if (v == 1) setProfiel(CyclischeFactor.profielDagCyclus);
          }),
        ),
        const SizedBox(height: 8),
        _profielGrid(profiel, l10n),
        const SizedBox(height: 8),
        GetalVeld(
          label: l10n.lblAantalKringen,
          eenheid: l10n.eenheidStuks,
          waarde: _inv.cyclischNKringen.toDouble(),
          onChanged: (v) =>
              _update(_inv.copyWith(cyclischNKringen: v.round().clamp(1, 16))),
          min: 1,
          max: 16,
          decimalen: 0,
        ),
        const SizedBox(height: 8),
        DropdownRij<bool>(
          label: l10n.lblLiggingKringen,
          waarde: _inv.cyclischAanliggend,
          opties: const [true, false],
          display: (v) => v ? l10n.optAanliggend : l10n.optGespreid,
          onChanged: (v) => _update(_inv.copyWith(cyclischAanliggend: v)),
        ),
        if (_inv.cyclischNKringen > 1) ...[
          const SizedBox(height: 8),
          GetalVeld(
            label: l10n.lblHartOpHartKringen,
            eenheid: 'mm',
            waarde: hartOpHart > 0 ? hartOpHart : 100,
            onChanged: (v) =>
                _update(_inv.copyWith(cyclischHartOpHartMm: v)),
            min: 0,
            max: 2000,
            decimalen: 0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 2),
            child: Text(
              l10n.hint0mmAanliggend,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _profielGrid(List<double> profiel, AppLocalizations l10n) {
    const uren = 24;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.lblIMaxPerUur, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: uren,
          itemBuilder: (ctx, h) {
            return _uurVeld(h, profiel[h], (v) {
              final nieuw = List<double>.from(profiel);
              nieuw[h] = v.clamp(0.0, 1.0);
              setState(() => _cyclischPreset = 2);
              _update(_inv.copyWith(cyclischProfiel: nieuw));
            });
          },
        ),
      ],
    );
  }

  Widget _uurVeld(int uur, double waarde, ValueChanged<double> onChanged) {
    final ctrl = TextEditingController(
        text: waarde == waarde.truncateToDouble()
            ? waarde.toInt().toString()
            : waarde.toStringAsFixed(2));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$uur', style: const TextStyle(fontSize: 10)),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              border: OutlineInputBorder(),
            ),
            onChanged: (s) {
              final v = double.tryParse(s.replaceAll(',', '.'));
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  // ── EISEN ──────────────────────────────────────────────────────────────────
  Widget _eisenSectie() {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.sectEisen,
      icoon: Icons.rule,
      children: [
        GetalVeld(
          label: l10n.lblMaxSpanningsval,
          eenheid: '%',
          waarde: _inv.maxSpanningsvalPct,
          onChanged: (v) => _update(_inv.copyWith(maxSpanningsvalPct: v)),
          min: 0.1,
          max: 20,
          decimalen: 1,
        ),
        const SizedBox(height: 4),
        SchakelaarRij(
          label: l10n.lblMaxLengte,
          waarde: _gebruikMaxLengte,
          onChanged: (v) => setState(() {
            _gebruikMaxLengte = v;
            if (!v) {
              _update(_inv.copyWith(
                clearBeveiligingType: true,
                clearBeveiligingWaarde: true,
              ));
            } else {
              _mcbAutoVulKortsluit(_inv.copyWith(
                beveiligingType: BeveiligingType.mcbC,
                beveiligingWaarde: 16,
              ));
            }
          }),
        ),
        const SizedBox(height: 4),
        SchakelaarRij(
          label: l10n.lblKortsluitToets,
          waarde: _gebruikKortsluit,
          onChanged: (v) => setState(() {
            _gebruikKortsluit = v;
            if (!v) _update(_inv.copyWith(kortsluitstroomA: 0));
          }),
        ),
        if (_inv.systeem == Systeemtype.ac3Fase &&
            (_inv.aantalAders == 4 || _inv.aantalAders == 5)) ...[
          const SizedBox(height: 4),
          SchakelaarRij(
            label: l10n.lblHarmonischen,
            waarde: _gebruikHarmonischen,
            onChanged: (v) => setState(() {
              _gebruikHarmonischen = v;
              if (v) {
                _update(_inv.copyWith(derdeHarmonischePct: 15));
              } else {
                _update(_inv.copyWith(derdeHarmonischePct: 0));
              }
            }),
          ),
        ],
      ],
    );
  }

  // ── BRONIMPEDANTIE TOGGLE (bovenaan, buiten boommode) ──────────────────────
  Widget _bronimpedantieToggle() {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SchakelaarRij(
          label: l10n.lblBronimpedantie,
          waarde: _gebruikBronimpedantie,
          onChanged: (v) => setState(() {
            _gebruikBronimpedantie = v;
            _update(_inv.copyWith(bronimpedantieActief: v));
          }),
        ),
      ),
    );
  }

  // ── BOOM UPSTREAM INFO (read-only, boom mode) ───────────────────────────────
  Widget _boomUpstreamInfo() {
    final l10n = context.l10n;
    final zUp = _inv.zUpstreamHandmatigMohm;
    if (zUp == null) return const SizedBox.shrink();
    final ikBron = _inv.ikBronBerekendA;
    return SectieCard(
      titel: l10n.sectBronimpedantieBoom,
      icoon: Icons.account_tree_outlined,
      children: [
        ResultaatRij(
          label: l10n.lblZUpstreamMohm,
          waarde: '${zUp.toStringAsFixed(2)} mΩ',
          vet: true,
        ),
        if (ikBron > 0)
          ResultaatRij(
            label: l10n.lblIk1fBron,
            waarde: '${ikBron.toStringAsFixed(0)} A',
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 2),
          child: Text(
            l10n.boomUpstreamHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  // ── BEREKENEN ──────────────────────────────────────────────────────────────
  Widget _berekenKnop() => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.calculate),
          label: Text(context.l10n.btnBerekenen),
          onPressed: _bereken,
        ),
      );

  // ── KORTSLUIT ──────────────────────────────────────────────────────────────
  Widget _kortsluitSectie() {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.sectKortsluit,
      icoon: Icons.flash_on,
      children: [
        GetalVeld(
          label: l10n.lblKortsluitstroom,
          eenheid: 'A',
          waarde: _inv.kortsluitstroomA,
          onChanged: (v) => _update(_inv.copyWith(kortsluitstroomA: v)),
          min: 100,
          max: 200000,
          decimalen: 0,
        ),
        const SizedBox(height: 4),
        GetalVeld(
          label: l10n.lblKortsluitduur,
          eenheid: 'ms',
          waarde: _inv.kortsluitduurMs,
          onChanged: (v) => _update(_inv.copyWith(kortsluitduurMs: v)),
          min: 1,
          max: 60000,
          decimalen: 0,
        ),
      ],
    );
  }

  // ── MAXIMALE LEIDINGLENGTE ─────────────────────────────────────────────────
  Widget _maxLengteSectie() {
    final l10n = context.l10n;
    final type = _inv.beveiligingType ?? BeveiligingType.mcbC;
    return SectieCard(
      titel: l10n.sectMaxLengte,
      icoon: Icons.straighten,
      children: [
        DropdownRij<BeveiligingType>(
          label: l10n.lblBeveiligingType,
          waarde: type,
          opties: BeveiligingType.values,
          display: (t) => t.label,
          onChanged: (v) => _mcbAutoVulKortsluit(_inv.copyWith(beveiligingType: v)),
        ),
        const SizedBox(height: 4),
        GetalVeld(
          label: l10n.lblBeveiligingWaarde,
          eenheid: 'A',
          waarde: _inv.beveiligingWaarde ?? 16,
          onChanged: (v) => _mcbAutoVulKortsluit(_inv.copyWith(beveiligingWaarde: v)),
          min: 0.5,
          max: 10000,
          decimalen: 1,
        ),
      ],
    );
  }

  // ── BRONIMPEDANTIE ─────────────────────────────────────────────────────────
  Widget _bronimpedantieSectie() {
    final l10n = context.l10n;
    final inv = _inv;

    // Geselecteerde transformator uit databank (of null bij handmatig)
    final dbIndex = inv.transformatorHandmatig
        ? -1
        : transformatorDatabase.indexWhere(
            (t) =>
                t.vermogenKva == inv.transformatorKva &&
                t.uccPct == inv.transformatorUccPct,
          );
    final geselecteerdeTrafo = (dbIndex >= 0 && dbIndex < transformatorDatabase.length)
        ? transformatorDatabase[dbIndex]
        : null;

    // Zb en Ik_bron berekenen voor weergave
    final zbOhm = inv.zbOhm;
    final zbMohm = zbOhm * 1000;
    final ikBron = inv.ikBronBerekendA;

    return SectieCard(
      titel: l10n.sectBronimpedantie,
      icoon: Icons.transform,
      children: [
        // Z_upstream handmatig toggle (ketenberekening)
        SchakelaarRij(
          label: l10n.lblZUpstreamHandmatig,
          waarde: inv.zUpstreamHandmatigMohm != null,
          onChanged: (v) => _update(v
              ? inv.copyWith(zUpstreamHandmatigMohm: 100.0)
              : inv.copyWith(clearZUpstream: true)),
        ),
        const SizedBox(height: 4),

        if (inv.zUpstreamHandmatigMohm != null) ...[
          // Handmatige Z_upstream invoer
          GetalVeld(
            label: l10n.lblZUpstreamMohm,
            eenheid: 'mΩ',
            waarde: inv.zUpstreamHandmatigMohm!,
            onChanged: (v) => _update(inv.copyWith(zUpstreamHandmatigMohm: v)),
            min: 0.01,
            max: 100000,
            decimalen: 2,
          ),
        ] else ...[
          // Transformatorselectie toggle
          SchakelaarRij(
            label: l10n.lblTransformatorHandmatig,
            waarde: inv.transformatorHandmatig,
            onChanged: (v) {
              final trafo = transformatorDatabase.firstWhere(
                (t) => t.vermogenKva == inv.transformatorKva,
                orElse: () => transformatorDatabase[3], // 250 kVA default
              );
              _update(inv.copyWith(
                transformatorHandmatig: v,
                transformatorKva: v ? inv.transformatorKva : trafo.vermogenKva,
                transformatorUccPct: v ? inv.transformatorUccPct : trafo.uccPct,
              ));
            },
          ),
          const SizedBox(height: 4),
          if (!inv.transformatorHandmatig) ...[
            // Dropdown uit databank
            DropdownRij<TransformatorSpec>(
              label: l10n.lblTransformatorSelectie,
              waarde: geselecteerdeTrafo ?? transformatorDatabase[3],
              opties: transformatorDatabase,
              display: (t) => t.naam,
              onChanged: (t) => _update(inv.copyWith(
                transformatorKva: t.vermogenKva,
                transformatorUccPct: t.uccPct,
              )),
            ),
          ] else ...[
            // Handmatige invoer
            GetalVeld(
              label: l10n.lblTransformatorKva,
              eenheid: 'kVA',
              waarde: inv.transformatorKva,
              onChanged: (v) => _update(inv.copyWith(transformatorKva: v)),
              min: 10,
              max: 10000,
              decimalen: 0,
            ),
            const SizedBox(height: 4),
            GetalVeld(
              label: l10n.lblTransformatorUcc,
              eenheid: '%',
              waarde: inv.transformatorUccPct,
              onChanged: (v) => _update(inv.copyWith(transformatorUccPct: v)),
              min: 0.5,
              max: 20,
              decimalen: 1,
            ),
          ],
        ],

        const SizedBox(height: 4),

        // Aardingsstelsel
        DropdownRij<Aardingsstelsel>(
          label: l10n.lblAardingsstelsel,
          waarde: inv.aardingsstelsel,
          opties: Aardingsstelsel.values,
          display: (s) => s.label,
          onChanged: (v) => _update(inv.copyWith(aardingsstelsel: v)),
        ),

        // NEN 1010 hint per stelsel
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 2, bottom: 4),
          child: Text(
            l10n.aardingsstelselHint(inv.aardingsstelsel.code),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: inv.aardingsstelsel == Aardingsstelsel.it ||
                          inv.aardingsstelsel == Aardingsstelsel.tt
                      ? Colors.orange.shade800
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),

        // Netwerk kortsluitvermogen
        SchakelaarRij(
          label: l10n.lblSkNetOneindig,
          waarde: inv.skNetOneindig,
          onChanged: (v) => _update(inv.copyWith(skNetOneindig: v)),
        ),
        if (!inv.skNetOneindig) ...[
          const SizedBox(height: 4),
          GetalVeld(
            label: l10n.lblSkNetAangepast,
            eenheid: 'MVA',
            waarde: inv.skNetMva,
            onChanged: (v) => _update(inv.copyWith(skNetMva: v)),
            min: 0.1,
            max: 10000,
            decimalen: 1,
          ),
        ],

        // Zb en Ik_bron samenvatting
        if (zbOhm > 0) ...[
          const Divider(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              inv.zUpstreamHandmatigMohm != null
                  ? l10n.zUpstreamInfo(inv.zUpstreamHandmatigMohm!.toStringAsFixed(2))
                  : l10n.zbBerekend(zbMohm.toStringAsFixed(2)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (ikBron > 0)
            Padding(
              padding: const EdgeInsets.only(left: 2, top: 2),
              child: Text(
                l10n.ikBronInfo(ikBron.toStringAsFixed(0)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }

  // ── HARMONISCHEN ───────────────────────────────────────────────────────────
  Widget _harmonischenSectie() {
    final l10n = context.l10n;
    final h3 = _inv.derdeHarmonischePct;
    final iNeutraal = 3.0 * (h3 / 100.0) * _inv.effectieveStroom;

    final String zone;
    final String toelichting;
    if (h3 <= 0) {
      zone = '—';
      toelichting = l10n.harmGeenCorrectie;
    } else if (h3 <= 15) {
      zone = '0 – 15%';
      toelichting = l10n.harmFasestroom;
    } else if (h3 <= 33) {
      zone = '15 – 33%';
      toelichting = l10n.harmFasestroomReductie;
    } else if (h3 <= 45) {
      zone = '33 – 45%';
      toelichting = l10n.harmNulpuntsstroom;
    } else {
      zone = '> 45%';
      toelichting = l10n.harmNulpuntsstroomHoog;
    }

    return SectieCard(
      titel: l10n.sectHarmonischen,
      icoon: Icons.waves,
      children: [
        GetalVeld(
          label: l10n.lblDerdeHarm,
          eenheid: '%',
          waarde: h3,
          onChanged: (v) => _update(_inv.copyWith(
            derdeHarmonischePct: v.clamp(0.0, 100.0),
          )),
          min: 0,
          max: 100,
          decimalen: 0,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                '${l10n.lblZone}$zone',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        Text(
          toelichting,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (h3 > 0) ...[
          const SizedBox(height: 4),
          Text(
            'I_N = 3 × ${(h3 / 100).toStringAsFixed(2)} × ${_inv.effectieveStroom.toStringAsFixed(1)} A'
            ' = ${iNeutraal.toStringAsFixed(1)} A',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
