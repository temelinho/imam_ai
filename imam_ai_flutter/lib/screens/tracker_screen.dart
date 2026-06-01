import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';

class TrackerScreen extends StatefulWidget {
  final Function(String) onNavigateToChat;

  const TrackerScreen({
    super.key,
    required this.onNavigateToChat,
  });

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<String> _tasks = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı', 'Kuran Okuma'];
  final List<String> _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  // Cache dates of the current week (Monday to Sunday)
  late List<DateTime> _weekDates;
  final Map<String, bool> _trackerData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateWeekDates();
    _loadTrackerData();
  }

  void _calculateWeekDates() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 (Mon) to 7 (Sun)
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    
    _weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Future<void> _loadTrackerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
      _trackerData.clear();
      
      for (var date in _weekDates) {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        for (var task in _tasks) {
          final key = 'tracker_${dateStr}_$task';
          _trackerData[key] = prefs.getBool(key) ?? false;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _toggleTrack(String dateStr, String task, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final currentVal = _trackerData[key] ?? false;
    final newVal = !currentVal;
    
    await prefs.setBool(key, newVal);
    setState(() {
      _trackerData[key] = newVal;
    });
  }

  double _calculateCompletionRate() {
    int totalCount = _weekDates.length * _tasks.length;
    int checkedCount = 0;
    _trackerData.forEach((key, val) {
      if (val) checkedCount++;
    });
    return totalCount > 0 ? (checkedCount / totalCount) : 0.0;
  }

  int _getTaskCompletionCount(String task) {
    int count = 0;
    for (var date in _weekDates) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final key = 'tracker_${dateStr}_$task';
      if (_trackerData[key] == true) count++;
    }
    return count;
  }

  void _generateAIReport() {
    final totalPercent = (_calculateCompletionRate() * 100).toStringAsFixed(0);
    
    // Find most missed task
    String mostMissed = '';
    int lowestCount = 8;
    for (var task in _tasks) {
      final completed = _getTaskCompletionCount(task);
      if (completed < lowestCount) {
        lowestCount = completed;
        mostMissed = task;
      }
    }

    String reportMessage = 'Bu hafta ibadet takip listenizin tamamlama oranı %$totalPercent. ';
    if (lowestCount < 4 && mostMissed.isNotEmpty) {
      reportMessage += 'Özellikle "$mostMissed" ibadetinizde bazı aksamalar olmuş görünüyor. ';
    } else {
      reportMessage += 'İbadetlerinize gösterdiğiniz özen harika! ';
    }
    reportMessage += 'AI Asistanı olarak ibadetlerinizi daha düzenli kılabilmeniz için motivasyonel fıkhi öneriler sunmak isterim.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Text('🕌 ', style: TextStyle(fontSize: 22)),
              Text(
                'Haftalık AI Değerlendirmesi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reportMessage,
                style: const TextStyle(fontSize: 14.0, height: 1.45, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Haftalık Başarı Skoru: %$totalPercent',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Send feedback to Chat screen
                final prompt = 'Bu hafta ibadet tamamlama oranım %$totalPercent. En çok aksattığım ibadet ise "$mostMissed" oldu ($lowestCount/7 gün kıldım). Bana bu konuda fıkhi motivasyonel tavsiyelerde bulunup sabah/ikindi namazlarının faziletlerini yazar mısın?';
                widget.onNavigateToChat(prompt);
              },
              child: const Text(
                'AI ile Detaylı Görüş',
                style: TextStyle(fontSize: 14.5, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Kapat',
                style: TextStyle(fontSize: 14.5, color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          const Text(
            'Bu Haftaki İbadetlerinizi Takip Edin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          // Scrollable Weekly Habit Board Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Column(
              children: [
                // Day Column Headers
                Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'İbadet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(7, (index) {
                      return Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            _dayNames[index],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.separator, height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                // Task Rows
                ..._tasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              task,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(7, (dayIdx) {
                          final date = _weekDates[dayIdx];
                          final dateStr = DateFormat('yyyy-MM-dd').format(date);
                          final key = 'tracker_${dateStr}_$task';
                          final isChecked = _trackerData[key] ?? false;
                          
                          return Expanded(
                            flex: 1,
                            child: Center(
                              child: GestureDetector(
                                onTap: () => _toggleTrack(dateStr, task, key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isChecked ? AppColors.primary : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isChecked ? Colors.transparent : AppColors.cardBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isChecked
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // AI Report Request Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('📊 ', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Haftalık İbadet Analizi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'İbadetlerinizi analiz ederek size özel manevi tavsiyeler alın.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _generateAIReport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AI Raporu Al',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
