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
  final void Function({
    required String exerciseId,
    required int setIndex,
    int? reps,
    double? weight,
    bool? isCompleted,
  }) onUpdate;
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
    _repsCtrl =
        TextEditingController(text: widget.exerciseSet.reps?.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: widget.exerciseSet.weight == null
            ? ''
            : widget.exerciseSet.weight! % 1 == 0
                ? widget.exerciseSet.weight!.toInt().toString()
                : widget.exerciseSet.weight!.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    widget.onUpdate(
      exerciseId: widget.exerciseId,
      setIndex: widget.exerciseSet.setNumber - 1,
      reps: int.tryParse(_repsCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.exerciseSet.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: done ? AppColors.accentDim : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color:
              done ? AppColors.accent.withOpacity(0.4) : AppColors.borderSubtle,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // رقم السيت
          SizedBox(
            width: 22,
            child: Text(
              '${widget.exerciseSet.setNumber}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: done ? AppColors.accent : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          // وزن
          Expanded(
            child: _NumField(
              controller: _weightCtrl,
              hint: '0',
              label: 'كجم',
              enabled: !done,
              onChanged: (_) => _onChange(),
            ),
          ),
          const SizedBox(width: 8),

          // رابس
          Expanded(
            child: _NumField(
              controller: _repsCtrl,
              hint: '0',
              label: 'رابس',
              enabled: !done,
              onChanged: (_) => _onChange(),
            ),
          ),
          const SizedBox(width: 8),

          // زرار ✓ — كبير وواضح
          GestureDetector(
            onTap: () => widget.onUpdate(
              exerciseId: widget.exerciseId,
              setIndex: widget.exerciseSet.setNumber - 1,
              isCompleted: !done,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: done ? AppColors.accent : AppColors.bgHighest,
                shape: BoxShape.circle,
                boxShadow: done
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                Icons.check_rounded,
                color: done ? AppColors.textOnAccent : AppColors.textMuted,
                size: 20,
              ),
            ),
          ),

          // حذف (بس لو مش مكتمل)
          if (!done) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: widget.onRemove,
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textMuted, size: 16),
            ),
          ] else
            const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String label;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        suffixText: label,
        suffixStyle:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgDeep,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
