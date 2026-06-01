import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../services/diyanet_service.dart';
import '../services/locale_service.dart';
import '../l10n/l10n_scope.dart';
import '../l10n/app_localizations.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String currentMezhep;
  final String currentReciter;
  final Function(String, String) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentMezhep,
    required this.currentReciter,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedMezhep;
  late String _selectedReciter;
  String _selectedCity = 'İstanbul';
  String _selectedEzan = 'Türkiye Diyanet';
  bool _globalNotif = true;
  bool _dailyVerse = true;
  bool _prayerReminder = true;
  bool _jumuaReminder = true;
  bool _isPro = false;


  static const Map<String, IconData> _mezhepIcons = {
    'Hanefi': Icons.mosque_rounded,
    'Şafi': Icons.star_rounded,
    'Maliki': Icons.brightness_5_rounded,
    'Hanbeli': Icons.menu_book_rounded,
  };


  static const List<String> _ezanSesleri = [
    'Türkiye Diyanet',
    'Mısır Usulü',
    'Mekke Ezanı',
    'Medine Ezanı',
    'Kısa Ezan',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMezhep = widget.currentMezhep;
    _selectedReciter = widget.currentReciter;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCity = prefs.getString('selected_city') ?? 'İstanbul';
      _selectedEzan = prefs.getString('selected_ezan') ?? 'Türkiye Diyanet';
      _globalNotif = prefs.getBool('global_notif') ?? true;
      _dailyVerse = prefs.getBool('daily_verse') ?? true;
      _prayerReminder = prefs.getBool('prayer_reminder') ?? true;
      _jumuaReminder = prefs.getBool('jumua_reminder') ?? true;
      _isPro = prefs.getBool('is_pro') ?? false;
    });
  }

  Future<void> _updateMezhep(String mezhep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_mezhep', mezhep);
    setState(() => _selectedMezhep = mezhep);
    widget.onSettingsChanged(_selectedMezhep, _selectedReciter);
  }

  Future<void> _updateReciter(String reciter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reciter', reciter);
    setState(() => _selectedReciter = reciter);
    widget.onSettingsChanged(_selectedMezhep, _selectedReciter);
  }

  Future<void> _updateCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', city);
    setState(() => _selectedCity = city);
  }

  Future<void> _updateEzan(String ezan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ezan', ezan);
    setState(() => _selectedEzan = ezan);
  }

  Future<void> _toggleBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _navigateToPremium() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
    if (result == true) {
      _loadPrefs();
    }
  }

  void _updateEzanSelection(String ezan) {
    final l10n = L10nScope.of(context);
    if (ezan == 'Türkiye Diyanet' || _isPro) {
      _updateEzan(ezan);
    } else {
      _showPremiumDialog(l10n.premiumEzanTitle, l10n.premiumEzanBody);
    }
  }

  void _showLanguagePicker(LocaleService localeService, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset + 8 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.selectLanguage, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Divider(height: 0.5),
              _languageOption(
                icon: Icons.language_rounded,
                label: l10n.languageTurkish,
                selected: localeService.languageCode == 'tr',
                onTap: () async {
                  await localeService.setLanguage('tr');
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const Divider(height: 0.5, indent: 56),
              _languageOption(
                icon: Icons.translate_rounded,
                label: l10n.languageArabic,
                subtitle: 'العربية',
                selected: localeService.languageCode == 'ar',
                onTap: () async {
                  await localeService.setLanguage('ar');
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon, color: AppColors.primary, size: 26),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.primaryDark : const Color(0xFF1A1A1A),
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey))
          : null,
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 26)
          : const Icon(Icons.circle_outlined, color: Color(0xFFD1D5DB), size: 26),
      onTap: onTap,
    );
  }

  void _showPremiumDialog(String featureTitle, String description) {
    final l10n = L10nScope.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                featureTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(fontSize: 13.5, color: Colors.grey, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.later, style: const TextStyle(color: Colors.grey, fontSize: 13.5)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPremium();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.goPro, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProPromoCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B27A), Color(0xFF005F41)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.proUpgrade,
                  style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.proUpgradeSubtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11.5),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToPremium,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.explore, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);
    final localeService = L10nScope.localeServiceOf(context);
    final mezheps = ['Hanefi', 'Şafi', 'Maliki', 'Hanbeli'];
    final reciters = ['Mishary Rashid', 'Abdul Rahman', 'Maher Al Muaiqly'];
    final cities = DiyanetService.majorCities.keys.toList()..sort();
    final currentLangLabel = localeService.isArabic ? l10n.languageArabic : l10n.languageTurkish;

    return Container(
      color: const Color(0xFFF2F4F3),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005F41), Color(0xFF00B27A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/images/logo.png', width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(l10n.appVersionLine, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 13),
                                  const SizedBox(width: 5),
                                  Text(l10n.geminiBadge, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11.5, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            if (_isPro) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 13),
                                    const SizedBox(width: 5),
                                    Text(l10n.pro, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (!_isPro) ...[
              _buildProPromoCard(l10n),
            ],

            _sectionTitle('🌐  ${l10n.settingsLanguage}', l10n.settingsLanguageSubtitle),
            _settingsCard([
              _buildDropdownTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF0EA5E9),
                iconBg: const Color(0xFFE0F2FE),
                title: l10n.settingsLanguage,
                value: currentLangLabel,
                onTap: () => _showLanguagePicker(localeService, l10n),
              ),
            ]),

            _sectionTitle('📍  ${l10n.sectionLocation}', l10n.sectionLocationSubtitle),
            _settingsCard([
              _buildDropdownTile(
                icon: Icons.location_city_rounded,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEFF6FF),
                title: l10n.city,
                value: _selectedCity,
                onTap: () => _showCityPicker(cities),
              ),
            ]),

            _sectionTitle('🕌  ${l10n.sectionMezhep}', l10n.sectionMezhepSubtitle),
            _settingsCard(
              mezheps.asMap().entries.map((entry) {
                final mezhep = entry.value;
                final isSelected = _selectedMezhep == mezhep;
                final isLast = entry.key == mezheps.length - 1;
                return _buildRadioTile(
                  icon: _mezhepIcons[mezhep] ?? Icons.mosque_rounded,
                  iconColor: isSelected ? Colors.white : Colors.grey,
                  iconBg: isSelected ? AppColors.primary : const Color(0xFFF3F4F6),
                  title: l10n.mezhepName(mezhep),
                  subtitle: l10n.mezhepDescription(mezhep),
                  isSelected: isSelected,
                  isLast: isLast,
                  onTap: () => _updateMezhep(mezhep),
                );
              }).toList(),
            ),

            _sectionTitle('🔊  ${l10n.sectionEzan}', l10n.sectionEzanSubtitle),
            _settingsCard(
              _ezanSesleri.asMap().entries.map((entry) {
                final ezan = entry.value;
                final isSelected = _selectedEzan == ezan;
                final isLast = entry.key == _ezanSesleri.length - 1;
                final isPremiumSound = ezan != 'Türkiye Diyanet';

                return _buildRadioTile(
                  icon: Icons.volume_up_rounded,
                  iconColor: isSelected ? Colors.white : Colors.grey,
                  iconBg: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFF3F4F6),
                  title: l10n.ezanName(ezan),
                  subtitle: isPremiumSound && !_isPro ? l10n.proEdition : '',
                  isSelected: isSelected,
                  isLast: isLast,
                  onTap: () => _updateEzanSelection(ezan),
                );
              }).toList(),
            ),

            _sectionTitle('🎙️  ${l10n.sectionReciter}', l10n.sectionReciterSubtitle),
            _settingsCard(
              reciters.asMap().entries.map((entry) {
                final reciter = entry.value;
                final isSelected = _selectedReciter == reciter;
                final isLast = entry.key == reciters.length - 1;
                return _buildRadioTile(
                  icon: Icons.mic_rounded,
                  iconColor: isSelected ? Colors.white : Colors.grey,
                  iconBg: isSelected ? const Color(0xFFEF4444) : const Color(0xFFF3F4F6),
                  title: reciter,
                  subtitle: l10n.reciterSubtitle(reciter),
                  isSelected: isSelected,
                  isLast: isLast,
                  onTap: () => _updateReciter(reciter),
                );
              }).toList(),
            ),

            _sectionTitle('🔔  ${l10n.sectionNotifications}', l10n.sectionNotificationsSubtitle),
            _settingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFF00B27A),
                iconBg: const Color(0xFFECFDF5),
                title: l10n.notifAll,
                subtitle: l10n.notifAllSubtitle,
                value: _globalNotif,
                isLast: false,
                onChanged: (v) {
                  setState(() => _globalNotif = v);
                  _toggleBool('global_notif', v);
                },
              ),
              _buildSwitchTile(
                icon: Icons.wb_sunny_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFFFBEB),
                title: l10n.notifPrayer,
                subtitle: l10n.notifPrayerSubtitle,
                value: _prayerReminder && _globalNotif,
                isLast: false,
                onChanged: _globalNotif
                    ? (v) {
                        setState(() => _prayerReminder = v);
                        _toggleBool('prayer_reminder', v);
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEFF6FF),
                title: l10n.notifDaily,
                subtitle: l10n.notifDailySubtitle,
                value: _dailyVerse && _globalNotif,
                isLast: false,
                onChanged: _globalNotif
                    ? (v) {
                        setState(() => _dailyVerse = v);
                        _toggleBool('daily_verse', v);
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.mosque_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF5F3FF),
                title: l10n.notifFriday,
                subtitle: l10n.notifFridaySubtitle,
                value: _jumuaReminder && _globalNotif,
                isLast: true,
                onChanged: _globalNotif
                    ? (v) {
                        setState(() => _jumuaReminder = v);
                        _toggleBool('jumua_reminder', v);
                      }
                    : null,
              ),
            ]),

            _sectionTitle('ℹ️  ${l10n.sectionAbout}', ''),
            _settingsCard([
              _buildInfoTile(icon: Icons.info_outline_rounded, iconColor: const Color(0xFF6B7280), title: l10n.version, trailing: 'v1.0.0', isLast: false),
              _buildInfoTile(icon: Icons.gavel_rounded, iconColor: const Color(0xFF6B7280), title: l10n.terms, trailing: '', isLast: false, showArrow: true),
              _buildInfoTile(icon: Icons.privacy_tip_outlined, iconColor: const Color(0xFF6B7280), title: l10n.privacy, trailing: '', isLast: false, showArrow: true),
              _buildInfoTile(icon: Icons.star_rounded, iconColor: const Color(0xFFF59E0B), title: l10n.rateApp, trailing: '', isLast: false, showArrow: true),
              _buildInfoTile(icon: Icons.mail_outline_rounded, iconColor: const Color(0xFF3B82F6), title: l10n.feedback, trailing: '', isLast: true, showArrow: true),
            ]),

            // ─── Feragatname ────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFD97706), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.disclaimer,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Yardımcı widget'lar ─────────────────────────────────────────────────

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRadioTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.transparent,
              borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primaryDark : const Color(0xFF1A1A1A))),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: 2),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 0.5, thickness: 0.5, indent: 66, endIndent: 16),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required bool isLast,
    required ValueChanged<bool>? onChanged,
  }) {
    final disabled = onChanged == null;
    return Column(
      children: [
        Opacity(
          opacity: disabled ? 0.45 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                      Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 0.5, thickness: 0.5, indent: 66, endIndent: 16),
      ],
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)))),
            Text(value, style: const TextStyle(fontSize: 13.5, color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailing,
    required bool isLast,
    bool showArrow = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: showArrow ? () {} : null,
          borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 14),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)))),
                if (trailing.isNotEmpty) Text(trailing, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                if (showArrow) const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 0.5, thickness: 0.5, indent: 50, endIndent: 16),
      ],
    );
  }

  void _showCityPicker(List<String> cities) {
    final l10n = L10nScope.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(l10n.selectCity, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Divider(height: 0.5),
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 16),
                  itemBuilder: (context, i) {
                    final city = cities[i];
                    final isSelected = city == _selectedCity;
                    return ListTile(
                      leading: Icon(Icons.location_on_rounded, color: isSelected ? AppColors.primary : Colors.grey, size: 20),
                      title: Text(city, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primaryDark : const Color(0xFF1A1A1A))),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20) : null,
                      onTap: () {
                        _updateCity(city);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
