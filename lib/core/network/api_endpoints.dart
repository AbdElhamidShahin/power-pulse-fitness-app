abstract class ApiEndpoints {
  ApiEndpoints._();

  static const String exerciseDbBaseUrl = 'https://exercisedb.p.rapidapi.com';
  static const String exerciseDbHost = 'exercisedb.p.rapidapi.com';

  static const String exercises = '/exercises';
  static const String exerciseById = '/exercises/exercise';
  static const String exercisesByTarget = '/exercises/target';
  static const String exercisesByEquip = '/exercises/equipment';
  static const String exercisesByName = '/exercises/name';
  static const String bodyPartList = '/exercises/bodyPartList';
  static const String equipmentList = '/exercises/equipmentList';
  static const String targetList = '/exercises/targetList';

  static const String foodBaseUrl = 'https://world.openfoodfacts.org';
  static const String foodSearch = '/cgi/search.pl';
  static const String foodByBarcode = '/api/v0/product';
}
