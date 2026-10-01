import 'package:flutter/material.dart';
import 'package:power_pulse/core/domain/api_result.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../exercises/data/models/exercise_entity.dart';
import '../../../exercises/logic/usecases/exercise_usecases.dart';
import '../../data/models/workout_session_entity.dart';

/// Sheet لاختيار تمرين من المكتبة وإضافته للجلسة.
///
/// Step 5 (P1 fix): browseExercises / searchLibrary انتقلوا من
/// WorkoutLoggerCubit لهنا — الـ Cubit مبقاش يعرف عن exercises feature.
class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({
    super.key,
    required this.onAdd,
    required this.getExercises,
    required this.searchExercises,
  });

  final void Function(SessionExercise) onAdd;
  final GetExercisesUseCase getExercises;
  final SearchExercisesUseCase searchExercises;

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

    final list = await (query.isEmpty
        ? _browseExercises()
        : _searchLibrary(query));

    if (mounted) setState(() { _results = list; _loading = false; });
  }

  Future<List<Exercise>> _browseExercises() async {
    final result = await widget.getExercises(limit: 300, offset: 0);
    return result.fold(onFailure: (_) => [], onSuccess: (l) => l);
  }

  Future<List<Exercise>> _searchLibrary(String query) async {
    final result = await widget.searchExercises(query.trim());
    return result.fold(onFailure: (_) => [], onSuccess: (l) => l);
  }

  void _pick(Exercise ex) {
    final exercise = SessionExercise(
      exerciseId: '${ex.id}_${DateTime.now().millisecondsSinceEpoch}',
      exerciseName: ex.nameAr.isNotEmpty ? ex.nameAr : ex.name,
      bodyPart: ex.bodyPartAr.isNotEmpty ? ex.bodyPartAr : ex.bodyPart,
      sets: [const ExerciseSet(setNumber: 1)],
    );
    widget.onAdd(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scroll) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppConstants.spaceM),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.colors.borderMedium,
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH,
              AppConstants.spaceM,
              AppConstants.screenPaddingH,
              AppConstants.spaceS,
            ),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(fontFamily: 'Cairo', color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'ابحث عن تمرين...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.colors.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: context.colors.textMuted),
                filled: true,
                fillColor: context.colors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (q) => _load(q),
            ),
          ),
          // Results
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : _results.isEmpty
                    ? Center(
                        child: Text('لا يوجد نتائج',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: context.colors.textMuted)),
                      )
                    : ListView.builder(
                        controller: scroll,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.screenPaddingH,
                          vertical: AppConstants.spaceS,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final ex = _results[i];
                          return ListTile(
                            title: Text(
                              ex.nameAr.isNotEmpty ? ex.nameAr : ex.name,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              ex.bodyPartAr.isNotEmpty ? ex.bodyPartAr : ex.bodyPart,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: context.colors.textMuted),
                            ),
                            trailing: Icon(Icons.add_circle_outline_rounded,
                                color: AppColors.accent),
                            onTap: () => _pick(ex),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
