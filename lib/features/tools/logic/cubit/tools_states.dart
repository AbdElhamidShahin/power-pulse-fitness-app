import '../../data/repo/tools_repositories.dart';
import '../../data/service/food_data_service.dart';


sealed class BmiState { const BmiState(); }
final class BmiInitial  extends BmiState { const BmiInitial(); }
final class BmiLoaded   extends BmiState {
  const BmiLoaded(this.result);
  final BmiResult result;
}
final class BmiError    extends BmiState {
  const BmiError(this.message);
  final String message;
}

// ── Food States ───────────────────────────────────────────────────────────────

sealed class FoodState { const FoodState(); }
final class FoodInitial  extends FoodState { const FoodInitial(); }
final class FoodLoading  extends FoodState { const FoodLoading(); }
final class FoodLoaded   extends FoodState {
  const FoodLoaded(this.nutrition);
  final FoodNutrition nutrition;
}
final class FoodError    extends FoodState {
  const FoodError(this.message);
  final String message;
}

// ── Ideal Weight States ───────────────────────────────────────────────────────

sealed class IdealWeightState { const IdealWeightState(); }
final class IdealWeightInitial extends IdealWeightState { const IdealWeightInitial(); }
final class IdealWeightLoaded  extends IdealWeightState {
  const IdealWeightLoaded(this.kg);
  final double kg;
}
final class IdealWeightError   extends IdealWeightState {
  const IdealWeightError(this.message);
  final String message;
}

// ── Calorie States ────────────────────────────────────────────────────────────

sealed class CalorieState { const CalorieState(); }
final class CalorieInitial extends CalorieState { const CalorieInitial(); }
final class CalorieLoaded  extends CalorieState {
  const CalorieLoaded(this.result);
  final CalorieResult result;
}
final class CalorieError   extends CalorieState {
  const CalorieError(this.message);
  final String message;
}
