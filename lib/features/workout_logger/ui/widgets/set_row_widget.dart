import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/workout_session_entity.dart';

class SetRowWidget extends StatefulWidget {
  const SetRowWidget({
    super.key,
    required this.exerciseSet,
    required this.exerciseId,
    required this.onUpdate,
    required this.onRemove,
  });

  final ExerciseSet exerciseSet;
  final String exerciseId;
  final void Function({required String exerciseId, required int setIndex,
      int? reps, double? weight, bool? isCompleted}) onUpdate;
  final VoidCallback onRemove;

  @override
  State<SetRowWidget> createState() => _SetRowWidgetState();
}

class _SetRowWidgetState extends State<SetRowWidget> {
  late final TextEditingController _repsCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _repsCtrl   = TextEditingController(
        text: widget.exerciseSet.reps?.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: widget.exerciseSet.weight?.toStringAsFixed(
            widget.exerciseSet.weight! % 1 == 0 ? 0 : 1) ?? '');
  }

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final reps   = int.tryParse(_repsCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    widget.onUpdate(
      exerciseId: widget.exerciseId,
      setIndex: widget.exerciseSet.setNumber - 1,
      reps: reps,
      weight: weight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.exerciseSet.isCompleted;
    return AnimatedContainer(
      duration: AppConstants.durationNormal,
      margin: const EdgeInsets.only(bottom: AppConstants.spaceS),
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceM, vertical: AppConstants.spaceS),
      decoration: BoxDecoration(
        color: done ? AppColors.accentDim : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: done ? AppColors.borderAccent : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 28,
            child: Text(
              widget.exerciseSet.setNumber.toString(),
              style: AppTextStyles.labelMedium
                  .copyWith(color: done ? AppColors.accent : AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),

          // Weight
          Expanded(
            child: _NumberField(
              controller: _weightCtrl,
              hint: '0',
              suffix: 'كغ',
              enabled: !done,
              onChanged: (_) => _onChanged(),
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),

          // Reps
          Expanded(
            child: _NumberField(
              controller: _repsCtrl,
              hint: '0',
              suffix: 'تكرار',
              enabled: !done,
              onChanged: (_) => _onChanged(),
            ),
          ),
          const SizedBox(width: AppConstants.spaceM),

          // Done button
          GestureDetector(
            onTap: () => widget.onUpdate(
              exerciseId: widget.exerciseId,
              setIndex: widget.exerciseSet.setNumber - 1,
              isCompleted: !done,
            ),
            child: AnimatedContainer(
              duration: AppConstants.durationNormal,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done ? AppColors.accent : AppColors.bgHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.check_rounded,
                color: done ? AppColors.textOnAccent : AppColors.textMuted,
                size: AppConstants.iconS,
              ),
            ),
          ),

          // Delete
          if (!done) ...[
            const SizedBox(width: AppConstants.spaceS),
            GestureDetector(
              onTap: widget.onRemove,
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textMuted, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.hint,
    required this.suffix,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String suffix;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: AppTextStyles.titleMedium,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall,
        suffixText: suffix,
        suffixStyle: AppTextStyles.bodySmall,
        filled: true,
        fillColor: AppColors.bgDeep,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceS, vertical: AppConstants.spaceS),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
