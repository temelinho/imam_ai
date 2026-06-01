import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../l10n/l10n_scope.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';
import '../location/location_scope.dart';
import '../services/location_service.dart';
import '../models/prayer_time_info.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/lazy_load_widget.dart';
import '../services/diyanet_service.dart';
import 'dashboard_screen.dart';
import 'prayer_times_screen.dart';
import 'quran_screen.dart';
import 'chat_screen.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';
import 'oruc_screen.dart';
import 'abdest_screen.dart';
import 'zikirmatik_screen.dart';
import 'daily_share_screen.dart';
import 'tracker_screen.dart';
import 'ezber_screen.dart';
import 'camiler_screen.dart';
import 'zekat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Global app settings state
  String _selectedCity = 'Malatya';
  String _selectedMezhep = 'Hanefi';
  String _selectedReciter = 'Mishary Rashid';

  // ValueNotifier for countdown info shared between dashboard and prayer screen
  final ValueNotifier<PrayerTimeInfo> _prayerTimeNotifier = ValueNotifier<PrayerTimeInfo>(
    const PrayerTimeInfo(name: '', time: '', countdown: ''),
  );

  // Initial prompt for chat screen (when coming from other guides)
  String? _initialChatPrompt;

  // Keys for communicating with child screen states
  final GlobalKey<State<QuranScreen>> _quranKey = GlobalKey<State<QuranScreen>>();
  final GlobalKey<State<ChatScreen>> _chatKey = GlobalKey<State<ChatScreen>>();
  final GlobalKey<State<CamilerScreen>> _camilerKey = GlobalKey<State<CamilerScreen>>();
  final GlobalKey<ZikirmatikScreenState> _zikirmatikKey = GlobalKey<ZikirmatikScreenState>();

  LocationService? _locationService;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = LocationScope.of(context);
    if (_locationService != loc) {
      _locationService?.removeListener(_syncCityFromLocation);
      _locationService = loc;
      _locationService!.addListener(_syncCityFromLocation);
      _syncCityFromLocation();
    }
  }

  @override
  void dispose() {
    _locationService?.removeListener(_syncCityFromLocation);
    super.dispose();
  }

  void _syncCityFromLocation() {
    final loc = _locationService;
    if (loc == null || !loc.fromGps) return;
    final city = loc.nearestCity;
    if (city != null && city != _selectedCity && mounted) {
      _updateCity(city, showSnack: true);
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCity = prefs.getString('selected_city') ?? 'Malatya';
      _selectedMezhep = prefs.getString('selected_mezhep') ?? 'Hanefi';
      _selectedReciter = prefs.getString('selected_reciter') ?? 'Mishary Rashid';
    });
  }

  Future<void> _updateCity(String city, {bool showSnack = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', city);
    if (!mounted) return;
    setState(() => _selectedCity = city);
    if (showSnack) {
      final l10n = L10nScope.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.locationAutoCity}: $city'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onSettingsChanged(String mezhep, String reciter) {
    setState(() {
      _selectedMezhep = mezhep;
      _selectedReciter = reciter;
    });
  }

  void _onNavigateToChat(String initialPrompt) {
    setState(() {
      _initialChatPrompt = initialPrompt;
      _currentIndex = 3; // Switch to Dini Sohbet
    });
  }

  void _onClearInitialPrompt() {
    setState(() {
      _initialChatPrompt = null;
    });
  }

  List<BottomNavItem> _getBottomNavItems(AppLocalizations l10n) {
    if (_currentIndex == 7) {
      return [
        BottomNavItem(label: l10n.navHome, icon: Icons.home_outlined, screenIndex: 0),
        BottomNavItem(label: l10n.navPrayer, icon: Icons.access_time_outlined, screenIndex: 1),
        BottomNavItem(label: l10n.navAblution, icon: Icons.opacity_outlined, screenIndex: 7),
        BottomNavItem(label: l10n.navAssistant, icon: Icons.auto_awesome, screenIndex: 3),
        BottomNavItem(label: l10n.navQibla, icon: Icons.explore_outlined, screenIndex: 4),
      ];
    }
    return [
      BottomNavItem(label: l10n.navHome, icon: Icons.home_outlined, screenIndex: 0),
      BottomNavItem(label: l10n.navPrayer, icon: Icons.access_time_outlined, screenIndex: 1),
      BottomNavItem(label: l10n.navQuran, icon: Icons.menu_book_outlined, screenIndex: 2),
      BottomNavItem(label: l10n.navAssistant, icon: Icons.auto_awesome, screenIndex: 3),
      BottomNavItem(label: l10n.navQibla, icon: Icons.explore_outlined, screenIndex: 4),
    ];
  }

  // Find active index inside the generated bottom items list
  int _getActiveBottomIndex(List<BottomNavItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].screenIndex == _currentIndex) {
        return i;
      }
    }
    // Asistan (3) sekmesini Oruç (6) ve Tracker (10) için vurgula
    if (_currentIndex == 6 || _currentIndex == 10) {
      for (int i = 0; i < items.length; i++) {
        if (items[i].screenIndex == 3) return i;
      }
    }
    // Ayarlar (5), Zikirmatik (8), Paylaşım (9), Ezber (11), Camiler (12), Zekat (13)
    // → Hiçbiri navbarda yok, Ana (0) sekmesi highlight olsun
    return 0;
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, LocaleService localeService) {
    String title = '';
    String subtitle = '';
    Widget? actionWidget;
    final mezhepLabel = l10n.mezhepName(_selectedMezhep);
    final dateStr = DateFormat(localeService.datePattern(), localeService.dateLocaleTag()).format(DateTime.now());

    switch (_currentIndex) {
      case 0:
        title = l10n.appName;
        subtitle = l10n.subtitleHome(_selectedCity, mezhepLabel);
        actionWidget = _buildAppBarAction(
          icon: Icons.settings,
          onTap: () => setState(() => _currentIndex = 5),
        );
        break;
      case 1:
        title = l10n.titlePrayerTimes;
        subtitle = l10n.subtitlePrayerDate(dateStr, _selectedCity);
        actionWidget = PopupMenuButton<String>(
          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.location_on, color: Colors.white, size: 16),
          ),
          onSelected: (city) => _updateCity(city),
          itemBuilder: (context) {
            return DiyanetService.majorCities.keys.map((city) {
              return PopupMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList();
          },
        );
        break;
      case 2:
        title = l10n.titleQuran;
        subtitle = l10n.subtitleQuran;
        actionWidget = _buildAppBarAction(
          icon: Icons.search,
          onTap: () {
            final quranState = _quranKey.currentState;
            if (quranState != null) {
              (quranState as dynamic).toggleSearch();
            }
          },
        );
        break;
      case 3:
        title = l10n.appName;
        subtitle = '$mezhepLabel · ${l10n.subtitleChat}';
        actionWidget = _buildAppBarAction(
          icon: Icons.refresh,
          onTap: () {
            try {
              // ignore: invalid_use_of_protected_member
              (_chatKey.currentState as dynamic)?.clearChat();
            } catch (e) {
              // Fail-safe
            }
          },
        );
        break;
      case 4:
        title = l10n.titleQibla;
        subtitle = l10n.subtitleQibla;
        actionWidget = _buildAppBarAction(
          icon: Icons.my_location,
          onTap: () => LocationScope.of(context).refresh(),
        );
        break;
      case 5:
        title = l10n.titleSettings;
        subtitle = l10n.subtitleSettings;
        actionWidget = _buildAppBarAction(
          icon: Icons.tune,
          onTap: () {},
        );
        break;
      case 6:
        title = l10n.titleFasting;
        subtitle = l10n.subtitleFasting;
        actionWidget = _buildAppBarAction(
          icon: Icons.nightlight_round,
          onTap: () {},
        );
        break;
      case 7:
        title = l10n.titleAblution;
        subtitle = l10n.subtitleAblution;
        actionWidget = _buildAppBarAction(
          icon: Icons.opacity,
          onTap: () {},
        );
        break;
      case 8:
        title = l10n.titleDhikr;
        subtitle = l10n.subtitleDhikr;
        actionWidget = _buildAppBarAction(
          icon: Icons.restore,
          onTap: () {
            _zikirmatikKey.currentState?.resetCounter();
          },
        );
        break;
      case 9:
        title = l10n.titleDailyShare;
        subtitle = l10n.subtitleDailyShare;
        actionWidget = _buildAppBarAction(
          icon: Icons.share,
          onTap: () {},
        );
        break;
      case 10:
        title = l10n.titleTracker;
        subtitle = l10n.subtitleTracker;
        actionWidget = _buildAppBarAction(
          icon: Icons.analytics_outlined,
          onTap: () {},
        );
        break;
      case 11:
        title = l10n.titleMemorize;
        subtitle = l10n.subtitleMemorize;
        actionWidget = _buildAppBarAction(
          icon: Icons.record_voice_over,
          onTap: () {},
        );
        break;
      case 12:
        title = l10n.titleMosques;
        subtitle = l10n.subtitleMosques;
        actionWidget = _buildAppBarAction(
          icon: Icons.my_location,
          onTap: () => LocationScope.of(context).refresh(),
        );
        break;
      case 13:
        title = l10n.titleZakat;
        subtitle = l10n.subtitleZakat;
        actionWidget = _buildAppBarAction(
          icon: Icons.calculate,
          onTap: () {},
        );
        break;
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title == l10n.appName) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.70),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: actionWidget != null ? [actionWidget] : null,
    );
  }

  Widget _buildAppBarAction({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);
    final localeService = L10nScope.localeServiceOf(context);
    final bottomNavItems = _getBottomNavItems(l10n);
    final activeBottomIndex = _getActiveBottomIndex(bottomNavItems);

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        setState(() {
          _currentIndex = 0;
        });
      },
      child: Scaffold(
        appBar: _buildAppBar(l10n, localeService),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Index 0: Ana (Dashboard)
            LazyLoadWidget(
              isActivated: _currentIndex == 0,
              builder: (context) => DashboardScreen(
                prayerTimeNotifier: _prayerTimeNotifier,
                onMenuTap: (index) => setState(() => _currentIndex = index),
              ),
            ),
            // Index 1: Vakit
            LazyLoadWidget(
              isActivated: _currentIndex == 1,
              builder: (context) => PrayerTimesScreen(
                selectedCity: _selectedCity,
                selectedMezhep: _selectedMezhep,
                onTimeUpdate: (name, time, count) {
                  _prayerTimeNotifier.value = PrayerTimeInfo(name: name, time: time, countdown: count);
                },
              ),
            ),
            // Index 2: Kuran
            LazyLoadWidget(
              isActivated: _currentIndex == 2,
              builder: (context) => QuranScreen(
                key: _quranKey,
                selectedReciter: _selectedReciter,
              ),
            ),
            // Index 3: Sohbet
            LazyLoadWidget(
              isActivated: _currentIndex == 3,
              builder: (context) => ChatScreen(
                key: _chatKey,
                selectedMezhep: _selectedMezhep,
                initialPrompt: _initialChatPrompt,
                onClearInitialPrompt: _onClearInitialPrompt,
              ),
            ),
            // Index 4: Kıble
            LazyLoadWidget(
              isActivated: _currentIndex == 4,
              builder: (context) => QiblaScreen(
                selectedCity: _selectedCity,
              ),
            ),
            // Index 5: Ayarlar (Mezhep Seçimi)
            LazyLoadWidget(
              isActivated: _currentIndex == 5,
              builder: (context) => SettingsScreen(
                currentMezhep: _selectedMezhep,
                currentReciter: _selectedReciter,
                onSettingsChanged: _onSettingsChanged,
              ),
            ),
            // Index 6: Oruç Bilgisi
            LazyLoadWidget(
              isActivated: _currentIndex == 6,
              builder: (context) => OrucScreen(
                onNavigateToChat: _onNavigateToChat,
              ),
            ),
            // Index 7: Abdest Rehberi
            LazyLoadWidget(
              isActivated: _currentIndex == 7,
              builder: (context) => AbdestScreen(
                selectedMezhep: _selectedMezhep,
              ),
            ),
            // Index 8: Zikirmatik (Sayaç)
            LazyLoadWidget(
              isActivated: _currentIndex == 8,
              builder: (context) => ZikirmatikScreen(
                key: _zikirmatikKey,
              ),
            ),
            // Index 9: Günlük Paylaşım (Ayet/Hadis)
            LazyLoadWidget(
              isActivated: _currentIndex == 9,
              builder: (context) => const DailyShareScreen(),
            ),
            // Index 10: İbadet Takipçisi
            LazyLoadWidget(
              isActivated: _currentIndex == 10,
              builder: (context) => TrackerScreen(
                onNavigateToChat: _onNavigateToChat,
              ),
            ),
            // Index 11: Sesli Ezber
            LazyLoadWidget(
              isActivated: _currentIndex == 11,
              builder: (context) => const EzberScreen(),
            ),
            // Index 12: Yakın Camiler
            LazyLoadWidget(
              isActivated: _currentIndex == 12,
              builder: (context) => CamilerScreen(
                key: _camilerKey,
                selectedCity: _selectedCity,
              ),
            ),
            // Index 13: Zekat Hesaplayıcı
            LazyLoadWidget(
              isActivated: _currentIndex == 13,
              builder: (context) => const ZekatScreen(),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          items: bottomNavItems,
          activeIndex: activeBottomIndex,
          onTap: (screenIdx) {
            setState(() {
              _currentIndex = screenIdx;
            });
          },
        ),
      ),
    );
  }
}

// Interface to allow clearing chat safely
abstract class ChatScreenStateExt {
  void clearChat();
}
