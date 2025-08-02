import 'package:flutter/material.dart';
import 'package:wardrobe_manager/screens/add_item_screen.dart';
import 'package:wardrobe_manager/screens/favorites_screen.dart';
import 'package:wardrobe_manager/screens/settings_screen.dart';
import 'package:wardrobe_manager/screens/wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WardrobeScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
                // Refresh wardrobe screen
                setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}