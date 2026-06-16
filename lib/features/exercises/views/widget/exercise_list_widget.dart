import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/components/pp_empty_state.dart';
import '../../data/model/exercise.dart';

import '../../../../shared/widgets/exercise_card.dart';
import '../../data/repo/exercise_repository.dart';
import '../../data/service/exercise_service.dart';
import '../../logic/exercise_cubit.dart';
import '../../logic/exercise_state.dart';

class ExerciseListWidget extends StatelessWidget {
  const ExerciseListWidget({
    super.key,
    required this.pageId,
    required this.itemCount,
    this.text1,
    this.onAddPressed,
  });

  final String pageId;
  final int itemCount;
  final String? text1;
  final void Function(Exercise)? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExerciseCubit(
        ExerciseRepositoryImpl(const ExerciseService()),
      )..load(pageId, limit: itemCount),
      child: _ExerciseListBody(
        title: text1 ?? '',
        onAddPressed: onAddPressed,
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ExerciseListBody extends StatelessWidget {
  const _ExerciseListBody({required this.title, this.onAddPressed});

  final String title;
  final void Function(Exercise)? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) => switch (state) {
        ExerciseLoading() => Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          ),
        ExerciseError(:final message) => Scaffold(
            backgroundColor: AppColors.background,
            body: PpEmptyState(
              emoji: '⚠️',
              title: 'حدث خطأ',
              subtitle: message,
            ),
          ),
        ExerciseLoaded(:final exercises) => _ExerciseList(
            title: title,
            exercises: exercises,
            onAddPressed: onAddPressed,
          ),
      },
    );
  }
}

// ── Loaded list ───────────────────────────────────────────────────────────────

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({
    required this.title,
    required this.exercises,
    this.onAddPressed,
  });

  final String title;
  final List<Exercise> exercises;
  final void Function(Exercise)? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: AppTextStyles.appBarTitleSmall),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(right: 20, bottom: 14),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppConstants.backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.surfaceHigh),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            AppColors.background,
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Exercise count badge ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.sm,
                AppSpacing.marginMobile,
                AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${exercises.length} تمارين',
                      style: AppTextStyles.labelCaps
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── List ───────────────────────────────────────────────────────
          exercises.isEmpty
              ? const SliverFillRemaining(
                  child: PpEmptyState(
                    emoji: '🏋️',
                    title: 'لا توجد تمارين',
                    subtitle: 'لم يتم العثور على تمارين لهذه المجموعة',
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => ExerciseCard(
                      exercise: exercises[i],
                      onAddPressed: onAddPressed,
                    ),
                    childCount: exercises.length,
                  ),
                ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomNavHeight + AppSpacing.md),
          ),
        ],
      ),
    );
  }
}
