import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_articles.dart';
import '../../models/article.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/common.dart';
import '../articles/article_detail_screen.dart';
import '../articles/articles_screen.dart';

/// All articles bookmarked from the "Saved articles" profile row.
class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final articles = saved.articleIds
        .map(MockArticles.byId)
        .whereType<Article>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved articles')),
      body: articles.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved articles',
              message:
                  'Tap the bookmark on any article to save it here to read '
                  'later.',
              actionLabel: 'Browse articles',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArticlesScreen()),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.lg,
                AppSpacing.pageH,
                AppSpacing.xxl,
              ),
              itemCount: articles.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, i) {
                final a = articles[i];
                return AppCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: a),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: a.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 22,
                          color: a.accentColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${a.readMinutes} min read · ${a.doctor.name}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove from saved',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () => saved.toggleArticle(a.id),
                        icon: const Icon(
                          Icons.bookmark_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
