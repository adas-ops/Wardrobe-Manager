import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ClothingItem> _items = [];
  Map<String, int> _categoryCounts = {};
  int _totalItems = 0;
  int _totalWears = 0;
  ClothingItem? _mostWornItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final items = await _dbHelper.getAllItems();
    
    // Calculate statistics
    final categoryCounts = <String, int>{};
    int totalWears = 0;
    ClothingItem? mostWorn;
    
    for (final item in items) {
      categoryCounts.update(
        item.category, 
        (value) => value + 1, 
        ifAbsent: () => 1
      );
      totalWears += item.wearCount;
      
      if (mostWorn == null || item.wearCount > mostWorn.wearCount) {
        mostWorn = item;
      }
    }

    setState(() {
      _items = items;
      _categoryCounts = categoryCounts;
      _totalItems = items.length;
      _totalWears = totalWears;
      _mostWornItem = mostWorn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Statistics'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.checkroom,
                      title: 'Total Items',
                      value: _totalItems.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.repeat,
                      title: 'Total Wears',
                      value: _totalWears.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_mostWornItem != null) ...[
                const Text(
                  'Most Worn Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: _mostWornItem!.imagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_mostWornItem!.imagePath),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.photo),
                    ),
                    title: Text(_mostWornItem!.name),
                    subtitle: Text('${_mostWornItem!.wearCount} wears'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                'Category Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._categoryCounts.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            '${entry.value} items',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: entry.value / _totalItems,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                        backgroundColor: Colors.grey[200],
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(entry.value / _totalItems * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
              if (_items.isEmpty)
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No data available'),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}