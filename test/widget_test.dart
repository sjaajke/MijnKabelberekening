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
import 'package:kabelberekening/main.dart';
import 'package:kabelberekening/state/custom_catalogus_provider.dart';
import 'package:kabelberekening/state/gebruikers_provider.dart';
import 'package:kabelberekening/state/language_provider.dart';
import 'package:kabelberekening/state/projecten_provider.dart';
import 'package:kabelberekening/state/boom_provider.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    final projectenProvider = ProjectenProvider();
    await tester.pumpWidget(KabelberekeningApp(
      customProvider: CustomCatalogusProvider(),
      languageProvider: LanguageProvider(),
      projectenProvider: projectenProvider,
      gebruikersProvider: GebruikersProvider(projectenProvider),
      boomProvider: BoomProvider(),
    ));
    expect(find.text('Kabelberekening'), findsWidgets);
  });
}
