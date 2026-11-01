import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/hadith_book.dart';
import '../providers/hadith_list_provider.dart';
import '../services/hadith_repository.dart';
import '../widgets/hadith_tile.dart';
import '../widgets/loading_state.dart';
import '../widgets/status_message.dart';
import 'hadith_detail_view.dart';
import 'search_view.dart';

/// Daftar hadis dari satu kitab dengan lazy loading saat di-scroll.
class HadithListView extends StatelessWidget {
  const HadithListView({super.key, required this.book});

  final HadithBook book;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HadithListProvider>(
      create: (context) => HadithListProvider(
        book: book,
        repository: context.read<HadithRepository>(),
      )..loadInitial(),
      child: _HadithListBody(book: book),
    );
  }
}

class _HadithListBody extends StatefulWidget {
  const _HadithListBody({required this.book});

  final HadithBook book;

  @override
  State<_HadithListBody> createState() => _HadithListBodyState();
}

class _HadithListBodyState extends State<_HadithListBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 600) {
      context.read<HadithListProvider>().loadMore();
    }
  }

  void _openDetail(int number) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HadithDetailView(book: widget.book, number: number),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchView(initialSlug: widget.book.slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HadithListProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              '${formatNumber(provider.totalItems)} hadis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cari di kitab ini',
            onPressed: _openSearch,
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, HadithListProvider provider) {
    if (provider.isInitialLoading) {
      return const LoadingState(message: 'Memuat hadis...');
    }

    if (provider.error != null && provider.items.isEmpty) {
      return StatusMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat hadis',
        message: provider.error!,
        action: FilledButton.tonalIcon(
          onPressed: () => context.read<HadithListProvider>().loadInitial(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba lagi'),
        ),
      );
    }

    if (provider.items.isEmpty) {
      return const StatusMessage(
        icon: Icons.menu_book_outlined,
        title: 'Belum ada hadis',
        message: 'Kitab ini belum memiliki hadis yang dapat ditampilkan.',
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: RefreshIndicator(
          color: AppTheme.green,
          onRefresh: () => context.read<HadithListProvider>().refresh(),
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: provider.items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == provider.items.length) {
                return _ListFooter(provider: provider);
              }

              final hadith = provider.items[index];
              return HadithTile(
                hadith: hadith,
                onTap: () => _openDetail(hadith.number),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.provider});

  final HadithListProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (provider.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (provider.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              provider.loadMoreError!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.read<HadithListProvider>().loadMore(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Muat ulang'),
            ),
          ],
        ),
      );
    }

    if (!provider.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Semua ${formatNumber(provider.totalItems)} hadis telah dimuat',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}
