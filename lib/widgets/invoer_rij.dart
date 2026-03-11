import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Label + TextFormField voor getallen.
/// Stateful zodat de TextEditingController synchroon blijft met [waarde]
/// wanneer de parent de waarde programmatisch wijzigt (bijv. na een reset).
class GetalVeld extends StatefulWidget {
  final String label;
  final String eenheid;
  final double waarde;
  final ValueChanged<double> onChanged;
  final double? min;
  final double? max;
  final int decimalen;

  const GetalVeld({
    super.key,
    required this.label,
    required this.eenheid,
    required this.waarde,
    required this.onChanged,
    this.min,
    this.max,
    this.decimalen = 1,
  });

  @override
  State<GetalVeld> createState() => _GetalVeldState();
}

class _GetalVeldState extends State<GetalVeld> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.waarde.toStringAsFixed(widget.decimalen));
    _focusNode = FocusNode();
  }

  /// Synchroniseer de controller met de nieuwe [waarde] als het veld
  /// geen focus heeft (de gebruiker typt er dan niet in).
  @override
  void didUpdateWidget(covariant GetalVeld old) {
    super.didUpdateWidget(old);
    if (old.waarde != widget.waarde && !_focusNode.hasFocus) {
      _controller.text = widget.waarde.toStringAsFixed(widget.decimalen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.eenheid,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onChanged: (s) {
          final v = double.tryParse(s.replaceAll(',', '.'));
          if (v == null) return;
          if (widget.min != null && v < widget.min!) return;
          if (widget.max != null && v > widget.max!) return;
          widget.onChanged(v);
        },
      ),
    );
  }
}

/// Label + DropdownButtonFormField.
/// Gebruikt [key: ValueKey(waarde)] zodat het FormField opnieuw wordt
/// aangemaakt — en de weergave wordt bijgewerkt — wanneer [waarde]
/// programmatisch wijzigt (bijv. na reset door systeemtype-wisseling).
class DropdownRij<T> extends StatelessWidget {
  final String label;
  final T waarde;
  final List<T> opties;
  final String Function(T) display;
  final ValueChanged<T> onChanged;

  const DropdownRij({
    super.key,
    required this.label,
    required this.waarde,
    required this.opties,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<T>(
        key: ValueKey(waarde),
        initialValue: waarde,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: opties
            .map((o) => DropdownMenuItem(
                value: o,
                child: Text(display(o))))
            .toList(),
        selectedItemBuilder: (ctx) => opties
            .map((o) => Align(
                alignment: Alignment.centerLeft,
                child: Text(display(o),
                    overflow: TextOverflow.ellipsis, maxLines: 1)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Schakelaar met label.
class SchakelaarRij extends StatelessWidget {
  final String label;
  final bool waarde;
  final ValueChanged<bool> onChanged;

  const SchakelaarRij({
    super.key,
    required this.label,
    required this.waarde,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(child: Text(label)),
        Switch(value: waarde, onChanged: onChanged),
      ]),
    );
  }
}

/// Resultaatrij met label, waarde en optionele kleur.
class ResultaatRij extends StatelessWidget {
  final String label;
  final String waarde;
  final Color? kleur;
  final bool vet;

  const ResultaatRij({
    super.key,
    required this.label,
    required this.waarde,
    this.kleur,
    this.vet = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: vet ? FontWeight.bold : FontWeight.normal,
      color: kleur,
      fontFamily: 'monospace',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          Expanded(flex: 4, child: Text(waarde, style: style)),
        ],
      ),
    );
  }
}
