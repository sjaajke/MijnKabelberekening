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
import 'state/berekening_provider.dart';
import 'state/boom_provider.dart';
import 'state/custom_catalogus_provider.dart';
import 'state/gebruikers_provider.dart';
import 'state/language_provider.dart';
import 'state/projecten_provider.dart';
import 'state/theme_provider.dart';
import 'screens/gebruiker_selectie_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final customProvider = CustomCatalogusProvider();
  final languageProvider = LanguageProvider();
  final themeProvider = ThemeProvider();
  final projectenProvider = ProjectenProvider();
  final berekeningProvider = BerekeningProvider();
  final gebruikersProvider = GebruikersProvider(projectenProvider, berekeningProvider);
  final boomProvider = BoomProvider();
  await Future.wait([
    customProvider.laad(),
    languageProvider.laad(),
    themeProvider.laad(),
    gebruikersProvider.laad(),
    boomProvider.laad(),
  ]);
  runApp(KabelberekeningApp(
    berekeningProvider: berekeningProvider,
    customProvider: customProvider,
    languageProvider: languageProvider,
    themeProvider: themeProvider,
    projectenProvider: projectenProvider,
    gebruikersProvider: gebruikersProvider,
    boomProvider: boomProvider,
  ));
}

class KabelberekeningApp extends StatelessWidget {
  const KabelberekeningApp({
    super.key,
    required this.berekeningProvider,
    required this.customProvider,
    required this.languageProvider,
    required this.themeProvider,
    required this.projectenProvider,
    required this.gebruikersProvider,
    required this.boomProvider,
  });

  final BerekeningProvider berekeningProvider;
  final CustomCatalogusProvider customProvider;
  final LanguageProvider languageProvider;
  final ThemeProvider themeProvider;
  final ProjectenProvider projectenProvider;
  final GebruikersProvider gebruikersProvider;
  final BoomProvider boomProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: berekeningProvider),
        ChangeNotifierProvider.value(value: customProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: projectenProvider),
        ChangeNotifierProvider.value(value: gebruikersProvider),
        ChangeNotifierProvider.value(value: boomProvider),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (_, lang, theme, _) => MaterialApp(
          title: 'Kabelberekening',
          debugShowCheckedModeBanner: false,
          locale: lang.locale,
          themeMode: theme.mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const _AppRouter(),
        ),
      ),
    );
  }
}

/// Switches between GebruikerSelectieScreen and HomeScreen based on
/// whether a user is active. This is the sole widget that watches
/// GebruikersProvider for routing purposes — keeping MaterialApp.home
/// constant avoids the "_dependents.isEmpty" assertion.
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final actief = context.select<GebruikersProvider, bool>(
      (p) => p.actieveGebruikerId != null,
    );
    return actief ? const HomeScreen() : const GebruikerSelectieScreen();
  }
}
