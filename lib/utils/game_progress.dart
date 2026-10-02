import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  static Future<void> saveLevel(
      String username, String game, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${username}_${game}_level', level);
  }

  static Future<int> loadLevel(
      String username, String game) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${username}_${game}_level') ?? 1;
  }

  static Future<void> saveScore(
      String username, String game, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('${username}_${game}_score') ?? 0;
    if (score > best) {
      await prefs.setInt('${username}_${game}_score', score);
    }
  }

  static Future<int> loadBestScore(
      String username, String game) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${username}_${game}_score') ?? 0;
  }
}