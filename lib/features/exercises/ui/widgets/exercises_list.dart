import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../logic/cubit/exercises_cubit.dart';
import '../../logic/cubit/exercises_state.dart';
import 'exercise_card.dart';
import 'exercises_shimmer.dart';

class ExercisesList extends StatelessWidget {
  const ExercisesList({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) => switch (state) {
        ExercisesInitial() || ExercisesLoading() => const ExercisesShimmer(),
        ExercisesError(:final message) => _ErrorView(message: message),
        ExercisesLoaded() => _LoadedList(
          state: state,
          scrollController: scrollController,
        ),
      },
    );
  }
}

class _LoadedList extends StatelessWidget {
  const _LoadedList({required this.state, required this.scrollController});
  final ExercisesLoaded state;
  final ScrollController scrollController;

  String _translateBodyPart(String englishName) {
    switch (englishName.toLowerCase()) {
      case 'all':
        return 'الكل';
      case 'back':
        return 'الظهر';
      case 'cardio':
        return 'كارديو';
      case 'chest':
        return 'الصدر';
      case 'lower arms':
        return 'الساعدين';
      case 'lower legs':
        return 'السمانة / الساق';
      case 'neck':
        return 'الرقبة';
      case 'shoulders':
        return 'الكتفين';
      case 'upper arms':
        return 'الباي والذراع';
      case 'upper legs':
        return 'الفخذين';
      case 'waist':
        return 'الوسط / البطن';
      default:
        return englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.bodyParts.isNotEmpty)
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: state.bodyParts.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final p = state.bodyParts[i];
                final active = state.selectedBodyPart == p;
                return GestureDetector(
                  onTap: () =>
                      context.read<ExercisesCubit>().filterByBodyPart(p),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.bgDark : AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _translateBodyPart(p),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color:
                        active ? AppColors.textOnDark : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.only(right: 16.w, bottom: 8.h),
          child: Text(
            '${state.exercises.length} تمرين',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8A8A8A),
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: state.exercises.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, i) {
              if (i == state.exercises.length) {
                return Padding(
                  padding: EdgeInsets.all(20.r),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                    ),
                  ),
                );
              }
              final ex = state.exercises[i];
              return ExerciseCard(
                exercise: ex,
                onTap: () => context.push('/exercises/${ex.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: AppColors.danger,
          size: 48.r,
        ),
        SizedBox(height: 16.h),
        Text(message, style: AppTextStyles.bodyMedium),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => context.read<ExercisesCubit>().loadInitial(),
          child: Text('حاول مجدداً', style: AppTextStyles.accentLabel),
        ),
      ],
    ),
  );
}