import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.privacyTitel, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              l10n.privacyBijgewerkt,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyIntro,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _Sectie(
              nummer: '1',
              titel: l10n.privacy1Titel,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.privacy1Intro),
                  const SizedBox(height: 8),
                  ...l10n.privacy1Bullets.map((item) => _BulletRij(text: item)),
                  const SizedBox(height: 8),
                  Text(l10n.privacy1Slot),
                ],
              ),
            ),
            _Sectie(
              nummer: '2',
              titel: l10n.privacy2Titel,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.privacy2Intro),
                  const SizedBox(height: 8),
                  ...l10n.privacy2Bullets.map((item) => _BulletRij(text: item)),
                  const SizedBox(height: 8),
                  Text(l10n.privacy2Slot),
                ],
              ),
            ),
            _Sectie(
              nummer: '3',
              titel: l10n.privacy3Titel,
              body: Text(l10n.privacy3Body),
            ),
            _Sectie(
              nummer: '4',
              titel: l10n.privacy4Titel,
              body: Text(l10n.privacy4Body),
            ),
            _Sectie(
              nummer: '5',
              titel: l10n.privacy5Titel,
              body: Text(l10n.privacy5Body),
            ),
            _Sectie(
              nummer: '6',
              titel: l10n.privacy6Titel,
              body: Text(l10n.privacy6Body),
            ),
            _Sectie(
              nummer: '7',
              titel: l10n.privacy7Titel,
              body: Text(l10n.privacy7Body),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'v1.0.0',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Sectie extends StatelessWidget {
  const _Sectie({required this.nummer, required this.titel, required this.body});

  final String nummer;
  final String titel;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nummer. $titel',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}

class _BulletRij extends StatelessWidget {
  const _BulletRij({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
