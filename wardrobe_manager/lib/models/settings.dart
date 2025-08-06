import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  String defaultCategory;
  String photoQuality;
  bool darkModeEnabled;
  bool backupEnabled;
  bool showTutorial;
  String navLayout;
  bool showNavLabels;
  String sortOption;

  AppSettings({
    this.defaultCategory = 'All',
    this.photoQuality = 'Medium',
    this.darkModeEnabled = false,
    this.backupEnabled = true,
    this.showTutorial = true,
    this.navLayout = 'Standard',
    this.showNavLabels = true,
    this.sortOption = 'newest',
  });

  void updateSettings({
    String? defaultCategory,
    String? photoQuality,
    bool? darkModeEnabled,
    bool? backupEnabled,
    bool? showTutorial,
    String? navLayout,
    bool? showNavLabels,
    String? sortOption,
  }) {
    if (defaultCategory != null) this.defaultCategory = defaultCategory;
    if (photoQuality != null) this.photoQuality = photoQuality;
    if (darkModeEnabled != null) this.darkModeEnabled = darkModeEnabled;
    if (backupEnabled != null) this.backupEnabled = backupEnabled;
    if (showTutorial != null) this.showTutorial = showTutorial;
    if (navLayout != null) this.navLayout = navLayout;
    if (showNavLabels != null) this.showNavLabels = showNavLabels;
    if (sortOption != null) this.sortOption = sortOption;
    notifyListeners();
  }

  void resetToDefaults() {
    defaultCategory = 'All';
    photoQuality = 'Medium';
    darkModeEnabled = false;
    backupEnabled = true;
    showTutorial = true;
    navLayout = 'Standard';
    showNavLabels = true;
    sortOption = 'newest';
    notifyListeners();
  }
}