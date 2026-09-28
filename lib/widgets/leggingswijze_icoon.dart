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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/enums.dart';

/// Schematische afbeelding van een basisinstallatiemethode
/// (NEN 1010 tabel 52.B.1 / IEC 60364-5-52 tabel B.52.1).
/// Eigen tekening; volgt de kleuren van het actieve thema.
class LeggingswijzeIcoon extends StatelessWidget {
  final Leggingswijze legging;
  final double hoogte;

  const LeggingswijzeIcoon(this.legging, {super.key, this.hoogte = 40});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: hoogte * _b / _h,
      height: hoogte,
      child: CustomPaint(
        painter: _LeggingPainter(legging, cs.onSurface),
      ),
    );
  }
}

// Tekenruimte in logische eenheden; wordt geschaald naar de widgetgrootte.
const double _b = 60;
const double _h = 44;

class _LeggingPainter extends CustomPainter {
  final Leggingswijze legging;
  final Color kleur;

  _LeggingPainter(this.legging, this.kleur);

  late final Paint _lijn = Paint()
    ..color = kleur
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  late final Paint _dun = Paint()
    ..color = kleur.withValues(alpha: 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  late final Paint _vol = Paint()..color = kleur;
  late final Paint _wand = Paint()..color = kleur.withValues(alpha: 0.35);
  late final Paint _grond = Paint()..color = kleur.withValues(alpha: 0.2);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _b, size.height / _h);
    switch (legging) {
      case Leggingswijze.a1:
        _geisoleerdeWand(canvas, meeraderig: false);
      case Leggingswijze.a2:
        _geisoleerdeWand(canvas, meeraderig: true);
      case Leggingswijze.b1:
        _buisOpWand(canvas, meeraderig: false);
      case Leggingswijze.b2:
        _buisOpWand(canvas, meeraderig: true);
      case Leggingswijze.c:
        _methodeC(canvas);
      case Leggingswijze.d1:
        _inGrond(canvas, koker: true);
      case Leggingswijze.d2:
        _inGrond(canvas, koker: false);
      case Leggingswijze.e:
        _methodeE(canvas);
      case Leggingswijze.f:
        _methodeF(canvas);
      case Leggingswijze.g:
        _methodeG(canvas);
    }
  }

  // ── Bouwstenen ──────────────────────────────────────────────────────────

  /// Eenaderige kabel / installatiedraad: cirkel met geleider.
  void _ader(Canvas c, Offset m, double r) {
    c.drawCircle(m, r, _lijn);
    c.drawCircle(m, r * 0.35, _vol);
  }

  /// Meeraderige kabel: mantel met drie aders in driehoek.
  void _meeraderig(Canvas c, Offset m, double r) {
    c.drawCircle(m, r, _lijn);
    final ra = r * 0.4;
    final d = r - ra - r * 0.08;
    for (var i = 0; i < 3; i++) {
      final hoek = -math.pi / 2 + i * 2 * math.pi / 3;
      _ader(c, m + Offset(math.cos(hoek) * d, math.sin(hoek) * d), ra);
    }
  }

  /// Wand links (houten wand), rechterzijde op x = 10.
  void _wandLinks(Canvas c) {
    c.drawRect(const Rect.fromLTRB(5, 3, 10, 41), _wand);
    c.drawLine(const Offset(10, 3), const Offset(10, 41), _lijn);
  }

  /// Maatlijn met pijlpunten tussen x1 en x2 op hoogte y, met label.
  void _maat(Canvas c, double x1, double x2, double y, String tekst) {
    c.drawLine(Offset(x1, y), Offset(x2, y), _dun);
    for (final (x, s) in [(x1, 1.0), (x2, -1.0)]) {
      c.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + 2.2 * s, y - 1.2)
          ..lineTo(x + 2.2 * s, y + 1.2)
          ..close(),
        _vol,
      );
    }
    final tp = TextPainter(
      text: TextSpan(
          text: tekst, style: TextStyle(fontSize: 6, color: kleur)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(x2 + 1.5, y - tp.height / 2));
  }

  // ── Methoden ────────────────────────────────────────────────────────────

  /// A1/A2: buis in thermisch geïsoleerde wand, rechts de ruimte.
  void _geisoleerdeWand(Canvas c, {required bool meeraderig}) {
    const wand = Rect.fromLTRB(3, 3, 46, 41);
    const buisM = Offset(36, 30);
    const buisR = 9.0;

    // Isolatie (golflijnen), uitgespaard rond de buis.
    c.save();
    c.clipPath(Path.combine(
      PathOperation.difference,
      Path()..addRect(wand),
      Path()..addOval(Rect.fromCircle(center: buisM, radius: buisR + 1)),
    ));
    for (var x = 8.0; x < 46; x += 7) {
      final p = Path()..moveTo(x, 3);
      for (var y = 3.0; y < 41; y += 6) {
        p.quadraticBezierTo(x + 4, y + 3, x, y + 6);
      }
      c.drawPath(p, _dun);
    }
    c.restore();

    c.drawRect(wand, _lijn);
    // Binnenbeplating aan de ruimtezijde.
    c.drawRect(const Rect.fromLTRB(46, 3, 49, 41), _wand);
    c.drawLine(const Offset(49, 3), const Offset(49, 41), _lijn);

    c.drawCircle(buisM, buisR, _lijn);
    if (meeraderig) {
      _meeraderig(c, buisM + const Offset(0, 2), 6.5);
    } else {
      const r = 2.6;
      for (final dx in [-5.2, 0.0, 5.2]) {
        _ader(c, buisM + Offset(dx, buisR - r - 1.2 - (dx == 0 ? 0 : 0.8)), r);
      }
    }

    final tp = TextPainter(
      text: TextSpan(
          text: 'ruimte',
          style: TextStyle(fontSize: 5, color: kleur.withValues(alpha: 0.7))),
      textDirection: TextDirection.ltr,
    )..layout();
    c.save();
    c.translate(55, 22 + tp.width / 2);
    c.rotate(-math.pi / 2);
    tp.paint(c, Offset.zero);
    c.restore();
  }

  /// B1/B2: buis aangebracht tegen een houten wand.
  void _buisOpWand(Canvas c, {required bool meeraderig}) {
    _wandLinks(c);
    const buisM = Offset(24, 22);
    const buisR = 13.0;
    // Bevestigingsbeugel
    c.drawLine(const Offset(10, 35), Offset(buisM.dx, 35), _lijn);
    c.drawCircle(buisM, buisR, _lijn);
    if (meeraderig) {
      _meeraderig(c, buisM + const Offset(0, 3), 9);
    } else {
      const r = 3.6;
      _ader(c, buisM + const Offset(-7.2, 7), r);
      _ader(c, buisM + const Offset(0, 8.6), r);
      _ader(c, buisM + const Offset(7.2, 7), r);
    }
  }

  /// C: een- of meeraderige kabel direct tegen de wand.
  void _methodeC(Canvas c) {
    _wandLinks(c);
    const r = 3.2;
    for (var i = 0; i < 3; i++) {
      _ader(c, Offset(10 + r, 6 + i * 2 * r), r);
    }
    _meeraderig(c, const Offset(30, 28), 10);
    c.drawLine(const Offset(10, 28), const Offset(20, 28), _dun);
  }

  /// D1/D2: in de grond, al dan niet in een koker.
  void _inGrond(Canvas c, {required bool koker}) {
    const m = Offset(30, 28);
    final gat = koker ? 11.0 : 9.0;
    final grond = Path()..moveTo(2, 12);
    for (var x = 2.0; x < 58; x += 8) {
      grond.quadraticBezierTo(x + 4, 9, x + 8, 12);
    }
    grond
      ..lineTo(58, 42)
      ..lineTo(2, 42)
      ..close();
    c.drawPath(
      Path.combine(
        PathOperation.difference,
        grond,
        Path()..addOval(Rect.fromCircle(center: m, radius: gat)),
      ),
      _grond,
    );
    c.drawPath(grond, _dun);
    if (koker) {
      c.drawCircle(m, gat, _lijn);
      _meeraderig(c, m + const Offset(0, 2.5), 8);
    } else {
      _meeraderig(c, m, gat);
    }
  }

  /// E: meeraderige kabel in vrije lucht, ≥ 0,3·De van de wand.
  void _methodeE(Canvas c) {
    _wandLinks(c);
    const r = 9.0;
    const m = Offset(10 + 5 + r, 18);
    _meeraderig(c, m, r);
    c.drawLine(Offset(m.dx - r, m.dy), Offset(m.dx - r, 38), _dun);
    _maat(c, 10, m.dx - r, 36, '≥0,3 De');
  }

  /// F: tegen elkaar gelegde eenaderige kabels, ≥ De van de wand.
  void _methodeF(Canvas c) {
    _wandLinks(c);
    const r = 5.0;
    const x0 = 10 + 2 * r;
    const y0 = 22.0;
    _ader(c, const Offset(x0 + r, y0), r);
    _ader(c, const Offset(x0 + 3 * r, y0), r);
    _ader(c, Offset(x0 + 2 * r, y0 - r * math.sqrt(3)), r);
    c.drawLine(const Offset(x0, y0), const Offset(x0, 38), _dun);
    _maat(c, 10, x0, 36, '≥De');
  }

  /// G: op afstand gelegde eenaderige kabels, onderling en tot wand ≥ De.
  void _methodeG(Canvas c) {
    _wandLinks(c);
    const r = 3.5;
    const y = 18.0;
    final xs = [10 + 3 * r, 10 + 7 * r, 10 + 11 * r];
    for (final x in xs) {
      _ader(c, Offset(x, y), r);
    }
    c.drawLine(Offset(xs[0] - r, y + r), Offset(xs[0] - r, 38), _dun);
    c.drawLine(Offset(xs[0] + r, y + r), Offset(xs[0] + r, 30), _dun);
    c.drawLine(Offset(xs[1] - r, y + r), Offset(xs[1] - r, 30), _dun);
    _maat(c, 10, xs[0] - r, 36, '≥De');
    _maat(c, xs[0] + r, xs[1] - r, 28, '≥De');
  }

  @override
  bool shouldRepaint(_LeggingPainter old) =>
      old.legging != legging || old.kleur != kleur;
}
