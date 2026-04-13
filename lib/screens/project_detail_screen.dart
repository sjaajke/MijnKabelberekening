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
import 'package:provider/provider.dart';
import '../berekening/ontwerper.dart';
import '../berekening/rapport.dart';
import '../l10n/app_localizations.dart';
import '../models/invoer.dart';
import '../models/project.dart';
import '../state/berekening_provider.dart';
import '../state/boom_provider.dart';
import '../state/projecten_provider.dart';
import 'boom_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ProjectenProvider>();
    final project =
        provider.projecten.where((p) => p.id == projectId).firstOrNull;

    if (project == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.naam),
        actions: [
          if (project.berekeningen.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: l10n.projectKopieerAlles,
              onPressed: () => _kopieerAlles(context, project, l10n),
            ),
        ],
      ),
      body: (project.berekeningen.isEmpty && project.bomen.isEmpty)
          ? Center(
              child: Text(
                l10n.berekeningLeeg,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (project.berekeningen.isNotEmpty) ...[
                  _SectieKop(titel: l10n.sectBerekeningen),
                  ...project.berekeningen.map((b) => _BerekeningTegel(
                        berekening: b,
                        projectId: projectId,
                        l10n: l10n,
                      )),
                ],
                if (project.bomen.isNotEmpty) ...[
                  _SectieKop(titel: l10n.sectKabelnetten),
                  ...project.bomen.map((b) => _BoomTegel(
                        opgeslaanBoom: b,
                        projectId: projectId,
                        l10n: l10n,
                      )),
                ],
              ],
            ),
    );
  }

  static void _kopieerAlles(
      BuildContext context, Project project, AppLocalizations l10n) {
    final buf = StringBuffer();
    final nu = DateTime.now();
    final datum =
        '${nu.day.toString().padLeft(2, '0')}-${nu.month.toString().padLeft(2, '0')}-${nu.year}'
        '  ${nu.hour.toString().padLeft(2, '0')}:${nu.minute.toString().padLeft(2, '0')}';

    // Bereken alle resultaten eenmalig.
    final items = project.berekeningen
        .map((b) => (b, KabelOntwerper(b.invoer).bereken()))
        .toList();

    // ── SAMENVATTING ────────────────────────────────────────────────
    buf.writeln(l10n.projectRapportHeader);
    buf.writeln('${'Project'.padRight(10)}: ${project.naam}');
    buf.writeln('${'Datum'.padRight(10)}: $datum');
    buf.writeln(l10n.rapportNorm);
    buf.writeln('═' * 64);
    buf.writeln();
    buf.writeln(l10n.rapportSamenvatting);
    buf.writeln('─' * 64);
    buf.writeln(
        '${'#'.padRight(3)}${'Naam'.padRight(22)}${'Kabel'.padRight(20)}'
        '${'Iz'.padRight(8)}${'ΔU%'.padRight(8)}Status');
    buf.writeln('─' * 64);

    for (var i = 0; i < items.length; i++) {
      final (b, res) = items[i];
      final nr    = '${i + 1}'.padRight(3);
      final naam  = _trunc(b.naam, 21).padRight(22);
      final kabel = res.kabel != null
          ? _trunc(res.kabel!.naam, 19).padRight(20)
          : '—'.padRight(20);
      final iz    = res.kabel != null
          ? '${res.iz.toStringAsFixed(1)} A'.padRight(8)
          : '—'.padRight(8);
      final du    = res.kabel != null
          ? '${res.deltaUPct.toStringAsFixed(2)} %'.padRight(8)
          : '—'.padRight(8);
      final ok    = res.voldoet ? '✓' : '✗';
      buf.writeln('$nr$naam$kabel$iz$du$ok');
    }

    buf.writeln('═' * 64);
    buf.writeln();

    // ── VOLLEDIGE RAPPORTEN ─────────────────────────────────────────
    for (var i = 0; i < items.length; i++) {
      if (i > 0) buf.writeln('\n${'═' * 64}\n');
      final (b, res) = items[i];
      buf.writeln('${i + 1}. ${b.naam}');
      buf.write(berekeningRapportTekst(b.invoer, res, l10n));
    }

    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.snackProjectGekopieerd),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String _trunc(String s, int max) =>
      s.length > max ? '${s.substring(0, max - 1)}…' : s;
}

