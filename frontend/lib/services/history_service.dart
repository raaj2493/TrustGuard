import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis.dart';

class HistoryService {
  static const String _key = 'scan_history';
  static const int _maxItems = 50;

  Future<List<ScanRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => ScanRecord.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> addRecord(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(record.toJson()));
    if (raw.length > _maxItems) raw.removeAt(0);
    await prefs.setStringList(_key, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
