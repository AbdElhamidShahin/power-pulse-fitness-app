/// Power Pulse — API Endpoints
abstract class ApiEndpoints {
  ApiEndpoints._();

  // ─── ExerciseDB (RapidAPI - Free tier) ─────────────────────
  // https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
  static const String exerciseDbBaseUrl = 'https://exercisedb.p.rapidapi.com';
  static const String exerciseDbHost    = 'exercisedb.p.rapidapi.com';

  // Exercises
  static const String exercises         = '/exercises';
  static const String exerciseById      = '/exercises/exercise'; // + /{id}
  static const String exercisesByTarget = '/exercises/target';   // + /{target}
  static const String exercisesByEquip  = '/exercises/equipment';// + /{type}
  static const String exercisesByName   = '/exercises/name';     // + /{name}
  static const String bodyPartList      = '/exercises/bodyPartList';
  static const String equipmentList     = '/exercises/equipmentList';
  static const String targetList        = '/exercises/targetList';

  // ─── Open Food Facts (100% Free - No key needed) ───────────
  // https://world.openfoodfacts.org/
  static const String foodBaseUrl       = 'https://world.openfoodfacts.org';
  static const String foodSearch        = '/cgi/search.pl';
  static const String foodByBarcode     = '/api/v0/product'; // + /{barcode}.json

  // ─── Numbers (سعرات - BMI - حسابات) ───────────────────────
  // كل الحسابات محلية - مفيش API
}
