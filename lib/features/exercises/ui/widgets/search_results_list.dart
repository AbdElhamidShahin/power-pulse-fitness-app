import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/exercises_cubit.dart';
import '../../logic/cubit/exercises_state.dart';
import 'exercise_card.dart';
import 'exercises_shimmer.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseSearchCubit, ExerciseSearchState>(
      builder: (context, state) => switch (state) {
        ExerciseSearchIdle() => Center(
          child: Text(
            'ابحث عن تمرين...',
            style: TextStyle(
              color: const Color(0xFF8A8A8A),
              fontFamily: 'Cairo',
              fontSize: 14.sp,
            ),
          ),
        ),
        ExerciseSearchLoading() => const ExercisesShimmer(),
        ExerciseSearchError() => const SizedBox.shrink(),
        ExerciseSearchLoaded(:final results) when results.isEmpty => Center(
          child: Text(
            'لا توجد نتائج',
            style: TextStyle(
              color: const Color(0xFF8A8A8A),
              fontFamily: 'Cairo',
              fontSize: 14.sp,
            ),
          ),
        ),
        ExerciseSearchLoaded(:final results) => ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: results.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, i) => ExerciseCard(
            exercise: results[i],
            onTap: () => context.push('/exercises/${results[i].id}'),
          ),
        ),
      },
    );
  }
}