import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/hadith.dart';

/// Ringkasan satu hadis pada daftar hadis maupun hasil pencarian.
class HadithTile extends StatelessWidget {
  const HadithTile({super.key, required this.hadith, required this.onTap});

  final Hadith hadith;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No. ${formatNumber(hadith.number)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.deepGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hadith.bookName.isNotEmpty)
                    Text(
                      hadith.bookName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hadith.arabic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.9,
                  fontWeight: FontWeight.w500,
                  fontFamilyFallback: [
                    'Noto Naskh Arabic',
                    'Scheherazade New',
                    'Amiri',
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hadith.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
