import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/l10n_scope.dart';

class OrucScreen extends StatelessWidget {
  final Function(String) onNavigateToChat;

  const OrucScreen({
    super.key,
    required this.onNavigateToChat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 8),
        _buildInfoCard(
          icon: Icons.access_time,
          title: l10n.suhurTitle,
          description: l10n.suhurDesc,
          badgeText: l10n.hanefiShafi,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.wb_twilight_outlined,
          title: l10n.iftarTitle,
          description: l10n.iftarDesc,
          badgeText: l10n.allMezheps,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          icon: Icons.error_outline,
          title: l10n.fastingBreakers,
          description: l10n.fastingBreakersDesc,
          badgeText: l10n.chatForDetails,
          isChatBadge: true,
          onTap: () => onNavigateToChat(l10n.qFasting),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required String badgeText,
    bool isChatBadge = false,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isChatBadge ? AppColors.surface2 : const Color(0xFFDCF5EC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
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
