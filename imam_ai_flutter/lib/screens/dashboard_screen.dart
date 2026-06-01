import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/prayer_time_info.dart';
import '../l10n/l10n_scope.dart';

class DashboardScreen extends StatelessWidget {
  final ValueNotifier<PrayerTimeInfo> prayerTimeNotifier;
  final Function(int) onMenuTap;

  const DashboardScreen({
    super.key,
    required this.prayerTimeNotifier,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF008B5D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ValueListenableBuilder<PrayerTimeInfo>(
                    valueListenable: prayerTimeNotifier,
                    builder: (context, info, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.nextPrayerTime,
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Color(0xC0FFFFFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            info.name.isEmpty ? l10n.loading : info.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            info.time.isEmpty ? '' : '${info.time} · ${info.countdown}',
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Color(0xCCFFFFFF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x2EFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.today, style: const TextStyle(fontSize: 11.0, color: Colors.white)),
                      const Text('5', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                      Text(l10n.prayerCountUnit, style: const TextStyle(fontSize: 11.0, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(l10n.sectionWorship),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(context, Icons.access_time_outlined, l10n.menuPrayerTimes, () => onMenuTap(1)),
              _buildMenuCard(context, Icons.menu_book_outlined, l10n.menuListenQuran, () => onMenuTap(2)),
              _buildMenuCard(context, Icons.explore_outlined, l10n.menuQibla, () => onMenuTap(4)),
              _buildMenuCard(context, Icons.opacity_outlined, l10n.menuAblution, () => onMenuTap(7)),
              _buildMenuCard(context, Icons.nightlight_round_outlined, l10n.menuFasting, () => onMenuTap(6)),
              _buildMenuCard(context, Icons.radar_outlined, l10n.menuDhikr, () => onMenuTap(8)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(l10n.sectionDaily),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(context, Icons.share_outlined, l10n.menuDailyShare, () => onMenuTap(9)),
              _buildMenuCard(context, Icons.check_box_outlined, l10n.menuTracker, () => onMenuTap(10)),
              _buildMenuCard(context, Icons.mic_none_outlined, l10n.menuMemorize, () => onMenuTap(11)),
              _buildMenuCard(context, Icons.calculate_outlined, l10n.menuZakat, () => onMenuTap(13)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(l10n.sectionServices),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(context, Icons.place_outlined, l10n.menuMosques, () => onMenuTap(12)),
              _buildMenuCard(context, Icons.chat_bubble_outline_outlined, l10n.menuChat, () => onMenuTap(3)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder.withOpacity(0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
