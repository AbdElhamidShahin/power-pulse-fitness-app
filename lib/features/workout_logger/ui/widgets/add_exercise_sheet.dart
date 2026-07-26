import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../data/models/workout_session_entity.dart';

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({
    super.key,
    required this.onExercisePicked,
    required this.onSearch,
    required this.onBrowse,
  });

  final void Function(SessionExercise) onExercisePicked;
  final Future<List<Exercise>> Function(String query) onSearch;
  final Future<List<Exercise>> Function() onBrowse;

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  final _searchCtrl = TextEditingController();
  List<Exercise> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load(String query) async {
    setState(() => _loading = true);
    final list =
        query.isEmpty ? await widget.onBrowse() : await widget.onSearch(query);
    if (mounted) {
      setState(() {
        _results = list;
        _loading = false;
      });
    }
  }

  void _pick(Exercise ex) {
    final exercise = SessionExercise(
      exerciseId: '${ex.id}_${DateTime.now().millisecondsSinceEpoch}',
      exerciseName: ex.nameAr.isNotEmpty ? ex.nameAr : ex.name,
      bodyPart: ex.bodyPartAr.isNotEmpty ? ex.bodyPartAr : ex.bodyPart,
      sets: [const ExerciseSet(setNumber: 1)],
    );
    widget.onExercisePicked(exercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spaceM),
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
              AppConstants.spaceM,
            ),
            child: Row(
              children: [
                Text(
                  'اختر تمريناً',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _load,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث عن تمرين...',
                hintStyle: AppTextStyles.bodyMedium,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
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
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد نتائج',
                          style: AppTextStyles.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.screenPaddingH,
                          0,
                          AppConstants.screenPaddingH,
                          AppConstants.spaceXXL,
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
                            onTap: () => _pick(ex),
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: AppConstants.spaceS,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spaceL,
                                vertical: AppConstants.spaceM,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgElevated,
                                borderRadius:
                                    BorderRadius.circular(AppConstants.radiusL),
                                border:
                                    Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTextStyles.labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: AppConstants.spaceXS,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants.spaceS,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentDim,
                                            borderRadius: BorderRadius.circular(
                                              AppConstants.radiusPill,
                                            ),
                                          ),
                                          child: Text(
                                            part,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: AppColors.accent,
                                    size: 22,
                                  ),
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
