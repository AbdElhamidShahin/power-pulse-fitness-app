import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/pp_input.dart';
import '../../logic/cubit/exercises_cubit.dart';
import '../widgets/exercises_header.dart';
import '../widgets/exercises_list.dart';
import '../widgets/search_results_list.dart';
import '../widgets/stat_item.dart';

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      context.read<ExercisesCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _isSearching = !_isSearching);
    if (!_isSearching) {
      _searchController.clear();
      context.read<ExerciseSearchCubit>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ExercisesHeader(
                    isSearching: _isSearching,
                    onSearchTap: _toggleSearch,
                  ),
                  if (_isSearching) ...[
                    SizedBox(height: 12.h),
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
            SizedBox(height: 20.h),
            if (!_isSearching) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatItem(value: '380', label: 'متوسط السعرات'),
                      StatItem(value: '12', label: 'إجمالي'),
                      StatItem(value: '3', label: 'هذا الأسبوع'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
            Expanded(
              child: _isSearching
                  ? const SearchResultsList()
                  : ExercisesList(scrollController: _scrollController),
            ),
          ],
        ),
      ),
    );
  }
}