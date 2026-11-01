import 'package:flutter/material.dart';

import '../core/topic_catalog.dart';
import '../models/hadith_topic.dart';
import '../widgets/topic_card.dart';
import 'topic_detail_view.dart';

/// Halaman daftar seluruh topik/kategori hadis.
class TopicsView extends StatelessWidget {
  const TopicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Topik Hadis')),
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
                  border: Border.all(color: const Color(0xFFE2ECE5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.category_rounded,
                      color: Color(0xFF0B5D3B),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jelajahi hadis berdasarkan topik',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hadis rujukan tiap topik otomatis disimpan ke perangkat '
                            'agar tetap bisa dibaca dalam mode offline.',
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
              for (final topic in hadithTopics)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TopicListTile(topic: topic),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicListTile extends StatelessWidget {
  const _TopicListTile({required this.topic});

  final HadithTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TopicDetailView(topic: topic),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconForTopic(topic.id),
                  size: 21,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(topic.title, style: theme.textTheme.titleSmall),
                        const SizedBox(width: 8),
                        Text(
                          topic.arabicTitle,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFC9A227),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      topic.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
