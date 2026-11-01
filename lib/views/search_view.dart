import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_config.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../providers/books_provider.dart';
import '../providers/hadith_search_provider.dart';
import '../widgets/hadith_tile.dart';
import '../widgets/status_message.dart';
import 'hadith_detail_view.dart';

/// Pencarian hadis berdasarkan nomor atau kata kunci.
class SearchView extends StatelessWidget {
  const SearchView({super.key, this.initialSlug});

  /// Kitab yang langsung dipilih saat halaman dibuka.
  final String? initialSlug;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HadithSearchProvider>(
      create: (_) => HadithSearchProvider(),
      child: _SearchForm(initialSlug: initialSlug),
    );
  }
}

class _SearchForm extends StatefulWidget {
  const _SearchForm({this.initialSlug});

  final String? initialSlug;

  @override
  State<_SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<_SearchForm> {
  final TextEditingController _keywordController = TextEditingController();
  late String _selectedSlug;

  @override
  void initState() {
    super.initState();
    _selectedSlug = widget.initialSlug ?? 'bukhari';
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<HadithSearchProvider>().search(
          keyword: _keywordController.text,
          slug: _selectedSlug,
        );
  }

  HadithBook _bookFor(List<HadithBook> books, Hadith hadith) {
    for (final book in books) {
      if (book.slug == hadith.bookSlug) return book;
    }
    return HadithBook(
      name: hadith.bookName.isEmpty ? 'Hadis' : hadith.bookName,
      slug: hadith.bookSlug,
      total: 0,
    );
  }

  void _openDetail(List<HadithBook> books, Hadith hadith) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HadithDetailView(
          book: _bookFor(books, hadith),
          number: hadith.number,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final books = context.watch<BooksProvider>().books;
    final search = context.watch<HadithSearchProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian Hadis')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4EE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.travel_explore_rounded,
                      color: AppTheme.green,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cari hadis dengan cepat',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Masukkan nomor hadis untuk membuka langsung, atau kata kunci untuk memindai kitab terpilih. Pencarian berhenti setelah '
                            '${ApiConfig.maxSearchResults} hasil ditemukan.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (books.isEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Daftar kitab belum tersedia.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: books.any(
                            (book) => book.slug == _selectedSlug,
                          )
                              ? _selectedSlug
                              : books.first.slug,
                          isExpanded: true,
                          menuMaxHeight: 360,
                          decoration: const InputDecoration(
                            labelText: 'Kitab',
                            prefixIcon: Icon(
                              Icons.menu_book_outlined,
                              size: 20,
                            ),
                          ),
                          items: [
                            for (final book in books)
                              DropdownMenuItem<String>(
                                value: book.slug,
                                child: Text(
                                  '${book.name} (${formatNumber(book.total)})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: search.isSearching
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() => _selectedSlug = value);
                                },
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _keywordController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Kata kunci atau nomor hadis',
                          hintText: 'Contoh: sabar, niat, atau 1',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: search.isSearching ? null : _submit,
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: const Text('Cari Hadis'),
                      ),
                    ],
                  ),
                ),
              ),
              if (search.isSearching) ...[
                const SizedBox(height: 16),
                _SearchProgress(search: search),
              ],
              if (search.error != null) ...[
                const SizedBox(height: 16),
                StatusMessage(
                  icon: Icons.search_off_rounded,
                  title: 'Pencarian gagal',
                  message: search.error!,
                  action: FilledButton.tonalIcon(
                    onPressed: search.isSearching ? null : _submit,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Coba lagi'),
                  ),
                ),
              ],
              if (search.info != null && !search.isSearching) ...[
                const SizedBox(height: 12),
                Text(
                  search.info!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (search.hasSearched) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text('Hasil Pencarian', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '${search.results.length} hadis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (search.results.isEmpty)
                  const StatusMessage(
                    icon: Icons.search_off_rounded,
                    title: 'Hadis tidak ditemukan',
                    message:
                        'Coba kata kunci lain, pilih kitab yang berbeda, '
                        'atau periksa nomor hadis yang dimasukkan.',
                  )
                else ...[
                  for (final hadith in search.results)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HadithTile(
                        hadith: hadith,
                        onTap: () => _openDetail(books, hadith),
                      ),
                    ),
                  if (search.results.length >= ApiConfig.maxSearchResults)
                    Text(
                      'Menampilkan maksimal ${ApiConfig.maxSearchResults} hasil. '
                      'Persempit kata kunci untuk menemukan hadis lain.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        height: 1.5,
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchProgress extends StatelessWidget {
  const _SearchProgress({required this.search});

  final HadithSearchProvider search;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = search.totalPages;
    final scanned = search.scannedPage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  total > 0
                      ? 'Memindai halaman $scanned dari $total...'
                      : 'Menghubungi server...',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: total > 0 ? (scanned / total).clamp(0.0, 1.0) : null,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: search.cancel,
              child: const Text('Hentikan'),
            ),
          ),
        ],
      ),
    );
  }
}
