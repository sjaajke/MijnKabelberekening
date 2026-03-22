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
import '../l10n/app_localizations.dart';
import '../l10n/handleiding_localizations.dart';
import '../widgets/sectie_card.dart';

/// Quickstart-handleiding — hoe gebruik je de app?
class HandleidingScreen extends StatelessWidget {
  const HandleidingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.hdlTitel)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IntroSectie(),
            const SizedBox(height: 8),
            _StapSectie(
              stap: 1,
              titel: context.l10n.hdlSysteemTitel,
              tekst: context.l10n.hdlSysteemTekst,
              afbeeldingLabel: context.l10n.hdlSysteemAfb,
              afbeeldingAsset: 'assets/handleiding/qs_systeem.png',
              icoon: Icons.electrical_services_outlined,
            ),
            const SizedBox(height: 8),
            _StapSectie(
              stap: 2,
              titel: context.l10n.hdlBelastingTitel,
              tekst: context.l10n.hdlBelastingTekst,
              afbeeldingLabel: context.l10n.hdlBelastingAfb,
              afbeeldingAsset: 'assets/handleiding/qs_belasting.png',
              icoon: Icons.power_outlined,
            ),
            const SizedBox(height: 8),
            _StapSectie(
              stap: 3,
              titel: context.l10n.hdlKabelTitel,
              tekst: context.l10n.hdlKabelTekst,
              afbeeldingLabel: context.l10n.hdlKabelAfb,
              afbeeldingAsset: 'assets/handleiding/qs_kabel.png',
              icoon: Icons.cable_outlined,
            ),
            const SizedBox(height: 8),
            _StapSectie(
              stap: 4,
              titel: context.l10n.hdlBerekenTitel,
              tekst: context.l10n.hdlBerekenTekst,
              afbeeldingLabel: context.l10n.hdlBerekenAfb,
              afbeeldingAsset: 'assets/handleiding/qs_bereken.png',
              icoon: Icons.play_circle_outline,
            ),
            const SizedBox(height: 8),
            _StapSectie(
              stap: 5,
              titel: context.l10n.hdlResultatenTitel,
              tekst: context.l10n.hdlResultatenTekst,
              afbeeldingLabel: context.l10n.hdlResultatenAfb,
              afbeeldingAsset: 'assets/handleiding/qs_resultaten.png',
              icoon: Icons.assessment_outlined,
            ),
            const SizedBox(height: 16),
            _ExtraSectie(
              titel: context.l10n.hdlBronTitel,
              tekst: context.l10n.hdlBronTekst,
              afbeeldingLabel: context.l10n.hdlBronAfb,
              afbeeldingAsset: 'assets/handleiding/qs_bronimpedantie.png',
              icoon: Icons.transform,
            ),
            const SizedBox(height: 8),
            _ExtraSectie(
              titel: context.l10n.hdlKabelnetTitel,
              tekst: context.l10n.hdlKabelnetTekst,
              afbeeldingLabel: context.l10n.hdlKabelnetAfb,
              afbeeldingAsset: 'assets/handleiding/qs_kabelnet.png',
              icoon: Icons.account_tree_outlined,
            ),
            const SizedBox(height: 8),
            _ExtraSectie(
              titel: context.l10n.hdlProjectenTitel,
              tekst: context.l10n.hdlProjectenTekst,
              afbeeldingLabel: context.l10n.hdlProjectenAfb,
              afbeeldingAsset: 'assets/handleiding/qs_projecten.png',
              icoon: Icons.folder_outlined,
            ),
            const SizedBox(height: 8),
            _TipsSectie(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Intro ──────────────────────────────────────────────────────────────────────

class _IntroSectie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.hdlIntroTitel,
      icoon: Icons.info_outline,
      children: [
        Text(l10n.hdlIntroTekst),
        const SizedBox(height: 12),
        _AfbeeldingPlaceholder(
          label: l10n.hdlIntroAfb,
          asset: 'assets/handleiding/qs_home.png',
        ),
      ],
    );
  }
}

// ── Stap-sectie ────────────────────────────────────────────────────────────────

class _StapSectie extends StatelessWidget {
  const _StapSectie({
    required this.stap,
    required this.titel,
    required this.tekst,
    required this.afbeeldingLabel,
    required this.afbeeldingAsset,
    required this.icoon,
  });

  final int stap;
  final String titel;
  final String tekst;
  final String afbeeldingLabel;
  final String afbeeldingAsset;
  final IconData icoon;

  @override
  Widget build(BuildContext context) {
    return SectieCard(
      titel: titel,
      icoon: icoon,
      children: [
        Text(tekst),
        const SizedBox(height: 12),
        _AfbeeldingPlaceholder(label: afbeeldingLabel, asset: afbeeldingAsset),
      ],
    );
  }
}

// ── Extra-sectie (bronimpedantie, kabelnet, projecten) ─────────────────────────

class _ExtraSectie extends StatelessWidget {
  const _ExtraSectie({
    required this.titel,
    required this.tekst,
    required this.afbeeldingLabel,
    required this.afbeeldingAsset,
    required this.icoon,
  });

  final String titel;
  final String tekst;
  final String afbeeldingLabel;
  final String afbeeldingAsset;
  final IconData icoon;

  @override
  Widget build(BuildContext context) {
    return SectieCard(
      titel: titel,
      icoon: icoon,
      children: [
        Text(tekst),
        const SizedBox(height: 12),
        _AfbeeldingPlaceholder(label: afbeeldingLabel, asset: afbeeldingAsset),
      ],
    );
  }
}

// ── Tips ───────────────────────────────────────────────────────────────────────

class _TipsSectie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SectieCard(
      titel: l10n.hdlTipsTitel,
      icoon: Icons.lightbulb_outline,
      children: [
        _TipRij(tekst: l10n.hdlTip1),
        const SizedBox(height: 6),
        _TipRij(tekst: l10n.hdlTip2),
        const SizedBox(height: 6),
        _TipRij(tekst: l10n.hdlTip3),
        const SizedBox(height: 6),
        _TipRij(tekst: l10n.hdlTip4),
        const SizedBox(height: 6),
        _TipRij(tekst: l10n.hdlTip5),
      ],
    );
  }
}

class _TipRij extends StatelessWidget {
  const _TipRij({required this.tekst});
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(tekst),
    );
  }
}

// ── Afbeeldingsplaceholder ─────────────────────────────────────────────────────

/// Toont een screenshot als het asset aanwezig is; anders een gestileerde
/// grijze placeholder met de bijschrifttekst.
class _AfbeeldingPlaceholder extends StatelessWidget {
  const _AfbeeldingPlaceholder({
    required this.label,
    required this.asset,
  });

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => Container(
          height: 180,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
