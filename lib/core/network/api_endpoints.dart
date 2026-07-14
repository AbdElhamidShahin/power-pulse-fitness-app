abstract class ApiEndpoints {
  ApiEndpoints._();

  static const String exerciseDbBaseUrl =
      'https://cdn.jsdelivr.net/gh/AbdElhamidShahin/power-pulse-exercises@main';

  static const String exercisesJson = '/data/exercises_en.json';

  static const String mediaCdnBase =
      'https://cdn.jsdelivr.net/gh/hasaneyldrm/exercises-dataset@main';
  static const String foodBaseUrl = 'https://world.openfoodfacts.org';
  static const String foodSearch = '/cgi/search.pl';
  static const String foodByBarcode = '/api/v0/product'; // + /{barcode}.json
}
