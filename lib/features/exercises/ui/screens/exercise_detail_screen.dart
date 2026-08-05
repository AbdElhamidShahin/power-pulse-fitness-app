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
import '../widgets/add_to_plan_sheet.dart';

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
          ExerciseDetailLoading() =>
            const _DetailLoading(),
          ExerciseDetailError(:final message) => _DetailError(message: message),
          ExerciseDetailLoaded(:final exercise) =>
            _DetailContent(exercise: exercise),
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.exercise});
  final Exercise exercise;

  void _showAddToPlanSheet(BuildContext context, Exercise ex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddToPlanSheet(exercise: ex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        exercise.nameAr.isNotEmpty ? exercise.nameAr : exercise.name;
    final displayBodyPart = exercise.bodyPartAr.isNotEmpty
        ? exercise.bodyPartAr
        : exercise.bodyPart;
    final displayTarget =
        exercise.targetAr.isNotEmpty ? exercise.targetAr : exercise.target;
    final displayEquipment = exercise.equipmentAr.isNotEmpty
        ? exercise.equipmentAr
        : exercise.equipment;
    final steps = exercise.instructionsAr.isNotEmpty
        ? exercise.instructionsAr
        : exercise.instructions;
    final muscles = exercise.secondaryMusclesAr.isNotEmpty
        ? exercise.secondaryMusclesAr
        : exercise.secondaryMuscles;

    return CustomScrollView(
      slivers: [
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
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textPrimary,
                size: AppConstants.iconS,
              ),
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
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.screenPaddingH),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineLarge,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Badges
              Wrap(
                spacing: AppConstants.spaceS,
                runSpacing: AppConstants.spaceS,
                children: [
                  MuscleGroupBadge(muscle: displayBodyPart),
                  PPBadge(label: displayTarget, color: AppColors.info),
                  PPBadge(label: displayEquipment, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXXL),

              if (muscles.isNotEmpty) ...[
                Text('العضلات الثانوية',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceM),
                Wrap(
                  spacing: AppConstants.spaceS,
                  runSpacing: AppConstants.spaceS,
                  children: muscles
                      .map((m) => PPBadge(
                            label: m,
                            color: AppColors.textMuted,
                            size: PPBadgeSize.small,
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
              ],

              if (steps.isNotEmpty) ...[
                Text('كيفية الأداء',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceL),
                ...steps.asMap().entries.map(
                      (e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppConstants.spaceM),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
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
                                border:
                                    Border.all(color: AppColors.borderAccent),
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
                              child: Text(
                                e.value,
                                style: AppTextStyles.bodyMedium,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],

              const SizedBox(height: AppConstants.space3XL),

              PPButton(
                label: 'أضف للخطة',
                onPressed: () => _showAddToPlanSheet(context, exercise),
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

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}

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
