import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_badge.dart';
import '../../../../../shared/widgets/pp_button.dart';
import '../../data/models/exercise_entity.dart';
import '../../logic/cubit/exercises_cubit.dart';
import '../../logic/cubit/exercises_state.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExerciseDetailCubit>().load(widget.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ExerciseDetailCubit, ExerciseDetailState>(
        builder: (context, state) => switch (state) {
          ExerciseDetailInitial() ||
          ExerciseDetailLoading() => const _DetailLoading(),
          ExerciseDetailError(:final message) => _DetailError(message: message),
          ExerciseDetailLoaded(:final exercise) => _DetailContent(exercise: exercise),
        },
      ),
    );
  }
}

// ─── Content ────────────────────────────────────────────────
class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ─── GIF Header ─────────────────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.bgDeep,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(AppConstants.spaceS),
              decoration: BoxDecoration(
                color: AppColors.bgSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: AppConstants.iconS),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: exercise.gifUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.bgElevated,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.bgElevated,
                child: const Icon(Icons.fitness_center,
                    color: AppColors.textMuted, size: 64),
              ),
            ),
          ),
        ),

        // ─── Info ────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(exercise.name,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppConstants.spaceM),

              // Badges
              Wrap(
                spacing: AppConstants.spaceS,
                runSpacing: AppConstants.spaceS,
                children: [
                  MuscleGroupBadge(muscle: exercise.bodyPart),
                  PPBadge(label: exercise.target, color: AppColors.info),
                  PPBadge(label: exercise.equipment, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXXL),

              // Secondary muscles
              if (exercise.secondaryMuscles.isNotEmpty) ...[
                Text('العضلات الثانوية',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceM),
                Wrap(
                  spacing: AppConstants.spaceS,
                  runSpacing: AppConstants.spaceS,
                  children: exercise.secondaryMuscles
                      .map((m) => PPBadge(
                    label: m,
                    color: AppColors.textMuted,
                    size: PPBadgeSize.small,
                  ))
                      .toList(),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
              ],

              // Instructions
              if (exercise.instructions.isNotEmpty) ...[
                Text('كيفية الأداء',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceL),
                ...exercise.instructions.asMap().entries.map(
                      (e) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppConstants.spaceM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(
                              left: AppConstants.spaceM),
                          decoration: BoxDecoration(
                            color: AppColors.accentDim,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusPill),
                            border: Border.all(
                                color: AppColors.borderAccent),
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(e.value,
                              style: AppTextStyles.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.space3XL),
              PPButton(
                label: 'أضف للخطة',
                onPressed: () {
                  // Phase 3 - Workout Plan feature
                },
                icon: Icons.add_rounded,
              ),
              const SizedBox(height: AppConstants.spaceXL),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Loading ─────────────────────────────────────────────────
class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────
class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 48),
          const SizedBox(height: AppConstants.spaceM),
          Text(message, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
