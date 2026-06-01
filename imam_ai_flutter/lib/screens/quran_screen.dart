import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/surah_list.dart';
import '../models/surah.dart';
import '../services/quran_playback.dart';
import '../services/quran_audio_handler.dart';
import 'quran_reader_screen.dart';
import 'quran_now_playing_screen.dart';

class QuranScreen extends StatefulWidget {
  final String selectedReciter;

  const QuranScreen({
    super.key,
    required this.selectedReciter,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  QuranAudioHandler? _handler;
  bool _playbackReady = false;
  Surah? _currentSurah;
  bool _isPlaying = false;
  bool _showSearch = false;
  int _selectedTab = 0;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _lastPositionSecond = -1;

  List<Surah> _filteredSurahs = quranSurahs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSurah = quranSurahs.first;
    _preparePlayback();
  }

  Future<void> _preparePlayback() async {
    try {
      final handler = await QuranPlayback.ensureInit();
      if (!mounted) return;
      setState(() {
        _handler = handler;
        _playbackReady = true;
        _currentSurah = handler.currentSurah ?? quranSurahs.first;
      });
      _initAudioListeners();
    } catch (_) {
      if (mounted) setState(() => _playbackReady = false);
    }
  }

  @override
  void didUpdateWidget(covariant QuranScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedReciter != widget.selectedReciter && _handler != null) {
      _handler!.setReciter(widget.selectedReciter);
    }
  }

  void _initAudioListeners() {
    final handler = _handler;
    if (handler == null) return;

    handler.player.positionStream.listen((pos) {
      if (!mounted) return;
      if (pos.inSeconds == _lastPositionSecond) return;
      _lastPositionSecond = pos.inSeconds;
      setState(() => _position = pos);
    });

    handler.player.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });

    handler.player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _currentSurah = handler.currentSurah ?? _currentSurah;
      });
    });
  }

  Future<void> _playSurah(Surah surah) async {
    final handler = _handler ?? await QuranPlayback.ensureInit();
    if (!mounted) return;
    setState(() {
      _handler = handler;
      _playbackReady = true;
      _currentSurah = surah;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await handler.playSurah(surah.number, widget.selectedReciter);
  }

  void _openNowPlaying(Surah surah, {bool autoPlay = true}) {
    setState(() => _currentSurah = surah);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        pageBuilder: (_, __, ___) => QuranNowPlayingScreen(
          initialSurah: surah,
          selectedReciter: widget.selectedReciter,
          autoPlay: autoPlay,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    final handler = _handler;
    if (handler == null) return;
    if (_isPlaying) {
      await handler.pause();
    } else if (handler.player.processingState == ProcessingState.idle) {
      await _playSurah(_currentSurah ?? quranSurahs.first);
    } else {
      await handler.play();
    }
  }

  Future<void> _playNext() async {
    final handler = _handler;
    if (handler == null) return;
    await handler.skipToNext();
    if (mounted) setState(() => _currentSurah = handler.currentSurah);
  }

  Future<void> _playPrevious() async {
    final handler = _handler;
    if (handler == null) return;
    await handler.skipToPrevious();
    if (mounted) setState(() => _currentSurah = handler.currentSurah);
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = quranSurahs;
      } else {
        _filteredSurahs = quranSurahs
            .where((s) =>
                s.englishNameTranslation.toLowerCase().contains(query.toLowerCase()) ||
                s.englishName.toLowerCase().contains(query.toLowerCase()) ||
                s.number.toString() == query)
            .toList();
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabSelector(),
        _buildSearchField(),
        if (_selectedTab == 0 && _currentSurah != null && _playbackReady) _buildPlayerCard(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredSurahs.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.separator,
              height: 0.5,
              thickness: 0.5,
            ),
            itemBuilder: (context, index) {
              final surah = _filteredSurahs[index];
              final isCurrent = _currentSurah?.number == surah.number;
              final isThisPlaying = isCurrent && _isPlaying;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_selectedTab == 0) {
                            _openNowPlaying(surah);
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => QuranReaderScreen(surah: surah),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.primaryDark : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  surah.number.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.englishNameTranslation,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent ? AppColors.primaryDark : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${surah.numberOfAyahs} ayet · ${surah.revelationType == 'Meccan' ? 'Mekki' : 'Medeni'}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                surah.name,
                                style: TextStyle(
                                  fontFamily: 'ScheherazadeNew',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent ? AppColors.primaryDark : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_selectedTab == 0) {
                          _openNowPlaying(surah);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuranReaderScreen(surah: surah),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _selectedTab == 0
                              ? (isThisPlaying ? Icons.pause : Icons.play_arrow)
                              : Icons.chrome_reader_mode_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '🎧 Sesli Kur\'an',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 0 ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '📖 Yazılı Kur\'an',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 1 ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _showSearch ? 48 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: _showSearch
          ? Row(
              children: [
                const Icon(Icons.search, color: AppColors.navbarPassive, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Sure ara...',
                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: _filterSurahs,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _filterSurahs('');
                    setState(() => _showSearch = false);
                  },
                  child: const Icon(Icons.close, color: Colors.grey, size: 18),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildPlayerCard() {
    final maxMs = _duration.inMilliseconds.toDouble();
    final cap = maxMs > 0 ? maxMs : 1.0;
    final posMs = _position.inMilliseconds.toDouble().clamp(0.0, cap);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005F41), Color(0xFF00B27A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _openNowPlaying(_currentSurah!, autoPlay: false),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_currentSurah!.englishNameTranslation} Suresi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.selectedReciter,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatDuration(_position)} / ${_duration.inMilliseconds > 0 ? _formatDuration(_duration) : '--:--'} · Tam ekran için dokun',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withOpacity(0.65),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_full_rounded, color: Colors.white.withOpacity(0.7), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            ),
            child: Slider(
              value: posMs,
              max: maxMs > 0 ? maxMs : 1,
              onChanged: (val) => _handler?.seek(Duration(milliseconds: val.toInt())),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _playerControl(
                icon: Icons.skip_previous_rounded,
                size: 32,
                onTap: () {
                  _playPrevious();
                },
              ),
              _playerControl(
                icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 44,
                filled: true,
                onTap: _togglePlayPause,
              ),
              _playerControl(
                icon: Icons.skip_next_rounded,
                size: 32,
                onTap: () {
                  _playNext();
                },
              ),
              _playerControl(
                icon: Icons.open_in_full_rounded,
                size: 26,
                onTap: () => _openNowPlaying(_currentSurah!, autoPlay: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerControl({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: filled ? Colors.white : Colors.white.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: filled ? 52 : 42,
          height: filled ? 52 : 42,
          child: Icon(
            icon,
            size: size,
            color: filled ? AppColors.primaryDark : Colors.white,
          ),
        ),
      ),
    );
  }

  void toggleSearch() {
    setState(() => _showSearch = !_showSearch);
  }
}
