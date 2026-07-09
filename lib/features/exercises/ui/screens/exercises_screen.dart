import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/constants/app_strings.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<ExercisesCubit>().loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExercisesCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              searchController: _searchController,
              isSearching: _isSearching,
              onSearchToggle: () {
                setState(() => _isSearching = !_isSearching);
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<ExerciseSearchCubit>().clear();
                }
              },
              onSearchChanged: (q) =>
                  context.read<ExerciseSearchCubit>().search(q),
            ),

            // ─── Search Results ──────────────────────────────
            if (_isSearching)
              Expanded(child: _SearchResults())
            else
              Expanded(child: _ExercisesList(scrollController: _scrollController)),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.isSearching,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
        AppConstants.screenPaddingH,
        AppConstants.spaceL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.workoutsTitle,
                        style: Theme.of(context).textTheme.headlineLarge),
                    Text(AppStrings.workoutsSub,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onSearchToggle,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSearching
                        ? AppColors.accentDim
                        : AppColors.bgElevated,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: isSearching
                          ? AppColors.accent
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Icon(
                    isSearching ? Icons.close_rounded : Icons.search_rounded,
                    color: isSearching
                        ? AppColors.accent
                        : AppColors.textMuted,
                    size: AppConstants.iconM,
                  ),
                ),
              ),
            ],
          ),
          if (isSearching) ...[
            const SizedBox(height: AppConstants.spaceM),
            PPSearchBar(
              hint: AppStrings.searchWorkout,
              controller: searchController,
              onChanged: onSearchChanged,
              autofocus: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Main List ──────────────────────────────────────────────
class _ExercisesList extends StatelessWidget {
  const _ExercisesList({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      builder: (context, state) => switch (state) {
        ExercisesInitial() || ExercisesLoading() => const _LoadingList(),
        ExercisesError(:final message)            => _ErrorView(message: message),
        ExercisesLoaded()                         => _LoadedList(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BodyPartFilterTabs(
          bodyParts: state.bodyParts,
          selected: state.selectedBodyPart,
          onSelect: (p) =>
              context.read<ExercisesCubit>().filterByBodyPart(p),
        ),
        const SizedBox(height: AppConstants.spaceL),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH,
            ),
            itemCount: state.exercises.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spaceM),
            itemBuilder: (context, i) {
              if (i == state.exercises.length) {
                return const Padding(
                  padding: EdgeInsets.all(AppConstants.spaceXL),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
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

// ─── Search Results ─────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseSearchCubit, ExerciseSearchState>(
      builder: (context, state) => switch (state) {
        ExerciseSearchIdle()                        => const _SearchIdleView(),
        ExerciseSearchLoading()                     => const _LoadingList(),
        ExerciseSearchError(:final message)         => _ErrorView(message: message),
        ExerciseSearchLoaded(:final results) when results.isEmpty
                                                    => const _EmptyView(),
        ExerciseSearchLoaded(:final results)        => ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH,
            ),
            itemCount: results.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spaceM),
            itemBuilder: (context, i) => ExerciseCard(
              exercise: results[i],
              onTap: () => context.push('/exercises/${results[i].id}'),
            ),
          ),
      },
    );
  }
}

// ─── States UI ──────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPaddingH,
      ),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceM),
      itemBuilder: (_, __) => _ExerciseShimmer(),
    );
  }
}

class _ExerciseShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderSubtle),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
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
          const SizedBox(height: AppConstants.spaceL),
          GestureDetector(
            onTap: () => context.read<ExercisesCubit>().loadInitial(),
            child: Text(AppStrings.tryAgain,
                style: AppTextStyles.accentLabel),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: AppConstants.spaceM),
          Text(AppStrings.noResults, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _SearchIdleView extends StatelessWidget {
  const _SearchIdleView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppStrings.searchWorkout,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
    );
  }
}
