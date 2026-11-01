import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/hadith_book.dart';
import '../providers/hadith_detail_provider.dart';
import '../widgets/loading_state.dart';
import '../widgets/status_message.dart';

/// Menampilkan teks Arab, terjemahan Indonesia, dan nomor satu hadis.
class HadithDetailView extends StatelessWidget {
  const HadithDetailView({
    super.key,
    required this.book,
    required this.number,
  });

  final HadithBook book;
  final int number;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HadithDetailProvider>(
      create: (_) =>
          HadithDetailProvider(book: book, number: number)..load(),
      child: _HadithDetailBody(book: book, number: number),
    );
  }
}

class _HadithDetailBody extends StatelessWidget {
  const _HadithDetailBody({required this.book, required this.number});

  final HadithBook book;
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HadithDetailProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              'Hadis nomor ${formatNumber(number)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, HadithDetailProvider provider) {
    if (provider.isLoading && provider.hadith == null) {
      return const LoadingState(message: 'Memuat detail hadis...');
    }

    if (provider.hadith == null) {
      return StatusMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat hadis',
        message: provider.error ?? 'Detail hadis tidak tersedia.',
        action: FilledButton.tonalIcon(
          onPressed: () => context.read<HadithDetailProvider>().load(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba lagi'),
        ),
      );
    }

    final hadith = provider.hadith!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.deepGreen, AppTheme.green],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x1FFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: Text(
                          formatNumber(hadith.number),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hadith.bookName.isEmpty
                                  ? book.name
                                  : hadith.bookName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hadis nomor ${formatNumber(hadith.number)}',
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ContentCard(
                  icon: Icons.auto_stories_rounded,
                  title: 'Teks Arab',
                  child: SelectableText(
                    hadith.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 2.1,
                      fontWeight: FontWeight.w500,
                      fontFamilyFallback: [
                        'Noto Naskh Arabic',
                        'Scheherazade New',
                        'Amiri',
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ContentCard(
                  icon: Icons.translate_rounded,
                  title: 'Terjemahan',
                  child: SelectableText(
                    hadith.translation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15.5,
                          height: 1.8,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sumber: Hadis API Indonesia • ${book.name}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
