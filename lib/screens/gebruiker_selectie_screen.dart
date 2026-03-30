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
import '../models/gebruiker.dart';
import '../state/gebruikers_provider.dart';
import '../widgets/invoer_rij.dart';

class GebruikerSelectieScreen extends StatelessWidget {
  const GebruikerSelectieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gebruikers = context.select<GebruikersProvider, List<Gebruiker>>(
      (p) => p.gebruikers,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gebruikerSelectieTitel),
        automaticallyImplyLeading: false,
      ),
      body: gebruikers.isEmpty
          ? Center(
              child: Text(
                l10n.gebruikerSelectieLeeg,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: gebruikers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _GebruikerTegel(
                gebruiker: gebruikers[i],
                l10n: l10n,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _toonNieuwGebruikerDialog(context, l10n),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.gebruikerNieuw),
      ),
    );
  }

  static Future<void> _toonNieuwGebruikerDialog(
      BuildContext context, AppLocalizations l10n) async {
    final ctr = TextEditingController();
    final naam = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.gebruikerNieuw),
        content: TextField(
          controller: ctr,
          decoration: InputDecoration(
            labelText: l10n.gebruikerNaam,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnAnnuleren),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctr.text),
            child: Text(l10n.btnToevoegen),
          ),
        ],
      ),
    );
    ctr.dispose();
    if (naam != null && naam.trim().isNotEmpty && context.mounted) {
      await context.read<GebruikersProvider>().maakGebruiker(naam);
    }
  }
}

class _GebruikerTegel extends StatelessWidget {
  const _GebruikerTegel({required this.gebruiker, required this.l10n});
  final Gebruiker gebruiker;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initiaal = gebruiker.naam.isNotEmpty
        ? gebruiker.naam[0].toUpperCase()
        : '?';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          initiaal,
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(gebruiker.naam,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      onTap: () => context.read<GebruikersProvider>().selecteerGebruiker(gebruiker.id),
      trailing: _MenuKnop(gebruiker: gebruiker, l10n: l10n),
    );
  }
}

class _MenuKnop extends StatelessWidget {
  const _MenuKnop({required this.gebruiker, required this.l10n});
  final Gebruiker gebruiker;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuActie>(
      icon: const Icon(Icons.more_vert),
      onSelected: (actie) async {
        switch (actie) {
          case _MenuActie.hernoemen:
            await _hernoemen(context);
          case _MenuActie.standaardwaarden:
            await _bewerkenPreset(context);
          case _MenuActie.verwijderen:
            await _verwijderen(context);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _MenuActie.hernoemen,
          child: ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: Text(l10n.gebruikerHernoemen),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuActie.standaardwaarden,
          child: ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(l10n.gebruikerStandaardwaarden),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuActie.verwijderen,
          child: ListTile(
            leading: Icon(Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error),
            title: Text(l10n.gebruikerVerwijderen,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _hernoemen(BuildContext context) async {
    final ctr = TextEditingController(text: gebruiker.naam);
    final naam = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.gebruikerHernoemen),
        content: TextField(
          controller: ctr,
          decoration: InputDecoration(
            labelText: l10n.gebruikerNaam,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctr.text),
              child: Text(l10n.btnOpslaan)),
        ],
      ),
    );
    ctr.dispose();
    if (naam != null && naam.trim().isNotEmpty && context.mounted) {
      await context
          .read<GebruikersProvider>()
          .hernoemGebruiker(gebruiker.id, naam);
    }
  }

  Future<void> _bewerkenPreset(BuildContext context) async {
    final nieuw = await showDialog<GebruikerPreset>(
      context: context,
      builder: (ctx) => _PresetDialog(preset: gebruiker.preset, l10n: l10n),
    );
    if (nieuw != null && context.mounted) {
      await context.read<GebruikersProvider>().slaPresetOp(gebruiker.id, nieuw);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackPresetOpgeslagen)),
        );
      }
    }
  }

  Future<void> _verwijderen(BuildContext context) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.gebruikerVerwijderen),
        content: Text(l10n.gebruikerVerwijderenVraag),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.gebruikerVerwijderen),
          ),
        ],
      ),
    );
    if (bevestigd == true && context.mounted) {
      await context
          .read<GebruikersProvider>()
          .verwijderGebruiker(gebruiker.id);
    }
  }
}

enum _MenuActie { hernoemen, standaardwaarden, verwijderen }

// ── Preset-dialoog ────────────────────────────────────────────────────────────

class _PresetDialog extends StatefulWidget {
  const _PresetDialog({required this.preset, required this.l10n});
  final GebruikerPreset preset;
  final AppLocalizations l10n;

  @override
  State<_PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<_PresetDialog> {
  late GebruikerPreset _p;

  @override
  void initState() {
    super.initState();
    _p = widget.preset;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.presetTitel),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownRij<Systeemtype>(
                label: l10n.presetSysteem,
                waarde: _p.systeem,
                opties: Systeemtype.values,
                display: (s) => s.label,
                onChanged: (v) => setState(() => _p = _p.copyWith(systeem: v)),
              ),
              const SizedBox(height: 4),
              GetalVeld(
                label: l10n.presetSpanning,
                eenheid: 'V',
                waarde: _p.spanningV,
                onChanged: (v) => setState(() => _p = _p.copyWith(spanningV: v)),
                min: 12,
                max: 1000,
                decimalen: 0,
              ),
              const SizedBox(height: 4),
              DropdownRij<Geleidermateriaal>(
                label: l10n.presetGeleider,
                waarde: _p.geleider,
                opties: Geleidermateriaal.values,
                display: (g) => g.label,
                onChanged: (v) => setState(() => _p = _p.copyWith(geleider: v)),
              ),
              const SizedBox(height: 4),
              DropdownRij<Isolatiemateriaal>(
                label: l10n.presetIsolatie,
                waarde: _p.isolatie,
                opties: Isolatiemateriaal.values,
                display: (i) => i.label,
                onChanged: (v) => setState(() => _p = _p.copyWith(isolatie: v)),
              ),
              const SizedBox(height: 4),
              DropdownRij<Leggingswijze>(
                label: l10n.presetLegging,
                waarde: _p.legging,
                opties: Leggingswijze.values,
                display: (l) => l.label,
                onChanged: (v) => setState(() => _p = _p.copyWith(legging: v)),
              ),
              const SizedBox(height: 4),
              GetalVeld(
                label: l10n.presetOmgeving,
                eenheid: '°C',
                waarde: _p.omgevingstempC,
                onChanged: (v) => setState(() => _p = _p.copyWith(omgevingstempC: v)),
                min: -40,
                max: 60,
                decimalen: 0,
              ),
              const SizedBox(height: 4),
              GetalVeld(
                label: l10n.presetMaxSpanning,
                eenheid: '%',
                waarde: _p.maxSpanningsvalPct,
                onChanged: (v) => setState(() => _p = _p.copyWith(maxSpanningsvalPct: v)),
                min: 0.5,
                max: 10,
                decimalen: 1,
              ),
              const SizedBox(height: 4),
              GetalVeld(
                label: l10n.presetCosPhi,
                eenheid: '',
                waarde: _p.cosPhi,
                onChanged: (v) => setState(() => _p = _p.copyWith(cosPhi: v)),
                min: 0.5,
                max: 1.0,
                decimalen: 2,
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
          onPressed: () => Navigator.pop(context, _p),
          child: Text(l10n.btnOpslaan),
        ),
      ],
    );
  }
}
