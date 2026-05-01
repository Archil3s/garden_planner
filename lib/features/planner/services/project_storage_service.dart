import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/garden_project.dart';

class ProjectStorageService {
  static const String _currentProjectKey = 'garden_planner.current_project';

  Future<void> saveProject(GardenProject project) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_currentProjectKey, jsonEncode(project.toJson()));
  }

  Future<GardenProject?> loadProject() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_currentProjectKey);

    if (rawJson == null || rawJson.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawJson);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved project JSON must be an object.');
    }

    return GardenProject.fromJson(decoded);
  }

  Future<void> clearProject() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_currentProjectKey);
  }
}
