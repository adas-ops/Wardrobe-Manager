import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';
import 'preference_keys.dart';

class SettingsHelper {
  final SharedPreferences prefs;

  SettingsHelper(this.prefs);

  AppSettings getSettings() {
    return AppSettings(
      defaultCategory: prefs.getString(PreferenceKeys.defaultCategory) ?? 'All',
      photoQuality: prefs.getString(PreferenceKeys.photoQuality) ?? 'Medium',
      darkModeEnabled: prefs.getBool(PreferenceKeys.darkMode) ?? false,
      backupEnabled: prefs.getBool(PreferenceKeys.autoBackup) ?? true,
      showTutorial: prefs.getBool(PreferenceKeys.showTutorial) ?? true,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    await prefs.setString(PreferenceKeys.defaultCategory, settings.defaultCategory);
    await prefs.setString(PreferenceKeys.photoQuality, settings.photoQuality);
    await prefs.setBool(PreferenceKeys.darkMode, settings.darkModeEnabled);
    await prefs.setBool(PreferenceKeys.autoBackup, settings.backupEnabled);
    await prefs.setBool(PreferenceKeys.showTutorial, settings.showTutorial);
  }
}