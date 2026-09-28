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
import 'package:excel/excel.dart';
import '../l10n/app_localizations.dart';
import '../models/invoer.dart';
import '../models/kabel_boom.dart';
import '../models/resultaten.dart';
import 'rapport.dart';

/// Genereert een Excel-werkblad (.xlsx) voor één kabelberekening. Hergebruikt
/// dezelfde tekstgeneratie als het PDF/kopieer-rapport, zodat alle drie
/// exportvormen altijd dezelfde inhoud tonen.
Uint8List berekeningRapportExcel(Invoer inv, Resultaten r, AppLocalizations l10n) {
  final excel = Excel.createExcel();
  final standaardNaam = excel.getDefaultSheet()!;
  excel.rename(standaardNaam, 'Berekening');
  _schrijfTekstAlsRijen(excel['Berekening'], berekeningRapportTekst(inv, r, l10n));
  return Uint8List.fromList(excel.encode()!);
}

/// Genereert een Excel-werkboek voor het volledige kabelnet [boom]: een
/// overzichtsblad plus een apart blad per berekende leiding.
Uint8List boomRapportExcel(KabelBoom boom, AppLocalizations l10n) {
  final excel = Excel.createExcel();
  final standaardNaam = excel.getDefaultSheet()!;
  excel.rename(standaardNaam, 'Overzicht');
  _schrijfTekstAlsRijen(excel['Overzicht'], boomRapportTekst(boom, l10n));

  final gebruikteNamen = <String>{'Overzicht'};
  void voegLeidingToe(String? parentId) {
    for (final node in boom.nodes.where((n) => n.parentId == parentId)) {
      final r = node.resultaten;
      if (r != null) {
        try {
          final tekst = berekeningRapportTekst(node.invoer, r, l10n);
          final sheetNaam = _geldigeSheetNaam(node.naam, gebruikteNamen);
          gebruikteNamen.add(sheetNaam);
          _schrijfTekstAlsRijen(excel[sheetNaam], tekst);
        } catch (_) {
          // Sla over als rapport voor deze leiding niet gegenereerd kan worden
        }
      }
      voegLeidingToe(node.id);
    }
  }
  voegLeidingToe(null);

  return Uint8List.fromList(excel.encode()!);
}

/// Schrijft een tekstrapport (zoals gebruikt voor PDF/klembord) regel voor
/// regel naar [sheet]. Regels opgebouwd als "label" + gevuld tot kolom 26 +
/// "waarde" (zie `rij()` in rapport.dart) worden over twee kolommen
/// gesplitst; overige regels (formules, ASCII-tabellen) komen in kolom A.
void _schrijfTekstAlsRijen(Sheet sheet, String tekst) {
  final titelStijl = CellStyle(bold: true, fontSize: 14);
  final sectieStijl = CellStyle(bold: true, fontSize: 12);

  final regels = tekst.split('\n');
  var rij = 0;

  for (var i = 0; i < regels.length; i++) {
    final regel = regels[i];

    if (regel.startsWith('═') || regel.startsWith('─')) continue;

    if (regel.trim().isEmpty) {
      rij++;
      continue;
    }

    final isHoofdTitel = i == 0;
    final isSectieKop = i > 0 && _isNaSeparator(regels, i);

    if (isHoofdTitel || isSectieKop) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rij))
        ..value = TextCellValue(regel.trim())
        ..cellStyle = isHoofdTitel ? titelStijl : sectieStijl;
    } else {
      final gesplitst = _splitsLabelWaarde(regel);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rij))
          .value = TextCellValue(gesplitst.$1);
      if (gesplitst.$2 != null) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rij))
            .value = TextCellValue(gesplitst.$2!);
      }
    }
    rij++;
  }

  sheet.setColumnWidth(0, 34);
  sheet.setColumnWidth(1, 46);
}

bool _isNaSeparator(List<String> regels, int index) {
  if (index <= 0) return false;
  final vorige = regels[index - 1];
  return vorige.startsWith('─') || vorige.startsWith('═');
}

/// Splitst een regel in (label, waarde) als er vroeg in de regel een duidelijke
/// kolomscheiding (2+ spaties) staat — zoals `rij()` in rapport.dart die
/// produceert. Anders wordt de volledige regel als label teruggegeven.
(String, String?) _splitsLabelWaarde(String regel) {
  final match = RegExp(r'^(.{1,30}?) {2,}(.+)$').firstMatch(regel);
  if (match == null) return (regel, null);
  final label = match.group(1)!.trim();
  final waarde = match.group(2)!.trim();
  if (label.isEmpty) return (waarde, null);
  return (label, waarde);
}

/// Maakt van [naam] een geldige, unieke Excel-bladnaam (max. 31 tekens, geen
/// tekens \ / ? * [ ] : , niet leeg, niet al in gebruik binnen [bestaand]).
String _geldigeSheetNaam(String naam, Set<String> bestaand) {
  var basis = naam.replaceAll(RegExp(r'''[\\/?*\[\]:]'''), ' ').trim();
  if (basis.isEmpty) basis = 'Leiding';
  if (basis.length > 31) basis = basis.substring(0, 31);

  if (!bestaand.contains(basis)) return basis;

  var teller = 2;
  while (true) {
    final suffix = ' ($teller)';
    final maxBasisLengte = 31 - suffix.length;
    final kandidaat =
        '${basis.length > maxBasisLengte ? basis.substring(0, maxBasisLengte) : basis}$suffix';
    if (!bestaand.contains(kandidaat)) return kandidaat;
    teller++;
  }
}
