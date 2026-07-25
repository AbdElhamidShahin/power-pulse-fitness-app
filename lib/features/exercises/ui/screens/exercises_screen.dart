import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/pp_input.dart';
import '../../logic/cubit/exercises_cubit.dart';
import '../../logic/cubit/exercises_state.dart';
import '../widgets/body_part_filter_tabs.dart';
import '../widgets/exercise_card.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});
  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSearching = false;

  // ✅ Issue 1 fix: حُذفت _selectedFilter و _filters الـ hardcoded
  // الـ filter state الآن موجودة في ExercisesCubit فقط

  @override
  void initState() {
    super.initState();
    context.read<ExercisesCubit>().loadInitial();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ExercisesCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search icon
                      GestureDetector(
                        onTap: () {
                          setState(() => _isSearching = !_isSearching);
                          if (!_isSearching) {
                            _searchController.clear();
                            context.read<ExerciseSearchCubit>().clear();
                          }
                        },
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: _isSearching
                                ? AppColors.bgDark : AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isSearching
                                ? Icons.close_rounded : Icons.search_rounded,
                            color: _isSearching
                                ? AppColors.textOnDark : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('مكتبة التمارين',
                              style: TextStyle(fontSize: 11,
                                  color: Color(0xFF8A8A8A), fontFamily: 'Cairo')),
                          Text('التمارين 🏋️',
                              style: TextStyle(fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Cairo')),
                        ],
                      ),
                    ],
                  ),

                  if (_isSearching) ...[
                    const SizedBox(height: 12),
                    PPSearchBar(
                      hint: 'ابحث عن تمرين...',
                      controller: _searchController,
                      onChanged: (q) =>
                          context.read<ExerciseSearchCubit>().search(q),
                      autofocus: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Stats Card (only when not searching) ──────────
            if (!_isSearching) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(value: '3', label: 'هذا الأسبوع'),
                      _StatItem(value: '12', label: 'إجمالي'),
                      _StatItem(value: '380', label: 'متوسط السعرات'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Issue 1+2 fix:
              // حُذف الـ hardcoded filter row الـ fake
              // الـ BodyPartFilterTabs الحقيقي بيظهر هنا فقط لما يكون
              // ExercisesLoaded — يُمرَّر للـ _ExercisesList عن طريق الـ Cubit state
            ],

            // ─── List ──────────────────────────────────────────
            Expanded(
              child: _isSearching
                  ? _SearchResults()
                  : _ExercisesList(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(
            fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.w900,
            color: AppColors.accent)),
        Text(label, style: const TextStyle(
            fontFamily: 'Cairo', fontSize: 10, color: Color(0xFF888888))),
      ],
    );
  }
}

class _ExercisesList extends StatelessWidget {
  const _ExercisesList({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) => switch (state) {
        ExercisesInitial() || ExercisesLoading() => const _Shimmer(),
        ExercisesError(:final message)           => _ErrorView(message: message),
        ExercisesLoaded()                        => _LoadedList(
            state: state, scrollController: scrollController),
      },
    );
  }
}

class _LoadedList extends StatelessWidget {
  const _LoadedList({required this.state, required this.scrollController});
  final ExercisesLoaded state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ✅ Issue 1+2 fix:
        // استبدل الـ inline ListView بـ BodyPartFilterTabs
        // الـ widget ده عنده ترجمة عربية (_label) وـ animation جاهزين
        if (state.bodyParts.isNotEmpty)
          BodyPartFilterTabs(
            bodyParts: state.bodyParts,
            selected:  state.selectedBodyPart,
            onSelect:  (p) =>
                context.read<ExercisesCubit>().filterByBodyPart(p),
          ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 8),
          child: Text('${state.exercises.length} تمرين',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8A8A), fontFamily: 'Cairo')),
        ),

        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.exercises.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == state.exercises.length) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(
                      color: AppColors.accent)),
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

class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseSearchCubit, ExerciseSearchState>(
      builder: (context, state) => switch (state) {
        ExerciseSearchIdle()    => const Center(
            child: Text('ابحث عن تمرين...',
                style: TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'Cairo'))),
        ExerciseSearchLoading() => const _Shimmer(),
        ExerciseSearchError()   => const SizedBox(),
        ExerciseSearchLoaded(:final results) when results.isEmpty =>
        const Center(
            child: Text('لا توجد نتائج',
                style: TextStyle(color: Color(0xFF8A8A8A), fontFamily: 'Cairo'))),
        ExerciseSearchLoaded(:final results) => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => ExerciseCard(
            exercise: results[i],
            onTap: () => context.push('/exercises/${results[i].id}'),
          ),
        ),
      },
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
      const SizedBox(height: 16),
      Text(message, style: AppTextStyles.bodyMedium),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => context.read<ExercisesCubit>().loadInitial(),
        child: Text('حاول مجدداً', style: AppTextStyles.accentLabel),
      ),
    ]),
  );
}