class _BerekeningTegel extends StatelessWidget {
  const _BerekeningTegel({
    required this.berekening,
    required this.projectId,
    required this.l10n,
  });
  final OpgeslaanBerekening berekening;
  final String projectId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final invoer = berekening.invoer;
    final res = KabelOntwerper(invoer).bereken();
    final samenvatting = l10n.berekeningSamenvatting(
      invoer.systeem.label,
      invoer.effectieveStroom,
      invoer.lengteM,
    );
    final datum = _datumLabel(berekening.aangemaakt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: res.voldoet
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.errorContainer,
        child: Icon(
          res.voldoet ? Icons.check : Icons.close,
          color: res.voldoet
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onErrorContainer,
          size: 20,
        ),
      ),
      title: Text(berekening.naam,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(samenvatting,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
          if (res.kabel != null)
            Text(
              '${res.kabel!.naam}  ·  I_z ${res.iz.toStringAsFixed(1)} A  ·  ΔU ${res.deltaUPct.toStringAsFixed(2)} %',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          Text(datum,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        tooltip: l10n.berekeningVerwijderen,
        onPressed: () => _verwijderen(context),
      ),
      onTap: () => _laden(context, invoer),
    );
  }

  Future<void> _laden(BuildContext context, Invoer invoer) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.berekeningLaden),
        content: Text(l10n.berekeningLadenVraag),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.berekeningLaden)),
        ],
      ),
    );
    if (bevestigd == true && context.mounted) {
      context.read<BerekeningProvider>().updateInvoer(invoer);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _verwijderen(BuildContext context) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.berekeningVerwijderen),
        content: Text('${berekening.naam}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.berekeningVerwijderen),
          ),
        ],
      ),
    );
    if (bevestigd == true && context.mounted) {
      await context
          .read<ProjectenProvider>()
          .verwijderBerekening(projectId, berekening.id);
    }
  }

  String _datumLabel(DateTime dt) {
    final tijd = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day}-${dt.month}-${dt.year}  $tijd';
  }
}

class _SectieKop extends StatelessWidget {
  const _SectieKop({required this.titel});
  final String titel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        titel,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _BoomTegel extends StatelessWidget {
  const _BoomTegel({
    required this.opgeslaanBoom,
    required this.projectId,
    required this.l10n,
  });
  final OpgeslaanBoom opgeslaanBoom;
  final String projectId;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boom = opgeslaanBoom.boom;
    final datum = _datumLabel(opgeslaanBoom.aangemaakt);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.tertiaryContainer,
        child: Icon(Icons.account_tree_outlined,
            color: theme.colorScheme.onTertiaryContainer, size: 20),
      ),
      title: Text(opgeslaanBoom.naam,
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${boom.nodes.length} leidingen  ·  ${boom.transformatorKva.toInt()} kVA  ·  $datum',
        style:
            theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        tooltip: l10n.boomVerwijderenUitProject,
        onPressed: () => _verwijderen(context),
      ),
      onTap: () => _laden(context, boom),
    );
  }

  Future<void> _laden(BuildContext context, dynamic boom) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.boomLaden),
        content: Text(l10n.boomLadenVraag),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.boomLaden)),
        ],
      ),
    );
    if (bevestigd == true && context.mounted) {
      final boomP = context.read<BoomProvider>();
      await boomP.laadBoom(opgeslaanBoom.boom);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BoomScreen()),
        );
      }
    }
  }

  Future<void> _verwijderen(BuildContext context) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.boomVerwijderenUitProject),
        content: Text('${opgeslaanBoom.naam}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnAnnuleren)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(l10n.boomVerwijderenUitProject),
          ),
        ],
      ),
    );
    if (bevestigd == true && context.mounted) {
      await context
          .read<ProjectenProvider>()
          .verwijderBoom(projectId, opgeslaanBoom.id);
    }
  }

  String _datumLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}-${dt.month}-${dt.year}';
  }
}
