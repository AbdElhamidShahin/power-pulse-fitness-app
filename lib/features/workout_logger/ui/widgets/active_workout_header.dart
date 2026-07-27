import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/workout_session_entity.dart';

class ActiveWorkoutHeader extends StatefulWidget {
  const ActiveWorkoutHeader({
    super.key,
    required this.session,
    required this.onCancel,
  });
  final WorkoutSession session;
  final VoidCallback onCancel;

  @override
  State<ActiveWorkoutHeader> createState() => _ActiveWorkoutHeaderState();
}

class _ActiveWorkoutHeaderState extends State<ActiveWorkoutHeader> {
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(
      const Duration(seconds: 1),
          (_) => DateTime.now().difference(widget.session.startTime).inSeconds,
    );
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.session.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                StreamBuilder<int>(
                  stream: _ticker,
                  initialData: 0,
                  builder: (_, snap) => Text(
                    '⏱ ${_fmt(snap.data ?? 0)}',
                    style: AppTextStyles.accentLabel,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.bgSurface,
                title: Text('إلغاء التمرين؟',
                    style: Theme.of(context).textTheme.headlineSmall),
                content: Text('سيتم حذف التمرين الحالي',
                    style: AppTextStyles.bodyMedium),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('لا', style: AppTextStyles.accentLabel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onCancel();
                    },
                    child: Text('نعم',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.danger)),
                  ),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceS),
              decoration: BoxDecoration(
                color: AppColors.dangerDim,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Text('إلغاء',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ─────────────────────────────────────────────────
class WorkoutBottomBar extends StatelessWidget {
  const WorkoutBottomBar({
    super.key,
    required this.session,
    required this.onAddExercise,
    required this.onFinish,
  });
  final WorkoutSession session;
  final VoidCallback onAddExercise;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
        AppConstants.screenPaddingH,
        AppConstants.spaceXL,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onAddExercise,
              child: Container(
                height: AppConstants.buttonHeightMedium,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: AppColors.textMuted, size: 20),
                    const SizedBox(width: AppConstants.spaceS),
                    Text('إضافة تمرين',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(
            child: ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: Size(double.infinity, AppConstants.buttonHeightMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
              ),
              child: Text('إنهاء التمرين ✅',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textOnAccent)),
            ),
          ),
        ],
      ),
    );
  }
}
