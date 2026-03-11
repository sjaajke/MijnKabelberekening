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
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/enums.dart';
import '../models/kabel_spec.dart';

class KabelToevoegenDialog extends StatefulWidget {
  const KabelToevoegenDialog({super.key, this.bestaande});

  final KabelSpec? bestaande;

  @override
  State<KabelToevoegenDialog> createState() => _KabelToevoegenDialogState();
}

class _KabelToevoegenDialogState extends State<KabelToevoegenDialog> {
  final _formKey = GlobalKey<FormState>();

  late Geleidermateriaal _geleider;
  late Isolatiemateriaal _isolatie;
  late int _aantalAders;
  final _doorsnedeCtr = TextEditingController();
  final _naamCtr = TextEditingController();
  final _buitendiameterCtr = TextEditingController();
  final _rAcCtr = TextEditingController();
  final _xAcCtr = TextEditingController();
  final _izCCtr = TextEditingController();
  final _izECtr = TextEditingController();
  final _izC3Ctr = TextEditingController();
  final _izE3Ctr = TextEditingController();

  @override
  void initState() {
    super.initState();
    final k = widget.bestaande;
    _geleider = k?.geleider ?? Geleidermateriaal.koper;
    _isolatie = k?.isolatie ?? Isolatiemateriaal.pvc;
    _aantalAders = k?.aantalAders ?? 3;
    _doorsnedeCtr.text = k != null ? _fmt(k.doorsnedemm2) : '';
    _naamCtr.text = k?.naam ?? '';
    _buitendiameterCtr.text = k != null ? _fmt(k.buitendiameter) : '';
    _rAcCtr.text = k != null ? k.rAcPerKm20C.toString() : '';
    _xAcCtr.text = k != null ? k.xAcPerKm.toString() : '0.075';
    _izCCtr.text = k != null ? _fmt(k.izC) : '';
    _izECtr.text = k != null ? _fmt(k.izE) : '';
    _izC3Ctr.text = k != null ? _fmt(k.izC3) : '0';
    _izE3Ctr.text = k != null ? _fmt(k.izE3) : '0';
  }

