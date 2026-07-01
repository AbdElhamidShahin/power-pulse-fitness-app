import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../logic/cubit/progress_cubit.dart';
import '../../logic/cubit/progress_state.dart';


class WeightSheet extends StatefulWidget {
  const WeightSheet({super.key});

  @override
  State<WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<WeightSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeightLogCubit, WeightLogState>(
      listener: (context, state) {
        if (state is WeightLogSuccess) Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          24.h,
          16.w,
          MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'تسجيل الوزن',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textDirection: TextDirection.ltr,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16.sp),
              decoration: InputDecoration(
                labelText: 'الوزن',
                suffixText: 'كجم',
                filled: true,
                fillColor: AppColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: BlocBuilder<WeightLogCubit, WeightLogState>(
                builder: (context, state) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgDark,
                    foregroundColor: AppColors.textOnDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: state is WeightLogLoading
                      ? null
                      : () {
                    final w = double.tryParse(_ctrl.text);
                    if (w != null && w > 0) {
                      context.read<WeightLogCubit>().addEntry(w);
                    }
                  },
                  child: state is WeightLogLoading
                      ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'حفظ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}