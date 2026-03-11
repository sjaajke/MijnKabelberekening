import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/gebruiker.dart';
import '../state/gebruikers_provider.dart';

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

enum _MenuActie { hernoemen, verwijderen }
