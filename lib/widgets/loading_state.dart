import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Indikator loading bernuansa tema Islami (hijau tua & aksen emas)
/// dengan teks status informatif.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Memuat data...',
    this.submessage,
    this.useAccent = false,
  });

  final String message;
  final String? submessage;

  /// Gunakan aksen emas untuk loading khusus atau kontras gelap.
  final bool useAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryIndicatorColor = useAccent ? AppTheme.gold : AppTheme.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(primaryIndicatorColor),
                backgroundColor: primaryIndicatorColor.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (submessage != null) ...[
              const SizedBox(height: 4),
              Text(
                submessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
