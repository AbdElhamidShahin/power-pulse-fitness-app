import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../exercises/logic/cubit/exercises_cubit.dart';
import '../../data/models/workout_plan_entity.dart';
import '../../logic/cubit/workout_plan_cubit.dart';
import '../../logic/cubit/workout_plan_state.dart';

class ExercisePickerSheet extends StatefulWidget {
  const ExercisePickerSheet({
    required this.exercisesCubit,
    required this.onPick,
  });
  final ExercisesCubit exercisesCubit;
  final ValueChanged<Exercise> onPick;

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final _ctrl = TextEditingController();
  List<Exercise> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load(String q) async {
    setState(() => _loading = true);
    final list = q.isEmpty
        ? await widget.exercisesCubit.browseAll()
        : await widget.exercisesCubit.search(q);
    if (mounted)
      setState(() {
        _results = list;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scroll) => Column(
        children: [
          const SizedBox(height: AppConstants.spaceM),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                AppConstants.spaceL,
                AppConstants.screenPaddingH,
                AppConstants.spaceM),
            child: Row(
              children: [
                Text('اختر تمريناً', style: AppTextStyles.headlineMedium),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH),
            child: TextField(
              controller: _ctrl,
              onChanged: _load,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Expanded(
            child: _loading
                ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent))
                : _results.isEmpty
                ? Center(
                child: Text('لا توجد نتائج',
                    style: AppTextStyles.bodyMedium))
                : ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPaddingH,
                0,
                AppConstants.screenPaddingH,
                AppConstants.space5XL,
              ),
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final ex = _results[i];
                final name =
                ex.nameAr.isNotEmpty ? ex.nameAr : ex.name;
                final part = ex.bodyPartAr.isNotEmpty
                    ? ex.bodyPartAr
                    : ex.bodyPart;
                return GestureDetector(
                  onTap: () => widget.onPick(ex),
                  child: Container(
                    margin: const EdgeInsets.only(
                        bottom: AppConstants.spaceS),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceL,
                      vertical: AppConstants.spaceM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: AppTextStyles.labelMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spaceS,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentDim,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusPill),
                                ),
                                child: Text(part,
                                    style: AppTextStyles.labelSmall
                                        .copyWith(
                                        color: AppColors.accent)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.accent, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
