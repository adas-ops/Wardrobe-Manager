// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/outfit.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Outfit>> _outfits = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    final outfits = await _dbHelper.getAllOutfits();
    final groupedOutfits = <DateTime, List<Outfit>>{};
    
    for (final outfit in outfits) {
      final date = DateTime.parse(outfit.date);
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      if (groupedOutfits.containsKey(dateOnly)) {
        groupedOutfits[dateOnly]!.add(outfit);
      } else {
        groupedOutfits[dateOnly] = [outfit];
      }
    }
    
    setState(() => _outfits = groupedOutfits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _outfits[day] ?? [];
            },
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null && _outfits.containsKey(_selectedDay))
            Expanded(
              child: ListView.builder(
                itemCount: _outfits[_selectedDay]!.length,
                itemBuilder: (context, index) {
                  final outfit = _outfits[_selectedDay]![index];
                  return ListTile(
                    title: Text(outfit.name),
                    subtitle: Text('Top: ${outfit.topId}, Bottom: ${outfit.bottomId}'),
                  );
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No outfits planned for this date'),
            ),
        ],
      ),
    );
  }
}