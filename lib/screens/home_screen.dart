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
import '../state/gebruikers_provider.dart';
import '../state/language_provider.dart';
import 'boom_screen.dart';
import 'catalogus_screen.dart';
import 'correctiefactoren_screen.dart';
import 'invoer_screen.dart';
import 'privacy_screen.dart';
import 'projecten_screen.dart';
import 'resultaten_screen.dart';
import 'uitleg_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController aanwezig op alle layouts zodat InvoerScreen._bereken()
    // DefaultTabController.of(context).animateTo(1) altijd kan aanroepen.
    return DefaultTabController(
      length: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 720) {
            return const _BreedLayout();
          }
          return const _SmalLayout();
        },
      ),
    );
  }
}

// ── Gedeelde helpers ─────────────────────────────────────────────────────────

Widget _catalogusKnop(BuildContext context) => IconButton(
      icon: const Icon(Icons.table_chart_outlined),
      tooltip: context.l10n.navKabelcatalogus,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CatalogusScreen()),
      ),
    );

Widget _correctiefactorenKnop(BuildContext context) => IconButton(
      icon: const Icon(Icons.calculate_outlined),
      tooltip: context.l10n.navCorrectiefactoren,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CorrectiefactorenScreen()),
      ),
    );

Widget _uitlegKnop(BuildContext context) => IconButton(
      icon: const Icon(Icons.menu_book_outlined),
      tooltip: context.l10n.navBerekeningswijze,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UitlegScreen()),
      ),
    );

Widget _privacyKnop(BuildContext context) => IconButton(
      icon: const Icon(Icons.privacy_tip_outlined),
      tooltip: 'Privacy Policy',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PrivacyScreen()),
      ),
    );

Widget _projectenKnop(BuildContext context) => IconButton(
      icon: const Icon(Icons.folder_outlined),
      tooltip: context.l10n.navProjecten,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProjectenScreen()),
      ),
    );

Widget _boomKnop(BuildContext context) => IconButton(
      icon: const Icon(Icons.account_tree_outlined),
      tooltip: context.l10n.navBoomberekening,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BoomScreen()),
      ),
    );

class _GebruikerKnop extends StatelessWidget {
  const _GebruikerKnop();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GebruikersProvider>();
    final gebruiker = provider.actieveGebruiker;
    final initiaal =
        (gebruiker?.naam.isNotEmpty == true) ? gebruiker!.naam[0].toUpperCase() : '?';
    return Tooltip(
      message: context.l10n.gebruikerWisselen,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.read<GebruikersProvider>().wisselGebruiker(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              initiaal,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _taalKnop(BuildContext context) {
  final lang = context.watch<LanguageProvider>();
  final isNL = lang.locale.languageCode == 'nl';
  return TextButton(
    onPressed: () => lang.setLocale(
      isNL ? const Locale('en') : const Locale('nl'),
    ),
    style: TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    ),
    child: Text(
      isNL ? 'EN' : 'NL',
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );
}

// ── BREED (iPad landscape / desktop) ─────────────────────────────────────────
class _BreedLayout extends StatelessWidget {
  const _BreedLayout();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: false,
        actions: [
          const _GebruikerKnop(),
          _taalKnop(context),
          _privacyKnop(context),
          _uitlegKnop(context),
          _correctiefactorenKnop(context),
          _catalogusKnop(context),
          _boomKnop(context),
          _projectenKnop(context),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoerpaneel: vaste breedte (scrollbaar)
          SizedBox(
            width: 430,
            child: Material(
              elevation: 1,
              child: const InvoerScreen(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Resultatenspaneel: neemt resterende ruimte
          const Expanded(child: ResultatenScreen()),
        ],
      ),
    );
  }
}

// ── SMAL (telefoon / iPad portrait) ──────────────────────────────────────────
class _SmalLayout extends StatelessWidget {
  const _SmalLayout();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitleShort),
        centerTitle: false,
        actions: [
          const _GebruikerKnop(),
          _taalKnop(context),
          _privacyKnop(context),
          _uitlegKnop(context),
          _correctiefactorenKnop(context),
          _catalogusKnop(context),
          _projectenKnop(context),
        ],
        bottom: TabBar(
          tabs: [
            Tab(icon: const Icon(Icons.edit_note), text: l10n.tabInvoer),
            Tab(icon: const Icon(Icons.assessment), text: l10n.tabResultaten),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          InvoerScreen(),
          ResultatenScreen(),
        ],
      ),
    );
  }
}
