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

// Enumeraties voor kabelberekeningsprogramma v3.0
// IEC 60364-5-52 | IEC 60287 | IEC 60949 | NEN 1010

/// Aardingsstelsel conform NEN 1010 / IEC 60364-1 §312.
enum Aardingsstelsel {
  tnS('TN-S  (aparte N en PE door het gehele stelsel)'),
  tnC('TN-C  (gecombineerde PEN-geleider)'),
  tnCS('TN-C-S  (PEN in voeding, daarna N+PE gescheiden)'),
  tt('TT  (aparte aard verbruiker)'),
  it('IT  (isolé of hoge impedantie aarding)');

  const Aardingsstelsel(this.label);
  final String label;

  /// Korte stelsel-afkorting voor weergave.
  String get code => label.split('  ').first.trim();
}

enum Systeemtype {
  ac1Fase('AC 1-fase (L + N)'),
  ac3Fase('AC 3-fase (3L + PE)'),
  dc2Draad('DC 2-draad (+ / −)'),
  dcAarde('DC met aardretour');

  const Systeemtype(this.label);
  final String label;

  bool get isAC => this == ac1Fase || this == ac3Fase;
  bool get isDC => this == dc2Draad || this == dcAarde;
}

enum Geleidermateriaal {
  koper('Cu'),
  aluminium('Al');

  const Geleidermateriaal(this.label);
  final String label;
}

enum Isolatiemateriaal {
  pvc('PVC'),
  xlpe('XLPE'),
  epr('EPR');

  const Isolatiemateriaal(this.label);
  final String label;
}

enum Leggingswijze {
  a1('A1  — In isolerende buis, ingebouwd in thermisch isolerende wand'),
  a2('A2  — In isolerende buis, ingebouwd in gemetselde wand'),
  b1('B1  — In kabelkanaal/buis op/in wand (meerkabelig)'),
  b2('B2  — In kabelkanaal/buis op/in wand (eénkabelig)'),
  c('C   — Aanliggend aan wand/plafond (direct op oppervlak)'),
  d1('D1  — Direct ingegraven (in grond)'),
  d2('D2  — In buis ingegraven'),
  e('E   — In vrije lucht (1 D van oppervlak)'),
  f('F   — Op kabelgoot (touching)'),
  g('G   — Op kabelgoot (spaced, 1 D)');

  const Leggingswijze(this.label);
  final String label;

  String get code => label.split('  ').first.trim();

  bool get isGrond => this == d1 || this == d2;
  bool get isVrijeLucht => this == e || this == g;
}

enum Windsnelheid {
  windstil('0 m/s  (windstil, natuurlijke convectie)'),
  zwak('1–2 m/s  (zwak, lichte luchtbeweging)'),
  matig('3–5 m/s  (matig, gemengde convectie)'),
  sterk('5–10 m/s  (sterk, geforceerde convectie)'),
  storm('10+ m/s  (sterk geforceerd)');

  const Windsnelheid(this.label);
  final String label;
}

enum DakOrientatie {
  z('Zuid'),
  zo('Zuid-Oost'),
  zw('Zuid-West'),
  o('Oost'),
  w('West'),
  n('Noord');

  const DakOrientatie(this.label);
  final String label;
}

enum PvLaagPositie {
  topLaag('Bovenste laag  — volledige directe instraling  (+25 K)', 25.0),
  tweedeLaag('2e laag van boven  — gedeeltelijke instraling  (+12 K)', 12.0),
  middenLaag('Middenlaag  — minimale indirecte instraling  (+5 K)', 5.0),
  onderLaag('Onderste laag  — volledig beschaduwd  (+0 K)', 0.0);

  const PvLaagPositie(this.label, this.deltaTK);
  final String label;
  final double deltaTK;
}

enum BeveiligingType {
  mcbB('MCB type B  (Ia = 5×In)', 5),
  mcbC('MCB type C  (Ia = 10×In)', 10),
  mcbD('MCB type D  (Ia = 20×In)', 20),
  handmatig('Handmatig  (Ia direct invoeren)', 1),
  gg02('gG patroon  (t ≤ 0,2 s)', 0),
  gg04('gG patroon  (t ≤ 0,4 s)', 0),
  gg1 ('gG patroon  (t ≤ 1 s)',   0),
  gg5 ('gG patroon  (t ≤ 5 s)',   0);

  const BeveiligingType(this.label, this.factor);
  final String label;
  final double factor;

  bool get isGg => this == gg02 || this == gg04 || this == gg1 || this == gg5;

  double berekenIa(double waarde) {
    if (this == handmatig) return waarde;
    if (isGg) {
      final data = switch (this) {
        gg02 => _ggData02,
        gg04 => _ggData04,
        gg1  => _ggData1,
        _    => _ggData5,
      };
      return _ggOpzoeken(waarde, data);
    }
    return factor * waarde;
  }
}

/// gG smeltzekering minimale uitschakelstroom per IEC 60269
/// Format: { In [A] : Ia [A] }
final _ggData02 = <double, double>{
  10: 130, 16: 175, 20: 250, 25: 320, 32: 420, 40: 530, 50: 675, 63: 860, 80: 1150,
};
final _ggData04 = <double, double>{
  10:  80, 16: 110, 20: 155, 25: 195, 32: 265, 40: 330, 50: 430, 63: 540, 80:  720,
};
final _ggData1 = <double, double>{
  10:  46, 16:  65, 20:  90, 25: 115, 32: 150, 40: 190, 50: 250, 63: 315, 80:  420,
};
final _ggData5 = <double, double>{
  10:  22, 16:  32, 20:  45, 25:  57, 32:  75, 40:  95, 50: 125, 63: 160, 80:  215,
};

/// Lineaire interpolatie/extrapolatie op gesorteerde tabel.
double _ggOpzoeken(double inA, Map<double, double> tabel) {
  if (tabel.containsKey(inA)) return tabel[inA]!;
  final keys = tabel.keys.toList()..sort();
  if (inA <= keys.first) return tabel[keys.first]!;
  if (inA >= keys.last)  return tabel[keys.last]!;
  for (int i = 0; i < keys.length - 1; i++) {
    final k0 = keys[i], k1 = keys[i + 1];
    if (inA >= k0 && inA <= k1) {
      final t = (inA - k0) / (k1 - k0);
      return tabel[k0]! + t * (tabel[k1]! - tabel[k0]!);
    }
  }
  return inA;
}