  @override
  void dispose() {
    for (final c in [
      _doorsnedeCtr, _naamCtr, _buitendiameterCtr, _rAcCtr, _xAcCtr,
      _izCCtr, _izECtr, _izC3Ctr, _izE3Ctr,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
  double _parseDouble(String s) => double.parse(s.replaceAll(',', '.'));

  void _opslaan() {
    if (!_formKey.currentState!.validate()) return;

    final doorsnede = _parseDouble(_doorsnedeCtr.text);
    final naam = _naamCtr.text.trim().isEmpty
        ? '${_fmt(doorsnede)} mm² ${_geleider.label} ${_isolatie.label} $_aantalAders×'
        : _naamCtr.text.trim();

    final kabel = KabelSpec(
      naam: naam,
      doorsnedemm2: doorsnede,
      aantalAders: _aantalAders,
      geleider: _geleider,
      isolatie: _isolatie,
      buitendiameter: _parseDouble(_buitendiameterCtr.text),
      rAcPerKm20C: _parseDouble(_rAcCtr.text),
      xAcPerKm: _parseDouble(_xAcCtr.text),
      izC: _parseDouble(_izCCtr.text),
      izE: _parseDouble(_izECtr.text),
      izC3: _aantalAders == 1 ? _parseDouble(_izC3Ctr.text) : 0,
      izE3: _aantalAders == 1 ? _parseDouble(_izE3Ctr.text) : 0,
    );
    Navigator.pop(context, kabel);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.bestaande != null;
    return AlertDialog(
      title: Text(isEdit ? l10n.dlgKabelBewerken : l10n.dlgKabelToevoegen),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectieLabel(context, l10n.dlgSectIdentificatie),
              _dropdownRij<Geleidermateriaal>(
                label: l10n.lblGeleider,
                waarde: _geleider,
                opties: Geleidermateriaal.values,
                display: (g) => g.label,
                onChanged: (v) => setState(() => _geleider = v),
              ),
              const SizedBox(height: 8),
              _dropdownRij<Isolatiemateriaal>(
                label: l10n.lblIsolatie,
                waarde: _isolatie,
                opties: Isolatiemateriaal.values,
                display: (i) => i.label,
                onChanged: (v) => setState(() => _isolatie = v),
              ),
              const SizedBox(height: 8),
              _dropdownRij<int>(
                label: l10n.lblAantalAders,
                waarde: _aantalAders,
                opties: const [1, 2, 3, 4, 5],
                display: (n) => '$n×',
                onChanged: (v) => setState(() => _aantalAders = v),
              ),
              const SizedBox(height: 8),
              _getalVeld(
                ctr: _doorsnedeCtr,
                label: l10n.lblDoorsnede,
                eenheid: 'mm²',
                hint: l10n.dlgHintDoorsnede,
                validator: (v) => _valideerPositief(v, l10n),
              ),
              const SizedBox(height: 8),
              _tekstVeld(
                ctr: _naamCtr,
                label: l10n.dlgLblNaam,
                hint: l10n.dlgHintNaam,
                vereist: false,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              _sectieLabel(context, l10n.dlgSectElektrisch),
              _getalVeld(
                ctr: _rAcCtr,
                label: 'R_AC 20°C',
                eenheid: 'Ω/km',
                hint: l10n.dlgHintRac,
                validator: (v) => _valideerPositief(v, l10n),
              ),
              const SizedBox(height: 8),
              _getalVeld(
                ctr: _xAcCtr,
                label: 'X 50 Hz',
                eenheid: 'Ω/km',
                hint: l10n.dlgHintX,
                validator: (v) => _valideerNietNegatief(v, l10n),
              ),
              const SizedBox(height: 16),
              _sectieLabel(context, l10n.dlgSectStroom),
              _getalVeld(
                ctr: _izCCtr,
                label: 'I_z methode C',
                eenheid: 'A',
                hint: l10n.dlgHintIzC,
                validator: (v) => _valideerPositief(v, l10n),
              ),
              const SizedBox(height: 8),
              _getalVeld(
                ctr: _izECtr,
                label: 'I_z methode E',
                eenheid: 'A',
                hint: l10n.dlgHintIzE,
                validator: (v) => _valideerPositief(v, l10n),
              ),
              if (_aantalAders == 1) ...[
                const SizedBox(height: 8),
                _getalVeld(
                  ctr: _izC3Ctr,
                  label: l10n.dlgIzC3Fase,
                  eenheid: 'A',
                  hint: l10n.dlgHintIz3Fase,
                  validator: (v) => _valideerNietNegatief(v, l10n),
                ),
                const SizedBox(height: 8),
                _getalVeld(
                  ctr: _izE3Ctr,
                  label: l10n.dlgIzE3Fase,
                  eenheid: 'A',
                  hint: l10n.dlgHintIz3Fase,
                  validator: (v) => _valideerNietNegatief(v, l10n),
                ),
              ],
              const SizedBox(height: 16),
              _sectieLabel(context, l10n.dlgSectGeometrie),
              _getalVeld(
                ctr: _buitendiameterCtr,
                label: l10n.lblBuitendiameter,
                eenheid: 'mm',
                hint: l10n.dlgHintBuiten,
                validator: (v) => _valideerPositief(v, l10n),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnAnnuleren),
        ),
        FilledButton(
          onPressed: _opslaan,
          child: Text(isEdit ? l10n.btnOpslaan : l10n.btnToevoegen),
        ),
      ],
    );
  }

  Widget _sectieLabel(BuildContext context, String tekst) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          tekst,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );

  Widget _dropdownRij<T>({
    required String label,
    required T waarde,
    required List<T> opties,
    required String Function(T) display,
    required ValueChanged<T> onChanged,
  }) =>
      Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: DropdownButtonFormField<T>(
              initialValue: waarde,
              isDense: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: opties
                  .map((o) => DropdownMenuItem(value: o, child: Text(display(o))))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      );

  Widget _getalVeld({
    required TextEditingController ctr,
    required String label,
    required String eenheid,
    String? hint,
    required String? Function(String?) validator,
  }) =>
      Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: TextFormField(
              controller: ctr,
              decoration: InputDecoration(
                suffixText: eenheid,
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: validator,
            ),
          ),
        ],
      );

  Widget _tekstVeld({
    required TextEditingController ctr,
    required String label,
    String? hint,
    bool vereist = true,
    required AppLocalizations l10n,
  }) =>
      Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: TextFormField(
              controller: ctr,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              validator: vereist
                  ? (v) => (v == null || v.trim().isEmpty)
                      ? l10n.valideerVerplichtVeld
                      : null
                  : null,
            ),
          ),
        ],
      );

  String? _valideerPositief(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.valideerVerplicht;
    final d = double.tryParse(v.replaceAll(',', '.'));
    if (d == null) return l10n.valideerOngeldigGetal;
    if (d <= 0) return l10n.valideerGroterDanNul;
    return null;
  }

  String? _valideerNietNegatief(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.valideerVerplicht;
    final d = double.tryParse(v.replaceAll(',', '.'));
    if (d == null) return l10n.valideerOngeldigGetal;
    if (d < 0) return l10n.valideerNietNegatief;
    return null;
  }
}
