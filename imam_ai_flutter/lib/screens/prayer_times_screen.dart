import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../services/diyanet_service.dart';
import '../services/notification_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  final String selectedCity;
  final String selectedMezhep;
  final Function(String nextPrayer, String time, String countdown) onTimeUpdate;

  const PrayerTimesScreen({
    super.key,
    required this.selectedCity,
    required this.selectedMezhep,
    required this.onTimeUpdate,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  final DiyanetService _diyanetService = DiyanetService();
  final NotificationService _notificationService = NotificationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, String> _rawTimes = {};
  Map<String, String> _adjustedTimes = {};
  bool _isLoading = true;
  Timer? _countdownTimer;

  // Geri sayım için state
  String _nextPrayerKey = '';
  final ValueNotifier<String> _countdownNotifier = ValueNotifier<String>('-- : --');

  final Map<String, bool> _notificationsEnabled = {
    'imsak': false,
    'gunes': false,
    'ogle': false,
    'ikindi': false,
    'aksam': false,
    'yatsi': false,
  };

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    _fetchTimes();
    _startCountdownTimer();
    _animCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant PrayerTimesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCity != widget.selectedCity ||
        oldWidget.selectedMezhep != widget.selectedMezhep) {
      _fetchTimes();
    }
  }

  Future<void> _fetchTimes() async {
    setState(() => _isLoading = true);
    final districtCode = DiyanetService.majorCities[widget.selectedCity] ?? '9798';
    final times = await _diyanetService.getPrayerTimes(districtCode);
    if (mounted) {
      setState(() {
        _rawTimes = times;
        _adjustedTimes = _diyanetService.adjustForMezhep(_rawTimes, widget.selectedMezhep);
        _isLoading = false;
      });
      _updateCountdown();
      _loadAndScheduleNotifications();
    }
  }

  Future<void> _loadAndScheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final sortedKeys = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];
    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final enabled = prefs.getBool('notif_$key') ?? false;
      if (mounted) {
        setState(() {
          _notificationsEnabled[key] = enabled;
        });
      }
      if (enabled && _adjustedTimes.containsKey(key)) {
        final timeStr = _adjustedTimes[key]!;
        final prayerTime = _parseTimeToToday(timeStr);
        await _notificationService.schedulePrayerNotification(
          id: i,
          prayerName: _getTurkishName(key),
          time: prayerTime,
        );
      }
    }
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _adjustedTimes.isNotEmpty) _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_adjustedTimes.isEmpty) return;
    final now = DateTime.now();
    final sorted = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];
    String nextKey = 'imsak';
    DateTime nextTime = DateTime.now();
    bool isNextDay = true;
    for (var prayer in sorted) {
      final timeStr = _adjustedTimes[prayer]!;
      final prayerTime = _parseTimeToToday(timeStr);
      if (now.isBefore(prayerTime)) {
        nextKey = prayer;
        nextTime = prayerTime;
        isNextDay = false;
        break;
      }
    }
    if (isNextDay) {
      final parts = _adjustedTimes['imsak']!.split(':');
      nextTime = DateTime(now.year, now.month, now.day + 1, int.parse(parts[0]), int.parse(parts[1]));
      nextKey = 'imsak';
    }
    final diff = nextTime.difference(now);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    final countStr = '$h:$m:$s';

    _countdownNotifier.value = countStr;
    if (_nextPrayerKey != nextKey) {
      setState(() {
        _nextPrayerKey = nextKey;
      });
    }

    final nextName = _getTurkishName(nextKey);
    final nextTimeStr = _adjustedTimes[nextKey] ?? '';
    widget.onTimeUpdate(nextName, nextTimeStr, countStr);
  }

  DateTime _parseTimeToToday(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _getTurkishName(String key) {
    switch (key) {
      case 'imsak': return 'İmsak';
      case 'gunes': return 'Güneş';
      case 'ogle': return 'Öğle';
      case 'ikindi': return 'İkindi';
      case 'aksam': return 'Akşam';
      case 'yatsi': return 'Yatsı';
      default: return '';
    }
  }

  bool _isPrayerActive(String key) {
    if (_adjustedTimes.isEmpty) return false;
    final now = DateTime.now();
    final sorted = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];
    int current = -1;
    for (int i = 0; i < sorted.length; i++) {
      final t = _parseTimeToToday(_adjustedTimes[sorted[i]]!);
      if (now.isAfter(t)) current = i;
    }
    if (current == -1) return key == 'yatsi';
    return sorted[current] == key;
  }

  IconData _getPrayerIcon(String key) {
    switch (key) {
      case 'imsak': return Icons.nights_stay_rounded;
      case 'gunes': return Icons.wb_sunny_rounded;
      case 'ogle': return Icons.light_mode_rounded;
      case 'ikindi': return Icons.wb_sunny_rounded;
      case 'aksam': return Icons.wb_twilight_rounded;
      case 'yatsi': return Icons.brightness_3_rounded;
      default: return Icons.access_time;
    }
  }

  Color _getPrayerIconColor(String key) {
    switch (key) {
      case 'imsak':
      case 'yatsi':
        return const Color(0xFF7C6AF7);
      case 'gunes':
      case 'ogle':
      case 'ikindi':
        return const Color(0xFFF59E0B);
      case 'aksam':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  Future<void> _playEzan() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/ezan.mp3');
      _audioPlayer.play();
    } catch (_) {}
  }

  void _toggleNotification(String key) async {
    final enabled = _notificationsEnabled[key] ?? false;
    setState(() => _notificationsEnabled[key] = !enabled);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_$key', !enabled);

    final index = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'].indexOf(key);
    if (!enabled) {
      final timeStr = _adjustedTimes[key]!;
      final prayerTime = _parseTimeToToday(timeStr);
      await _notificationService.schedulePrayerNotification(
        id: index,
        prayerName: _getTurkishName(key),
        time: prayerTime,
      );
      await _playEzan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_getTurkishName(key)} vakti için ezan bildirimi kuruldu 🕌'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } else {
      await _notificationService.cancelNotification(index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_getTurkishName(key)} vakti bildirimi iptal edildi 🔕'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animCtrl.dispose();
    _audioPlayer.dispose();
    _countdownNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final sortedKeys = ['imsak', 'gunes', 'ogle', 'ikindi', 'aksam', 'yatsi'];
    final nextName = _getTurkishName(_nextPrayerKey);

    return Container(
      color: const Color(0xFFF2F4F3),
      child: FadeTransition(
        opacity: _animCtrl,
        child: Column(
          children: [
            // ─── Üst banner: Sonraki namaza kalan süre ───────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005F41), Color(0xFF00B27A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sol: metin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sonraki vakit',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextName.isEmpty ? '--' : nextName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            ValueListenableBuilder<String>(
                              valueListenable: _countdownNotifier,
                              builder: (context, countdown, child) {
                                return Text(
                                  countdown,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Sağ: büyük cami ikonu
                  const Icon(Icons.mosque_rounded, color: Colors.white24, size: 72),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ─── Mezhep + Kaynak etiketleri ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _chip(widget.selectedMezhep, const Color(0xFFD1FAE5), AppColors.primaryDark),
                  const SizedBox(width: 8),
                  _chip('Diyanet API', const Color(0xFFFEF3E2), const Color(0xFF7A4A00)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ─── Namaz vakitleri listesi ──────────────────────────────────
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedKeys[index];
                  final isActive = _isPrayerActive(key);
                  final isNext = key == _nextPrayerKey && !isActive;
                  final notifEnabled = _notificationsEnabled[key] ?? false;
                  final name = _getTurkishName(key);
                  final time = _adjustedTimes[key] ?? '--:--';
                  final icon = _getPrayerIcon(key);
                  final iconColor = _getPrayerIconColor(key);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isNext
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.35)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // İkon kutusu
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white.withOpacity(0.2)
                                  : iconColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: isActive ? Colors.white : iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // İsim
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              if (isNext)
                                Text(
                                  'Sıradaki vakit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (isActive)
                                Text(
                                  'Şu anki vakit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          // Bildirim butonu
                          GestureDetector(
                            onTap: () => _toggleNotification(key),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: notifEnabled
                                    ? (isActive ? Colors.white.withOpacity(0.25) : AppColors.primary.withOpacity(0.1))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                notifEnabled ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                color: notifEnabled
                                    ? (isActive ? Colors.white : AppColors.primary)
                                    : (isActive ? Colors.white54 : Colors.grey.shade400),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Saat
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : const Color(0xFF1A1A1A),
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.15), width: 1),
      ),
      child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
    );
  }
}
