import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BottomNavItem {
  final String label;
  final IconData icon;
  final int screenIndex;

  const BottomNavItem({required this.label, required this.icon, required this.screenIndex});
}

class CustomBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({super.key, required this.items, required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF008F62), Color(0xFF00B27A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x5500B27A), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(item.screenIndex),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: 48,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white.withOpacity(0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          // Aktif: tam beyaz. Pasif: %70 beyaz - ikisi de yeşil üzerinde gözükür
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
                          size: isActive ? 24 : 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
