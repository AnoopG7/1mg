import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_articles.dart';
import '../../models/article.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: Article.categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Health articles'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.border,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: [
              for (final c in Article.categories) Tab(text: c),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final c in Article.categories) _CategoryList(category: c),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final articles =
        MockArticles.all.where((a) => a.category == category).toList();
    final saved = context.watch<SavedProvider>();

    if (articles.isEmpty) {
      return const EmptyState(
        icon: Icons.article_outlined,
        title: 'No articles here yet',
        message: 'More doctor-verified content is coming soon.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxl),
      itemCount: articles.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, i) {
        final a = articles[i];
        final isSaved = saved.isArticleSaved(a.id);
        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: a)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 96,
                decoration: BoxDecoration(
                  color: a.accentColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg - 1),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.menu_book_rounded,
                          size: 34, color: a.accentColor.withValues(alpha: 0.6)),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: VerifiedBadge(),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () => saved.toggleArticle(a.id),
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: isSaved
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: a.accentColor.withValues(alpha: 0.15),
                          child: Text(
                            a.doctor.name
                                .split(' ')
                                .skip(1)
                                .first
                                .substring(0, 1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: a.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            a.doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${a.readMinutes} min read',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textTertiary),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          Fmt.compact(a.views),
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
