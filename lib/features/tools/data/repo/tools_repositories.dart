import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../service/food_data_service.dart';


abstract interface class FoodRepository {
  Future<ApiResult<FoodNutrition>> getFoodDetails(String query);
}

final class FoodRepositoryImpl implements FoodRepository {
  const FoodRepositoryImpl(this._service);
  final FoodDataService _service;

  @override
  Future<ApiResult<FoodNutrition>> getFoodDetails(String query) async {
    if (query.trim().isEmpty) {
      return ApiResult.failure(const ValidationFailure('أدخل اسم الطعام'));
    }
    try {
      final data = await _service.getDetails(query.trim());
      return ApiResult.success(data);
    } on Failure catch (f) {
      return ApiResult.failure(f);
    } catch (e) {
      return ApiResult.failure(UnknownFailure(e.toString()));
    }
  }
}


class BmiResult {
   BmiResult({required this.bmi, required this.category, required this.color});
  final double bmi;
  final String category;
  final int color;
}

abstract interface class BmiRepository {
  ApiResult<BmiResult> calculate({required double heightCm, required double weightKg});
}

final class BmiRepositoryImpl implements BmiRepository {
  const BmiRepositoryImpl();

  @override
  ApiResult<BmiResult> calculate({required double heightCm, required double weightKg}) {
    if (heightCm <= 0 || weightKg <= 0) {
      return ApiResult.failure(const ValidationFailure('القيم يجب أن تكون أكبر من صفر'));
    }
    final h = heightCm / 100;
    final bmi = weightKg / (h * h);
    final (cat, colorVal) = _classify(bmi);
    return ApiResult.success(BmiResult(bmi: bmi, category: cat, color: colorVal));
  }

  (String, int) _classify(double bmi) {
    if (bmi < AppConstants.bmiUnderweightMax) return ('نقص في الوزن', 0xFF7B6EFF);
    if (bmi <= AppConstants.bmiNormalMax)     return ('وزن صحي',      0xFF34DCA0);
    if (bmi <= AppConstants.bmiOverweightMax) return ('زيادة في الوزن',0xFFFFAB2E);
    if (bmi <= AppConstants.bmiObeseMax)      return ('سمنة',         0xFFFF8C42);
    return ('سمنة مفرطة', 0xFFFF5C5C);
  }
}


abstract interface class IdealWeightRepository {
  ApiResult<double> calculate({required double heightCm, required String gender});
}

final class IdealWeightRepositoryImpl implements IdealWeightRepository {
  const IdealWeightRepositoryImpl();

  @override
  ApiResult<double> calculate({required double heightCm, required String gender}) {
    if (heightCm <= 0) {
      return ApiResult.failure(const ValidationFailure('أدخل طولاً صحيحاً'));
    }
    if (gender.isEmpty) {
      return ApiResult.failure(const ValidationFailure('اختر النوع'));
    }
    final h = gender == 'MALE' ? heightCm : heightCm - 10;
    final ideal = 22 * (h / 100) * (h / 100);
    return ApiResult.success(ideal);
  }
}


class CalorieResult {
  const CalorieResult({
    required this.maintenance,
    required this.lose05,
    required this.lose10,
    required this.gain05,
    required this.gain10,
  });

  final double maintenance;
  final double lose05;  // -500 kcal/day → -0.5 kg/week
  final double lose10;  // -1000 kcal/day → -1 kg/week
  final double gain05;  // +500
  final double gain10;  // +1000
}

abstract interface class CalorieRepository {
  ApiResult<CalorieResult> calculate({
    required double heightCm,
    required double weightKg,
    required double ageYears,
    required String gender,
    required String activityLevel,
  });
}

final class CalorieRepositoryImpl implements CalorieRepository {
  const CalorieRepositoryImpl();

  @override
  ApiResult<CalorieResult> calculate({
    required double heightCm,
    required double weightKg,
    required double ageYears,
    required String gender,
    required String activityLevel,
  }) {
    if (heightCm <= 0 || weightKg <= 0 || ageYears <= 0) {
      return ApiResult.failure(const ValidationFailure('أدخل جميع البيانات'));
    }
    if (gender.isEmpty) {
      return ApiResult.failure(const ValidationFailure('اختر النوع'));
    }
    if (activityLevel.isEmpty) {
      return ApiResult.failure(const ValidationFailure('اختر مستوى النشاط'));
    }

    // Mifflin-St Jeor BMR
    final double bmr = gender == 'MALE'
        ? 10 * weightKg + 6.25 * heightCm - 5 * ageYears + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * ageYears - 161;

    final multiplier =
        AppConstants.activityMultipliers[activityLevel] ?? 1.2;
    final tdee = bmr * multiplier;

    return ApiResult.success(CalorieResult(
      maintenance: tdee,
      lose05: tdee - 500,
      lose10: tdee - 1000,
      gain05: tdee + 500,
      gain10: tdee + 1000,
    ));
  }
}
