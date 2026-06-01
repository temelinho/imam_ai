import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/surah_list.dart';
import '../models/surah.dart';
import '../services/audio_service.dart';
import 'quran_reader_screen.dart';

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
  final QuranAudioService _audioService = QuranAudioService();
  Surah? _currentSurah;
  bool _isPlaying = false;
  bool _showSearch = false;
  int _selectedTab = 0; // 0 for Audio Quran, 1 for Written Quran

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<Surah> _filteredSurahs = quranSurahs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentSurah = quranSurahs.first; // Default to Fatihah
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _audioService.player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _audioService.player.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });

    _audioService.player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      }
    });
  }

  void _playSurah(Surah surah) {
    setState(() {
      _currentSurah = surah;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    _audioService.playSurah(surah.number, widget.selectedReciter);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.resume();
    }
  }

  void _playNext() {
    if (_currentSurah == null) return;
    int nextIndex = quranSurahs.indexWhere((s) => s.number == _currentSurah!.number) + 1;
    if (nextIndex < quranSurahs.length) {
      _playSurah(quranSurahs[nextIndex]);
    }
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
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Selector for Audio vs Reading
        _buildTabSelector(),

        // Search bar (toggled via AppBar search icon)
        _buildSearchField(),

        // Playback player card (only visible on Audio tab)
        if (_selectedTab == 0 && _currentSurah != null) _buildPlayerCard(),

        // Surah List
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
                            _playSurah(surah);
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
                              // Left 32x32 number circle
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
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
                              // Middle names
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.englishNameTranslation,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${surah.numberOfAyahs} ayet · ${surah.revelationType == 'Meccan' ? 'Mekki' : 'Medeni'}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arabic Surah name
                              Text(
                                surah.name,
                                style: const TextStyle(
                                  fontFamily: 'ScheherazadeNew',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right 32x32 action circle
                    GestureDetector(
                      onTap: () {
                        if (_selectedTab == 0) {
                          if (isCurrent) {
                            _togglePlayPause();
                          } else {
                            _playSurah(surah);
                          }
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Left music icon 24px
          const Icon(
            Icons.music_note_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentSurah!.englishNameTranslation} Suresi',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.selectedReciter} · ${_formatDuration(_position)} / ${_duration.inMilliseconds > 0 ? _formatDuration(_duration) : "0:00"}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                // Custom thin Slider progress bar
                SizedBox(
                  height: 12,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 6),
                    ),
                    child: Slider(
                      value: _position.inMilliseconds.toDouble(),
                      max: _duration.inMilliseconds.toDouble() > 0
                          ? _duration.inMilliseconds.toDouble()
                          : 1.0,
                      onChanged: (val) {
                        _audioService.seek(Duration(milliseconds: val.toInt()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right 34x34 pause circle
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
  }
}
