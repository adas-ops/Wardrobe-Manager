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
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothing Stats', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 28),
              if (_mostWornItem != null) ...[
                Text(
                  'Most Worn Item',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          child: _mostWornItem!.imagePath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_mostWornItem!.imagePath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Icons.broken_image, 
                                          size: 30,
                                          color: colorScheme.onSurfaceVariant),
                                      );
                                    },
                                  ),
                                )
                              : Icon(Icons.photo, size: 30, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _mostWornItem!.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_mostWornItem!.wearCount} wears',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
              Text(
                'Category Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              ..._categoryCounts.entries.map((entry) {
                final percentage = entry.value / _totalItems;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${entry.value} items',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          if (percentage > 0.15)
                            Text(
                              '${entry.value} items',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withAlpha(178), // 0.7 opacity
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              if (_items.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined, 
                        size: 64, 
                        color: colorScheme.onSurface.withAlpha(102) // 0.4 opacity
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withAlpha(153), // 0.6 opacity
                        ),
                      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title, 
              style: TextStyle(
                fontSize: 14, 
                color: colorScheme.onSurface.withAlpha(153) // 0.6 opacity
              )
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}