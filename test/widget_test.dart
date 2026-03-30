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

import 'package:flutter_test/flutter_test.dart';
import 'package:mijnkabelberekening/main.dart';
import 'package:mijnkabelberekening/state/berekening_provider.dart';
import 'package:mijnkabelberekening/state/custom_catalogus_provider.dart';
import 'package:mijnkabelberekening/state/gebruikers_provider.dart';
import 'package:mijnkabelberekening/state/language_provider.dart';
import 'package:mijnkabelberekening/state/projecten_provider.dart';
import 'package:mijnkabelberekening/state/theme_provider.dart';
import 'package:mijnkabelberekening/state/boom_provider.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    final projectenProvider = ProjectenProvider();
    final berekeningProvider = BerekeningProvider();
    await tester.pumpWidget(KabelberekeningApp(
      berekeningProvider: berekeningProvider,
      customProvider: CustomCatalogusProvider(),
      languageProvider: LanguageProvider(),
      themeProvider: ThemeProvider(),
      projectenProvider: projectenProvider,
      gebruikersProvider: GebruikersProvider(projectenProvider, berekeningProvider),
      boomProvider: BoomProvider(),
    ));
    expect(find.text('Kabelberekening'), findsWidgets);
  });
}
