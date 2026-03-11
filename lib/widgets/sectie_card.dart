import 'package:flutter/material.dart';

class SectieCard extends StatelessWidget {
  final String titel;
  final IconData icoon;
  final List<Widget> children;

  const SectieCard({
    super.key,
    required this.titel,
    required this.icoon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icoon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(titel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    )),
              ),
            ]),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
