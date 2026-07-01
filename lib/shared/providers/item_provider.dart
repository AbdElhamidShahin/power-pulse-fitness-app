import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/exercises/data/model/exercise.dart';

class ItemProvider with ChangeNotifier {
  Map<String, List<Exercise>> _items = {};

  ItemProvider() {
    _loadItems();
  }

  List<Exercise> getItems(String day) {
    return _items[day] ?? [];
  }

  void addItem(String day, Exercise item) {
    if (_items.containsKey(day)) {
      _items[day]?.add(item);
    } else {
      _items[day] = [item];
    }
    _saveItems();
    notifyListeners();
  }

  void removeItem(String day, Exercise item) {
    _items[day]?.remove(item);
    _saveItems();
    notifyListeners();
  }

  void _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((key, value) => MapEntry(key, jsonEncode(value)));
    await prefs.setString('items', jsonEncode(data));
  }

  void _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('items');
    if (data != null) {
      final Map<String, dynamic> json = jsonDecode(data);
      _items = json.map((key, value) => MapEntry(
          key,
          (jsonDecode(value) as List)
              .map((e) => Exercise.fromJson(e))
              .toList()));
      notifyListeners();
    }
  }
}
