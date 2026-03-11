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
