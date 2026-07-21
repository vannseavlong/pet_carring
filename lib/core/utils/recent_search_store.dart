import 'package:shared_preferences/shared_preferences.dart';

/// Persists the shop-search history shown on [SearchScreen] between app
/// launches. Most-recent-first, capped at [_maxEntries], case-insensitive
/// de-duplication.
abstract final class RecentSearchStore {
  static const _key = 'recent_shop_searches';
  static const _maxEntries = 8;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  static Future<List<String>> add(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return load();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    current.removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    final updated = current.take(_maxEntries).toList();
    await prefs.setStringList(_key, updated);
    return updated;
  }

  static Future<List<String>> remove(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    current.removeWhere((e) => e == term);
    await prefs.setStringList(_key, current);
    return current;
  }

  static Future<List<String>> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, const []);
    return const [];
  }
}
