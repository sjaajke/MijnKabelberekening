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
import '../models/project.dart';
import '../state/projecten_provider.dart';
import 'project_detail_screen.dart';

class ProjectenScreen extends StatelessWidget {
  const ProjectenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ProjectenProvider>();
    final projecten = provider.projecten;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProjecten),
      ),
      body: projecten.isEmpty
          ? Center(
              child: Text(
                l10n.projectenLeeg,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: projecten.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) =>
                  _ProjectTegel(project: projecten[i], l10n: l10n),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toonNieuwProjectDialog(context, l10n),
        tooltip: l10n.projectNieuw,
        child: const Icon(Icons.create_new_folder_outlined),
      ),
    );
  }

  static Future<void> _toonNieuwProjectDialog(
      BuildContext context, AppLocalizations l10n) async {
    final ctr = TextEditingController();
    final naam = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.projectNieuw),
        content: TextField(
          controller: ctr,
          decoration: InputDecoration(
            labelText: l10n.projectNaam,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
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
      await context.read<ProjectenProvider>().maakProject(naam);
    }
  }
}

class _ProjectTegel extends StatelessWidget {
  const _ProjectTegel({required this.project, required this.l10n});
  final Project project;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gewijzigd = _datumLabel(project.gewijzigd);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.folder_outlined,
            color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(project.naam,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${l10n.berekeningen(project.berekeningen.length)}  ·  ${l10n.gewijzigd}: $gewijzigd',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.outline),
      ),
      trailing: _MenuKnop(project: project, l10n: l10n),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: project.id),
        ),
      ),
    );
  }

  String _datumLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      return l10n.isNL
          ? '${diff.inDays} dag${diff.inDays == 1 ? '' : 'en'} geleden'
          : '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return '${dt.day}-${dt.month}-${dt.year}';
  }
}

class _MenuKnop extends StatelessWidget {
  const _MenuKnop({required this.project, required this.l10n});
  final Project project;
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
            title: Text(l10n.projectHernoemen),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuActie.verwijderen,
          child: ListTile(
            leading: Icon(Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error),
            title: Text(l10n.projectVerwijderen,
                style:
                    TextStyle(color: Theme.of(ctx).colorScheme.error)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _hernoemen(BuildContext context) async {
    final ctr = TextEditingController(text: project.naam);
    final naam = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.projectHernoemen),
        content: TextField(
          controller: ctr,
          decoration: InputDecoration(
            labelText: l10n.projectNaam,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
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
      await context.read<ProjectenProvider>().hernoemProject(project.id, naam);
    }
  }

  Future<void> _verwijderen(BuildContext context) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.projectVerwijderen),
        content: Text(l10n.projectVerwijderenVraag),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.projectVerwijderen),
          ),
        ],
      ),
    );
    if (bevestigd == true && context.mounted) {
      await context.read<ProjectenProvider>().verwijderProject(project.id);
    }
  }
}

enum _MenuActie { hernoemen, verwijderen }
