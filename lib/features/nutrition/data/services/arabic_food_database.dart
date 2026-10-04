import '../models/food_entity.dart';

/// قاعدة بيانات الأطعمة العربية المحلية
/// تشمل: أكلات شعبية، علب معلبة، وجبات سريعة شائعة
abstract class ArabicFoodDatabase {
  ArabicFoodDatabase._();

  static List<FoodItem> get all => [
    ..._egyptianFoods,
    ..._arabicFoods,
    ..._cannedFoods,
    ..._grains,
    ..._meatAndPoultry,
    ..._dairyAndEggs,
    ..._vegetablesAndFruits,
    ..._snacksAndSweets,
  ];

  // ─── أكلات مصرية شعبية ───────────────────────────────────
  static const _egyptianFoods = [
    FoodItem(id: 'ar_001', name: 'Kushari', nameAr: 'كشري', calories: 190, protein: 6, carbs: 38, fat: 2, servingSize: 250, servingUnit: 'جم'),
    FoodItem(id: 'ar_002', name: 'Ful Medames', nameAr: 'فول مدمس', calories: 150, protein: 8, carbs: 22, fat: 4, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_003', name: 'Falafel (Taameya)', nameAr: 'طعمية', calories: 330, protein: 14, carbs: 30, fat: 18, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'ar_004', name: 'Egyptian Rice', nameAr: 'أرز مصري مسلوق', calories: 130, protein: 3, carbs: 28, fat: 0.5, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_005', name: 'Macarona Bechamel', nameAr: 'مكرونة بشاميل', calories: 280, protein: 12, carbs: 32, fat: 12, servingSize: 250, servingUnit: 'جم'),
    FoodItem(id: 'ar_006', name: 'Molokhia', nameAr: 'ملوخية', calories: 55, protein: 4, carbs: 5, fat: 2, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_007', name: 'Stuffed Grape Leaves', nameAr: 'ورق عنب', calories: 200, protein: 7, carbs: 25, fat: 8, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_008', name: 'Hawawshi', nameAr: 'هواوشي', calories: 380, protein: 22, carbs: 28, fat: 20, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_009', name: 'Egyptian Bread (Baladi)', nameAr: 'عيش بلدي', calories: 250, protein: 9, carbs: 52, fat: 1.5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'ar_010', name: 'Shawarma Chicken', nameAr: 'شاورما دجاج', calories: 290, protein: 28, carbs: 18, fat: 12, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_011', name: 'Kofta', nameAr: 'كفتة', calories: 280, protein: 20, carbs: 5, fat: 20, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_012', name: 'Kebab', nameAr: 'كباب', calories: 250, protein: 22, carbs: 2, fat: 17, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_013', name: 'Fiteer Meshaltet', nameAr: 'فطير مشلتت', calories: 380, protein: 8, carbs: 42, fat: 20, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_014', name: 'Lentil Soup', nameAr: 'شوربة عدس', calories: 120, protein: 7, carbs: 20, fat: 2, servingSize: 250, servingUnit: 'جم'),
    FoodItem(id: 'ar_015', name: 'Vermicelli Rice', nameAr: 'أرز بالشعرية', calories: 145, protein: 3.5, carbs: 30, fat: 2, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_016', name: 'Chicken with rice', nameAr: 'فراخ مع أرز', calories: 320, protein: 25, carbs: 30, fat: 10, servingSize: 300, servingUnit: 'جم'),
    FoodItem(id: 'ar_017', name: 'Om Ali', nameAr: 'أم علي', calories: 420, protein: 9, carbs: 48, fat: 22, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_018', name: 'Basbosa', nameAr: 'بسبوسة', calories: 350, protein: 5, carbs: 58, fat: 12, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'ar_019', name: 'Grilled Fish', nameAr: 'سمكة مشوية', calories: 160, protein: 28, carbs: 0, fat: 5, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_020', name: 'Mahshi (Stuffed Veg)', nameAr: 'محشي', calories: 175, protein: 6, carbs: 28, fat: 5, servingSize: 200, servingUnit: 'جم'),
  ];

  // ─── أكلات عربية ─────────────────────────────────────────
  static const _arabicFoods = [
    FoodItem(id: 'ar_021', name: 'Hummus', nameAr: 'حمص بالطحينة', calories: 170, protein: 8, carbs: 18, fat: 8, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'ar_022', name: 'Mutabbal / Baba Ganoush', nameAr: 'متبل / بابا غنوج', calories: 120, protein: 3, carbs: 12, fat: 7, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'ar_023', name: 'Fattoush Salad', nameAr: 'سلطة فتوش', calories: 110, protein: 3, carbs: 16, fat: 4, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_024', name: 'Tabbouleh', nameAr: 'تبولة', calories: 90, protein: 3, carbs: 12, fat: 4, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_025', name: 'Mansaf (Rice & Lamb)', nameAr: 'منسف', calories: 450, protein: 30, carbs: 40, fat: 18, servingSize: 350, servingUnit: 'جم'),
    FoodItem(id: 'ar_026', name: 'Knafeh', nameAr: 'كنافة', calories: 380, protein: 8, carbs: 50, fat: 16, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_027', name: 'Lebanese Bread (Pita)', nameAr: 'خبز لبناني (پيتا)', calories: 270, protein: 9, carbs: 55, fat: 1, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'ar_028', name: 'Chicken Tikka (Arabic)', nameAr: 'تيكا دجاج', calories: 220, protein: 32, carbs: 5, fat: 9, servingSize: 200, servingUnit: 'جم'),
    FoodItem(id: 'ar_029', name: 'Grilled Shrimp', nameAr: 'جمبري مشوي', calories: 120, protein: 22, carbs: 2, fat: 3, servingSize: 150, servingUnit: 'جم'),
    FoodItem(id: 'ar_030', name: 'Laham Bil Ajeen (Meat Pizza)', nameAr: 'لحم بعجين', calories: 300, protein: 14, carbs: 32, fat: 14, servingSize: 150, servingUnit: 'جم'),
  ];

  // ─── أكلات معلبة ─────────────────────────────────────────
  static const _cannedFoods = [
    FoodItem(id: 'cn_001', name: 'Canned Tuna in Water', nameAr: 'تونة معلبة بالماء', calories: 120, protein: 26, carbs: 0, fat: 1, servingSize: 85, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_002', name: 'Canned Tuna in Oil', nameAr: 'تونة معلبة بالزيت', calories: 190, protein: 24, carbs: 0, fat: 10, servingSize: 85, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_003', name: 'Canned Ful Medames', nameAr: 'فول معلب', calories: 130, protein: 8, carbs: 22, fat: 1, servingSize: 200, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_004', name: 'Canned Chickpeas', nameAr: 'حمص معلب', calories: 140, protein: 7, carbs: 24, fat: 2, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_005', name: 'Canned Kidney Beans', nameAr: 'لوبيا حمراء معلبة', calories: 110, protein: 7.5, carbs: 20, fat: 0.5, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_006', name: 'Canned Corn', nameAr: 'ذرة معلبة', calories: 90, protein: 3, carbs: 20, fat: 1, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_007', name: 'Canned White Beans', nameAr: 'فاصوليا بيضاء معلبة', calories: 125, protein: 7, carbs: 22, fat: 0.5, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_008', name: 'Canned Green Peas', nameAr: 'بسلة معلبة', calories: 75, protein: 5, carbs: 13, fat: 0.5, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_009', name: 'Canned Sardines', nameAr: 'سردين معلب', calories: 200, protein: 22, carbs: 0, fat: 12, servingSize: 100, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_010', name: 'Canned Tomatoes', nameAr: 'طماطم معلبة مهروسة', calories: 40, protein: 2, carbs: 8, fat: 0.5, servingSize: 200, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_011', name: 'Canned Lentils', nameAr: 'عدس معلب', calories: 115, protein: 9, carbs: 20, fat: 0.5, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_012', name: 'Canned Mushrooms', nameAr: 'فطر معلب', calories: 30, protein: 3, carbs: 4, fat: 0.5, servingSize: 100, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_013', name: 'Canned Mackerel', nameAr: 'ماكريل معلب', calories: 170, protein: 20, carbs: 0, fat: 10, servingSize: 100, servingUnit: 'جم', brand: 'معلبة'),
    FoodItem(id: 'cn_014', name: 'Canned Peas & Carrots', nameAr: 'بسلة وجزر معلبة', calories: 65, protein: 3, carbs: 12, fat: 0.5, servingSize: 150, servingUnit: 'جم', brand: 'معلبة'),
  ];

  // ─── حبوب وبقوليات ───────────────────────────────────────
  static const _grains = [
    FoodItem(id: 'gr_001', name: 'White Rice (raw)', nameAr: 'أرز أبيض (خام)', calories: 360, protein: 7, carbs: 80, fat: 0.5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_002', name: 'Brown Rice (raw)', nameAr: 'أرز بني (خام)', calories: 350, protein: 7, carbs: 77, fat: 2, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_003', name: 'Spaghetti (dry)', nameAr: 'مكرونة إسباجيتي (جافة)', calories: 371, protein: 13, carbs: 75, fat: 1.5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_004', name: 'White Bread', nameAr: 'خبز توست أبيض', calories: 265, protein: 9, carbs: 50, fat: 3.5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_005', name: 'Whole Wheat Bread', nameAr: 'خبز أسمر كامل القمح', calories: 245, protein: 11, carbs: 44, fat: 3.5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_006', name: 'Oats', nameAr: 'شوفان', calories: 389, protein: 17, carbs: 66, fat: 7, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_007', name: 'Quinoa (raw)', nameAr: 'كينوا (خام)', calories: 368, protein: 14, carbs: 64, fat: 6, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'gr_008', name: 'Lentils (raw)', nameAr: 'عدس أحمر (خام)', calories: 352, protein: 25, carbs: 60, fat: 1, servingSize: 100, servingUnit: 'جم'),
  ];

  // ─── لحوم ودواجن ─────────────────────────────────────────
  static const _meatAndPoultry = [
    FoodItem(id: 'mt_001', name: 'Chicken Breast (grilled)', nameAr: 'صدر فراخ مشوي', calories: 165, protein: 31, carbs: 0, fat: 3.5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'mt_002', name: 'Chicken Thigh (grilled)', nameAr: 'فخدة فراخ مشوية', calories: 210, protein: 26, carbs: 0, fat: 11, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'mt_003', name: 'Beef (lean, grilled)', nameAr: 'لحم بقري قليل الدهن مشوي', calories: 215, protein: 27, carbs: 0, fat: 12, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'mt_004', name: 'Lamb (grilled)', nameAr: 'ضأن مشوي', calories: 260, protein: 25, carbs: 0, fat: 17, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'mt_005', name: 'Ground Beef (80% lean)', nameAr: 'لحم مفروم بقري', calories: 254, protein: 20, carbs: 0, fat: 19, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'mt_006', name: 'Turkey Breast', nameAr: 'صدر ديك رومي', calories: 135, protein: 29, carbs: 0, fat: 1, servingSize: 100, servingUnit: 'جم'),
  ];

  // ─── ألبان وبيض ──────────────────────────────────────────
  static const _dairyAndEggs = [
    FoodItem(id: 'dy_001', name: 'Egg (whole, boiled)', nameAr: 'بيضة كاملة مسلوقة', calories: 78, protein: 6, carbs: 0.5, fat: 5, servingSize: 50, servingUnit: 'جم'),
    FoodItem(id: 'dy_002', name: 'Egg White', nameAr: 'بياض بيض', calories: 17, protein: 3.6, carbs: 0.2, fat: 0, servingSize: 33, servingUnit: 'جم'),
    FoodItem(id: 'dy_003', name: 'Whole Milk', nameAr: 'لبن كامل الدسم', calories: 149, protein: 8, carbs: 12, fat: 8, servingSize: 240, servingUnit: 'مل'),
    FoodItem(id: 'dy_004', name: 'Skimmed Milk', nameAr: 'لبن خالي الدسم', calories: 83, protein: 8, carbs: 12, fat: 0.2, servingSize: 240, servingUnit: 'مل'),
    FoodItem(id: 'dy_005', name: 'Greek Yogurt', nameAr: 'زبادي يوناني', calories: 100, protein: 17, carbs: 6, fat: 0.7, servingSize: 170, servingUnit: 'جم'),
    FoodItem(id: 'dy_006', name: 'Egyptian White Cheese', nameAr: 'جبنة بيضاء مصرية', calories: 260, protein: 16, carbs: 2, fat: 21, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'dy_007', name: 'Cottage Cheese', nameAr: 'جبنة قريش', calories: 110, protein: 13, carbs: 4, fat: 5, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'dy_008', name: 'Rumi Cheese', nameAr: 'جبنة رومي', calories: 350, protein: 25, carbs: 2, fat: 28, servingSize: 100, servingUnit: 'جم'),
  ];

  // ─── خضروات وفواكه ──────────────────────────────────────
  static const _vegetablesAndFruits = [
    FoodItem(id: 'vg_001', name: 'Tomato', nameAr: 'طماطم', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_002', name: 'Cucumber', nameAr: 'خيار', calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_003', name: 'Onion', nameAr: 'بصل', calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_004', name: 'Potato (boiled)', nameAr: 'بطاطس مسلوقة', calories: 77, protein: 2, carbs: 17, fat: 0.1, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_005', name: 'Sweet Potato', nameAr: 'بطاطا حلوة', calories: 86, protein: 1.6, carbs: 20, fat: 0.1, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_006', name: 'Banana', nameAr: 'موزة', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_007', name: 'Apple', nameAr: 'تفاحة', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_008', name: 'Mango', nameAr: 'مانجو', calories: 60, protein: 0.8, carbs: 15, fat: 0.4, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_009', name: 'Orange', nameAr: 'برتقالة', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_010', name: 'Watermelon', nameAr: 'بطيخ', calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_011', name: 'Carrot', nameAr: 'جزر', calories: 41, protein: 0.9, carbs: 10, fat: 0.2, servingSize: 100, servingUnit: 'جم'),
    FoodItem(id: 'vg_012', name: 'Eggplant', nameAr: 'باذنجان', calories: 25, protein: 1, carbs: 6, fat: 0.2, servingSize: 100, servingUnit: 'جم'),
  ];

  // ─── وجبات خفيفة وحلويات ─────────────────────────────────
  static const _snacksAndSweets = [
    FoodItem(id: 'sw_001', name: 'Nuts Mix', nameAr: 'مكسرات مشكلة', calories: 607, protein: 20, carbs: 13, fat: 55, servingSize: 30, servingUnit: 'جم'),
    FoodItem(id: 'sw_002', name: 'Peanut Butter', nameAr: 'زبدة الفول السوداني', calories: 588, protein: 25, carbs: 20, fat: 50, servingSize: 32, servingUnit: 'جم'),
    FoodItem(id: 'sw_003', name: 'Dark Chocolate', nameAr: 'شيكولاتة داكنة', calories: 545, protein: 5, carbs: 60, fat: 31, servingSize: 40, servingUnit: 'جم'),
    FoodItem(id: 'sw_004', name: 'Egyptian Sesame Bar (Simsimiya)', nameAr: 'سمسمية', calories: 520, protein: 12, carbs: 52, fat: 32, servingSize: 50, servingUnit: 'جم'),
    FoodItem(id: 'sw_005', name: 'Date', nameAr: 'تمرة', calories: 277, protein: 1.8, carbs: 75, fat: 0.2, servingSize: 30, servingUnit: 'جم'),
    FoodItem(id: 'sw_006', name: 'Honey', nameAr: 'عسل', calories: 304, protein: 0.3, carbs: 82, fat: 0, servingSize: 20, servingUnit: 'جم'),
    FoodItem(id: 'sw_007', name: 'Tahini', nameAr: 'طحينة', calories: 592, protein: 17, carbs: 22, fat: 53, servingSize: 30, servingUnit: 'جم'),
  ];

  /// بحث في قاعدة البيانات المحلية
  static List<FoodItem> search(String query) {
    if (query.trim().isEmpty) return all.take(20).toList();
    final q = query.toLowerCase().trim();
    return all.where((f) {
      return f.nameAr.contains(q) ||
          f.name.toLowerCase().contains(q) ||
          (f.brand?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
