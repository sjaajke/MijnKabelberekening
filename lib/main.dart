import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/berekening_provider.dart';
import 'state/boom_provider.dart';
import 'state/custom_catalogus_provider.dart';
import 'state/gebruikers_provider.dart';
import 'state/language_provider.dart';
import 'state/projecten_provider.dart';
import 'screens/gebruiker_selectie_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final customProvider = CustomCatalogusProvider();
  final languageProvider = LanguageProvider();
  final projectenProvider = ProjectenProvider();
  final gebruikersProvider = GebruikersProvider(projectenProvider);
  final boomProvider = BoomProvider();
  await Future.wait([
    customProvider.laad(),
    languageProvider.laad(),
    gebruikersProvider.laad(),
    boomProvider.laad(),
  ]);
  runApp(KabelberekeningApp(
    customProvider: customProvider,
    languageProvider: languageProvider,
    projectenProvider: projectenProvider,
    gebruikersProvider: gebruikersProvider,
    boomProvider: boomProvider,
  ));
}

class KabelberekeningApp extends StatelessWidget {
  const KabelberekeningApp({
    super.key,
    required this.customProvider,
    required this.languageProvider,
    required this.projectenProvider,
    required this.gebruikersProvider,
    required this.boomProvider,
  });

  final CustomCatalogusProvider customProvider;
  final LanguageProvider languageProvider;
  final ProjectenProvider projectenProvider;
  final GebruikersProvider gebruikersProvider;
  final BoomProvider boomProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BerekeningProvider()),
        ChangeNotifierProvider.value(value: customProvider),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: projectenProvider),
        ChangeNotifierProvider.value(value: gebruikersProvider),
        ChangeNotifierProvider.value(value: boomProvider),
      ],
      child: Consumer<LanguageProvider>(
        builder: (_, lang, _) => MaterialApp(
          title: 'Kabelberekening',
          debugShowCheckedModeBanner: false,
          locale: lang.locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
