import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  String defaultCategory;
  String photoQuality;
  bool darkModeEnabled;
  bool backupEnabled;
  bool showTutorial;

  AppSettings({
    this.defaultCategory = 'All',
    this.photoQuality = 'Medium',
    this.darkModeEnabled = false,
    this.backupEnabled = true,
    this.showTutorial = true,
  });

  void updateSettings({
    String? defaultCategory,
    String? photoQuality,
    bool? darkModeEnabled,
    bool? backupEnabled,
    bool? showTutorial,
  }) {
    if (defaultCategory != null) this.defaultCategory = defaultCategory;
    if (photoQuality != null) this.photoQuality = photoQuality;
    if (darkModeEnabled != null) this.darkModeEnabled = darkModeEnabled;
    if (backupEnabled != null) this.backupEnabled = backupEnabled;
    if (showTutorial != null) this.showTutorial = showTutorial;
    notifyListeners();
  }

  void resetToDefaults() {
    defaultCategory = 'All';
    photoQuality = 'Medium';
    darkModeEnabled = false;
    backupEnabled = true;
    showTutorial = true;
    notifyListeners();
  }
}