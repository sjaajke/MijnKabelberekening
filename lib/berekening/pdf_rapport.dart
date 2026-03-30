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

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../l10n/app_localizations.dart';
import '../models/invoer.dart';
import '../models/kabel_boom.dart';
import '../models/resultaten.dart';
import 'rapport.dart';

Future<Uint8List> berekeningRapportPdf(
    Invoer inv, Resultaten r, AppLocalizations l10n) async {
  // NotoSans heeft volledige Unicode-ondersteuning (φ, Ω, Δ, √, ─, ═, enz.)
  // NotoSansRegular dient als fallback voor wiskundige symbolen die
  // NotoSansMono niet bevat (bijv. √ U+221A).
  final fontRegular = await PdfGoogleFonts.notoSansRegular();
  final fontBold = await PdfGoogleFonts.notoSansBold();
  final fontMono = await PdfGoogleFonts.notoSansMonoRegular();

  final doc = pw.Document();

  final tekst = berekeningRapportTekst(inv, r, l10n);
  final regels = tekst.split('\n');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      build: (context) {
        final widgets = <pw.Widget>[];

        for (var i = 0; i < regels.length; i++) {
          final regel = regels[i];

          if (regel.startsWith('═') || regel.startsWith('─')) {
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 2),
                height: 0.5,
                color: PdfColors.grey600,
              ),
            );
          } else if (regel.isEmpty) {
            widgets.add(pw.SizedBox(height: 5));
          } else {
            final isHoofdTitel = i == 0;
            final isSectieKop =
                i > 0 && _isNaSeparator(regels, i);

            widgets.add(
              pw.Text(
                regel,
                style: pw.TextStyle(
                  font: isSectieKop || isHoofdTitel ? fontBold : fontMono,
                  fontFallback: [fontRegular, fontBold],
                  fontSize: isHoofdTitel ? 11 : (isSectieKop ? 9 : 8),
                ),
              ),
            );
          }
        }

        return widgets;
      },
    ),
  );

  return doc.save();
}

bool _isNaSeparator(List<String> regels, int index) {
  if (index <= 0) return false;
  final vorige = regels[index - 1];
  return vorige.startsWith('─') || vorige.startsWith('═');
}

Future<Uint8List> boomRapportPdf(
    KabelBoom boom, AppLocalizations l10n) async {
  final fontRegular = await PdfGoogleFonts.notoSansRegular();
  final fontBold = await PdfGoogleFonts.notoSansBold();
  final fontMono = await PdfGoogleFonts.notoSansMonoRegular();

  final doc = pw.Document();

  // ── Pagina 1+: kabelnet-overzicht ─────────────────────────────────────────
  _voegTekstPaginaToe(doc, boomRapportTekst(boom, l10n),
      fontRegular: fontRegular, fontBold: fontBold, fontMono: fontMono);

  // ── Vervolg: volledige kabelberekeningsrapport per berekende leiding ───────
  // Diepte-eerst volgorde (zelfde als boomRapportTekst).
  void voegLeidingToe(String? parentId) {
    for (final node in boom.nodes.where((n) => n.parentId == parentId)) {
      final r = node.resultaten;
      if (r != null) {
        try {
          final tekst = berekeningRapportTekst(node.invoer, r, l10n);
          _voegTekstPaginaToe(
            doc,
            'LEIDING: ${node.naam}\n$tekst',
            fontRegular: fontRegular,
            fontBold: fontBold,
            fontMono: fontMono,
          );
        } catch (_) {
          // Sla over als rapport voor deze leiding niet gegenereerd kan worden
        }
      }
      voegLeidingToe(node.id);
    }
  }
  voegLeidingToe(null);

  return doc.save();
}

void _voegTekstPaginaToe(
  pw.Document doc,
  String tekst, {
  required pw.Font fontRegular,
  required pw.Font fontBold,
  required pw.Font fontMono,
}) {
  final regels = tekst.split('\n');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      build: (context) {
        final widgets = <pw.Widget>[];
        for (var i = 0; i < regels.length; i++) {
          final regel = regels[i];
          if (regel.startsWith('═') || regel.startsWith('─')) {
            widgets.add(pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 2),
              height: 0.5,
              color: PdfColors.grey600,
            ));
          } else if (regel.isEmpty) {
            widgets.add(pw.SizedBox(height: 5));
          } else {
            final isHoofdTitel = i == 0;
            final isSectieKop = i > 0 && _isNaSeparator(regels, i);
            widgets.add(pw.Text(
              regel,
              style: pw.TextStyle(
                font: isSectieKop || isHoofdTitel ? fontBold : fontMono,
                fontFallback: [fontRegular, fontBold],
                fontSize: isHoofdTitel ? 11 : (isSectieKop ? 9 : 8),
              ),
            ));
          }
        }
        return widgets;
      },
    ),
  );
}
