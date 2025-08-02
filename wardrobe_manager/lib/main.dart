import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/helpers/settings_helper.dart';
import 'package:wardrobe_manager/models/settings.dart';
import 'package:wardrobe_manager/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseHelper.instance.database;
  
  final prefs = await SharedPreferences.getInstance();
  final settingsHelper = SettingsHelper(prefs);
  final settings = settingsHelper.getSettings();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SettingsHelper>.value(value: settingsHelper),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return MaterialApp(
      title: 'Wardrobe Manager',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}