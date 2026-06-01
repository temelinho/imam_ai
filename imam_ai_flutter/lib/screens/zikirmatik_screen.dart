import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';

class ZikirmatikScreen extends StatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  State<ZikirmatikScreen> createState() => ZikirmatikScreenState();
}

class ZikirmatikScreenState extends State<ZikirmatikScreen> {
  int _counter = 0;
  int _target = 33;
  String _selectedZikir = 'Sübhanallah';

  final List<Map<String, dynamic>> _predefinedZikirs = [
    {'name': 'Sübhanallah', 'target': 33, 'arabic': 'سُبْحَانَ ٱللَّٰهِ'},
    {'name': 'Elhamdülillah', 'target': 33, 'arabic': 'ٱلْحَمْدُ لِلَّٰهِ'},
    {'name': 'Allahü Ekber', 'target': 33, 'arabic': 'ٱللَّٰهُ أَكْبَرُ'},
    {'name': 'Lâ ilâhe illallah', 'target': 100, 'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ'},
    {'name': 'Estağfirullah', 'target': 100, 'arabic': 'أَسْتَغْفِرُ ٱللَّٰهِ'},
  ];

  Map<String, int> _weeklyStats = {};

  @override
  void initState() {
    super.initState();
    _loadZikirData();
    _loadWeeklyStats();
  }

  Future<void> _loadZikirData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedZikir = prefs.getString('zikir_selected') ?? 'Sübhanallah';
      _counter = prefs.getInt('zikir_counter_$_selectedZikir') ?? 0;
      _target = prefs.getInt('zikir_target_$_selectedZikir') ?? 33;
    });
  }

  Future<void> _loadWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('zikir_weekly_stats') ?? '{}';
    try {
      final Map<String, dynamic> decoded = jsonDecode(statsJson);
      setState(() {
        _weeklyStats = decoded.map((key, value) => MapEntry(key, value as int));
      });
    } catch (e) {
      _weeklyStats = {};
    }
  }

  Future<void> _saveZikirData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zikir_selected', _selectedZikir);
    await prefs.setInt('zikir_counter_$_selectedZikir', _counter);
    await prefs.setInt('zikir_target_$_selectedZikir', _target);
  }

  Future<void> _incrementCounter() async {
    // Standard haptic vibration on tap
    HapticFeedback.lightImpact();
    
    setState(() {
      _counter++;
    });

    // Record stats for today
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _weeklyStats[todayStr] = (_weeklyStats[todayStr] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zikir_weekly_stats', jsonEncode(_weeklyStats));

    if (_counter == _target) {
      // Success heavy vibration
      HapticFeedback.vibrate();
      _showTargetReachedDialog();
    }
    
    await _saveZikirData();
  }

  void resetCounter() {
    _resetCounter();
  }

  void _resetCounter() async {
    setState(() {
      _counter = 0;
    });
    await _saveZikirData();
  }

  void _showTargetReachedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Tebrikler!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: Text(
            '$_selectedZikir zikri için belirlediğiniz $_target hedefine ulaştınız.',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetCounter();
              },
              child: const Text(
                'Sıfırla',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Kapat',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeZikir(String zikirName) async {
    final zikir = _predefinedZikirs.firstWhere((z) => z['name'] == zikirName);
    setState(() {
      _selectedZikir = zikir['name'];
      _target = zikir['target'];
    });
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('zikir_counter_$_selectedZikir') ?? 0;
    await _saveZikirData();
  }

  List<double> _getWeeklyData() {
    final List<double> result = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      result.add((_weeklyStats[dateStr] ?? 0).toDouble());
    }
    return result;
  }

  List<String> _getWeeklyLabels() {
    final List<String> result = [];
    final now = DateTime.now();
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      result.add(weekdays[date.weekday - 1]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currentArabic = _predefinedZikirs.firstWhere(
      (z) => z['name'] == _selectedZikir,
      orElse: () => {'arabic': ''},
    )['arabic'];

    final weeklyData = _getWeeklyData();
    final weeklyLabels = _getWeeklyLabels();
    final maxVal = weeklyData.reduce(math.max);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Dropdown selector for predefined Zikirs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedZikir,
                isExpanded: true,
                onChanged: (val) {
                  if (val != null) _changeZikir(val);
                },
                items: _predefinedZikirs.map((zikir) {
                  return DropdownMenuItem<String>(
                    value: zikir['name'] as String,
                    child: Text(
                      zikir['name'] as String,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Large main tap area card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Column(
              children: [
                // Arabic writing
                Text(
                  currentArabic ?? '',
                  style: const TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 30,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Outer circle tap button
                GestureDetector(
                  onTap: _incrementCounter,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_counter',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '/ $_target',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Reset Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey, size: 24),
                      onPressed: _resetCounter,
                    ),
                    const Text(
                      'Sıfırla',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Weekly statistics bar chart
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Haftalık Zikir İstatistiği',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                // Simulating a bar chart with simple Row + Containers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final val = weeklyData[index];
                    final maxColHeight = 60.0;
                    final calculatedHeight = maxVal > 0 ? (val / maxVal) * maxColHeight : 0.0;
                    return Column(
                      children: [
                        Text(
                          '${val.toInt()}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 14,
                          height: calculatedHeight > 2 ? calculatedHeight : 2,
                          decoration: BoxDecoration(
                            color: val > 0 ? AppColors.primary : Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weeklyLabels[index],
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
