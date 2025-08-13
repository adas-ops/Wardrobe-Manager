import 'package:flutter/material.dart';
import 'package:wardrobe_manager/screens/add_item_screen.dart';
import 'package:wardrobe_manager/screens/planner_screen.dart';
import 'package:wardrobe_manager/screens/statistics_screen.dart';
import 'package:wardrobe_manager/screens/wardrobe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const WardrobeScreen(),
    const PlannerScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
                setState(() {});
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final onSurfaceColor = colorScheme.onSurface;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.alphaBlend(
              Colors.black.withAlpha(25),
              colorScheme.surface,
            ),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        elevation: 8,
        backgroundColor: colorScheme.surface,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color.alphaBlend(
          onSurfaceColor.withAlpha(153),
          colorScheme.surface,
        ),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.checkroom_outlined, size: 26),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  primaryColor.withAlpha(25),
                  colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.checkroom, size: 26, color: primaryColor),
            ),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.calendar_month_outlined, size: 26),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  primaryColor.withAlpha(25),
                  colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_month, size: 26, color: primaryColor),
            ),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.analytics_outlined, size: 26),
            ),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  primaryColor.withAlpha(25),
                  colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.analytics, size: 26, color: primaryColor),
            ),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}