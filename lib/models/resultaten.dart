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

import 'kabel_spec.dart';

/// Volledige berekeningsresultaten.
class Resultaten {
  // Geselecteerde kabel
  final KabelSpec? kabel;
  final double doorsnedeMinKortsluit; // mm² min vanuit kortsluit

  // Gevraagde stroom
  final double iGevraagd;

  // Correctiefactoren
  final double tEffectief;    // effectieve omgevingstemperatuur (incl. zonlicht)
  final double fT;
  final double fLegging;      // leggingswijze-factor (IEC 60364-5-52 tabel B.52.4)
  final double fBundel;
  final double fGrond;
  final double fCyclisch;     // cyclische factor M (NEN IEC 60583-1); 1.0 = niet toegepast
  final double fHarmonisch;   // NEN 1010 Bijlage 52.E.1; 1.0 = niet van toepassing of geen reductie
  final bool harmonischOpNul; // true = kabelkeuze gebaseerd op nulpuntsstroom (h3 > 33%)
  final double iNeutraal;     // berekende nulpuntsstroom I_N = 3 × h3 × I_fase (A)
  final double fTotaal;

  // Toelaatbare stroom
  final int nParallel;        // aantal parallelle kabels
  final double iPerKabel;     // stroom per kabel = I_totaal / nParallel
  final double iz0;           // referentie (tabel, 30°C)
  final double iz;            // gecorrigeerd (per kabel)
  final double margeStroomPct;

  // Bundel
  final (int, int)? bundelPositieWorst;
  final double fHorizontaal;
  final double fVerticaal;

  // Bundel: warmste (centrum) vs koudste (hoek) positie
  // fBundelRand = fH(2)×fV(2) — hoekpositie heeft minder thermische buren
  final double fBundelRand;
  final double izRand;              // I_z voor hoekpositie (hoger dan iz)
  final double margeStroomPctRand;  // stroomveiligheidsmarge hoekpositie
  // Temperaturen via IEC-effectieve-omgeving benadering (indicatief):
  //   T_eff_centrum = T_max − (T_max − T_omg)·fBundel²
  //   T_geleider = T_eff + ΔT_eigen (I²R)
  final double geleiderTempCWarm;   // centrum geleidertemp (incl. mutuele verwarming)
  final double geleiderTempCKoud;   // hoek geleidertemp

  // Spanningsval
  final double deltaUV;
  final double deltaUPct;
  final bool okSpanning;

  // Temperatuur
  final double i2rVerliesWPerM;
  final double tempStijgingK;
  final double geleiderTempC;
  final double maxTempC;
  final bool okTemp;

  // Kortsluit
  final double deltaTKortsluitK;
  final double eindtempKortsluitC;
  final bool? okKortsluit; // null = niet getoetst

  // Maximale leidinglengte (kortsluitbeveiliging)
  final double? maxLengteM;    // null = toets niet actief
  final double? ikEind;        // kortsluitstroom aan het einde van de leiding [A]
  final bool? okMaxLengte;     // null = niet getoetst

  // Bronimpedantie (transformator + netwerk)
  final double? zbOhm;         // transformator + net-impedantie per fase [Ω]; null = niet actief
  final double? zbNetOhm;      // netwerk-aandeel Z_net [Ω]; null = oneindig
  final double? ik3fBronA;     // driefasige kortsluitstroom aan bron [A]
  final double? ik1fBronA;     // enkelfasige lus-Ik aan bron (= effectieveKortsluitstroomA) [A]
  final double? zKabelLusOhm;  // lusimpedantie kabel bij gegeven lengte [Ω]
  final double? ik1fEindA;     // enkelfasige lus-Ik aan kabeluiteinde [A]

  // Windkoeling
  final double? deltaTWindK;   // effectieve ΔT door wind [K]; null = niet actief
  final double? dtZonPvLaagK;  // zonneinstraling ΔT per laagpositie [K]; null = niet actief

  // Eindoordeel
  final bool voldoet;
  final List<String> fouten;
  final List<String> waarschuwingen;

  const Resultaten({
    this.kabel,
    this.doorsnedeMinKortsluit = 0,
    this.iGevraagd = 0,
    this.tEffectief = 30,
    this.fT = 1,
    this.fLegging = 1,
    this.fBundel = 1,
    this.fGrond = 1,
    this.fCyclisch = 1,
    this.fHarmonisch = 1,
    this.harmonischOpNul = false,
    this.iNeutraal = 0,
    this.fTotaal = 1,
    this.nParallel = 1,
    this.iPerKabel = 0,
    this.iz0 = 0,
    this.iz = 0,
    this.margeStroomPct = 0,
    this.bundelPositieWorst,
    this.fHorizontaal = 1,
    this.fVerticaal = 1,
    this.fBundelRand = 1,
    this.izRand = 0,
    this.margeStroomPctRand = 0,
    this.geleiderTempCWarm = 0,
    this.geleiderTempCKoud = 0,
    this.deltaUV = 0,
    this.deltaUPct = 0,
    this.okSpanning = false,
    this.i2rVerliesWPerM = 0,
    this.tempStijgingK = 0,
    this.geleiderTempC = 0,
    this.maxTempC = 70,
    this.okTemp = false,
    this.deltaTKortsluitK = 0,
    this.eindtempKortsluitC = 0,
    this.okKortsluit,
    this.maxLengteM,
    this.ikEind,
    this.okMaxLengte,
    this.zbOhm,
    this.zbNetOhm,
    this.ik3fBronA,
    this.ik1fBronA,
    this.zKabelLusOhm,
    this.ik1fEindA,
    this.deltaTWindK,
    this.dtZonPvLaagK,
    this.voldoet = false,
    this.fouten = const [],
    this.waarschuwingen = const [],
  });
}
