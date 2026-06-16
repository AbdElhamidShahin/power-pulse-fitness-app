import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/exercises/data/model/exercise.dart';

class ItemProvider with ChangeNotifier {
  static const _kKey = 'custom_workout_plan';

  Map<String, List<Exercise>> _items = {};

  ItemProvider() {
    _loadItems();
  }

  Map<String, List<Exercise>> get items => Map.unmodifiable(_items);

  List<Exercise> getItems(String day) => List.unmodifiable(_items[day] ?? []);

  void addItem(String day, Exercise item) {
    _items.putIfAbsent(day, () => []).add(item);
    _saveItems();
    notifyListeners();
  }

  void removeItem(String day, Exercise item) {
    _items[day]?.remove(item);
    _saveItems();
    notifyListeners();
  }

  void _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _items.map(
        (key, value) =>
            MapEntry(key, jsonEncode(value.map((e) => e.toJson()).toList())),
      );
      await prefs.setString(_kKey, jsonEncode(encoded));
    } catch (_) {
      // Silent — UI already updated; persistence failure is non-critical.
    }
  }

  void _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw == null) return;
      final outer = jsonDecode(raw) as Map<String, dynamic>;
      _items = outer.map((key, value) {
        final list = (jsonDecode(value as String) as List)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(key, list);
      });
      notifyListeners();
    } catch (_) {
      _items = {};
    }
  }
}
