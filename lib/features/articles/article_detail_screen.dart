import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/article.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final isSaved = saved.isArticleSaved(article.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.surface,
            actions: [
              IconButton(
                onPressed: () => saved.toggleArticle(article.id),
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Article link copied')),
                    );
                },
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: article.accentColor.withValues(alpha: 0.1),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 64,
                        color:
                            article.accentColor.withValues(alpha: 0.35)),
                    const Positioned(
                      top: 70,
                      child: VerifiedBadge(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppBadge(
                        label: article.category,
                        color: article.accentColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const AppBadge(
                        label: 'Education',
                        icon: Icons.school_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DoctorCard(article: article),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text('${article.readMinutes} min read',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textTertiary)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.visibility_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text('${Fmt.compact(article.views)} views',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textTertiary)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.favorite_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(Fmt.compact(article.likes),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textTertiary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            sliver: SliverList.builder(
              itemCount: article.body.length,
              itemBuilder: (context, i) {
                final para = article.body[i];
                if (para.startsWith('## ')) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: AppSpacing.xl, bottom: AppSpacing.sm),
                    child: Text(
                      para.substring(3),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    para,
                    style: const TextStyle(fontSize: 14, height: 1.65),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.xl,
                  AppSpacing.pageH, AppSpacing.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Tags', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final t in article.tags)
                        AppBadge(
                            label: t,
                            color: AppColors.textSecondary,
                            dense: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const NoticeBanner(
                    color: AppColors.textTertiary,
                    icon: Icons.medical_information_rounded,
                    message:
                        'This article is for general education and does not '
                        'replace a consultation with a doctor. Last medically '
                        'reviewed on the date shown above.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final d = article.doctor;

    return AppCard(
      color: AppColors.verifiedSurface,
      borderColor: AppColors.verified.withValues(alpha: 0.25),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.verified,
            child: Text(
              d.name.split(' ').skip(1).first.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        d.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (d.verified) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.verified_rounded,
                          size: 15, color: AppColors.verified),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${d.speciality} · ${d.qualification}',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${d.experienceYears} years experience · Reviewed ${Fmt.dateShort(article.publishedOn)}',
                  style: const TextStyle(
                      fontSize: 10.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
