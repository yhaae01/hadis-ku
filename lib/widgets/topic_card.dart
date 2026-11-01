import 'package:flutter/material.dart';

import '../models/hadith_topic.dart';

/// Memetakan id topik ke ikon Material yang sesuai.
IconData iconForTopic(String topicId) {
  switch (topicId) {
    case 'niat':
      return Icons.track_changes_rounded;
    case 'iman':
      return Icons.shield_rounded;
    case 'shalat':
      return Icons.mosque_rounded;
    case 'akhlak':
      return Icons.favorite_rounded;
    case 'makanan-minuman':
      return Icons.restaurant_rounded;
    case 'sabar':
      return Icons.self_improvement_rounded;
    case 'ilmu':
      return Icons.school_rounded;
    case 'sedekah':
      return Icons.volunteer_activism_rounded;
    default:
      return Icons.auto_stories_rounded;
  }
}

/// Kartu topik kompak untuk deret horizontal di beranda.
class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    this.height = 122,
  });

  final HadithTopic topic;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 150,
      height: height,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconForTopic(topic.id),
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  topic.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
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
