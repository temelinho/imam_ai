import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/prayer_time_info.dart';

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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Prayer Countdown Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF008B5D),
                ],
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
                // Left Column
                Expanded(
                  child: ValueListenableBuilder<PrayerTimeInfo>(
                    valueListenable: prayerTimeNotifier,
                    builder: (context, info, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sonraki namaz vakti',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Color(0xC0FFFFFF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            info.name.isEmpty ? 'Yükleniyor...' : info.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            info.time.isEmpty
                                ? ''
                                : '${info.time} · ${info.countdown}',
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
                // Right Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x2EFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bugün',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '5',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'vakit',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SECTION 1: Temel İbadetler & Rehberler
          _buildSectionHeader('TEMEL İBADETLER & REHBERLER'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(
                icon: Icons.access_time_outlined,
                label: 'Namaz vakitleri',
                onTap: () => onMenuTap(1),
              ),
              _buildMenuCard(
                icon: Icons.menu_book_outlined,
                label: 'Kuran dinle',
                onTap: () => onMenuTap(2),
              ),
              _buildMenuCard(
                icon: Icons.explore_outlined,
                label: 'Kıble yönü',
                onTap: () => onMenuTap(4),
              ),
              _buildMenuCard(
                icon: Icons.opacity_outlined,
                label: 'Abdest rehberi',
                onTap: () => onMenuTap(7),
              ),
              _buildMenuCard(
                icon: Icons.nightlight_round_outlined,
                label: 'Oruç bilgisi',
                onTap: () => onMenuTap(6),
              ),
              _buildMenuCard(
                icon: Icons.radar_outlined,
                label: 'Zikirmatik (Sayaç)',
                onTap: () => onMenuTap(8),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SECTION 2: Günlük Araçlar & Takip
          _buildSectionHeader('GÜNLÜK ARAÇLAR & TAKİP'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(
                icon: Icons.share_outlined,
                label: 'Günün Paylaşımı',
                onTap: () => onMenuTap(9),
              ),
              _buildMenuCard(
                icon: Icons.check_box_outlined,
                label: 'İbadet Takipçisi',
                onTap: () => onMenuTap(10),
              ),
              _buildMenuCard(
                icon: Icons.mic_none_outlined,
                label: 'Sesli Ezber',
                onTap: () => onMenuTap(11),
              ),
              _buildMenuCard(
                icon: Icons.calculate_outlined,
                label: 'Zekat Hesaplayıcı',
                onTap: () => onMenuTap(13),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SECTION 3: Yardımcı Hizmetler
          _buildSectionHeader('YARDIMCI HİZMETLER'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuCard(
                icon: Icons.place_outlined,
                label: 'Yakın Camiler',
                onTap: () => onMenuTap(12),
              ),
              _buildMenuCard(
                icon: Icons.chat_bubble_outline_outlined,
                label: 'Dini Sohbet (AI)',
                onTap: () => onMenuTap(3),
              ),
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

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
              child: Icon(
                icon,
                size: 28,
                color: AppColors.primary,
              ),
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
