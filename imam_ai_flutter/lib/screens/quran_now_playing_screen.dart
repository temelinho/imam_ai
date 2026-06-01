import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/surah_list.dart';
import '../models/surah.dart';
import '../services/quran_playback.dart';
import '../services/quran_audio_handler.dart';
import 'quran_reader_screen.dart';

/// Tam ekran oynatıcı — Samsung Music benzeri koyu düzen.
class QuranNowPlayingScreen extends StatefulWidget {
  final Surah initialSurah;
  final String selectedReciter;
  final bool autoPlay;

  const QuranNowPlayingScreen({
    super.key,
    required this.initialSurah,
    required this.selectedReciter,
    this.autoPlay = true,
  });

  @override
  State<QuranNowPlayingScreen> createState() => _QuranNowPlayingScreenState();
}

class _QuranNowPlayingScreenState extends State<QuranNowPlayingScreen> {
  static const Color _bg = Color(0xFF0D0D0D);
  static const Color _surface = Color(0xFF1C1C1E);

  QuranAudioHandler? _handler;
  bool _ready = false;
  String? _error;
  Surah? _currentSurah;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _lastPositionSecond = -1;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurah;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final handler = await QuranPlayback.ensureInit();
      if (!mounted) return;
      setState(() {
        _handler = handler;
        _ready = true;
        _error = null;
        _currentSurah = widget.initialSurah;
      });
      _bindStreams();
      if (widget.autoPlay) {
        final playing = handler.player.playing;
        final sameTrack = handler.currentSurah?.number == widget.initialSurah.number;
        if (!playing || !sameTrack) {
          await handler.playSurah(widget.initialSurah.number, widget.selectedReciter);
        } else {
          await handler.play();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ready = false;
        _error = 'Ses yüklenemedi. İnternet bağlantınızı kontrol edin.';
      });
    }
  }

  void _bindStreams() {
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

  Surah get _displaySurah => _currentSurah ?? widget.initialSurah;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _togglePlayPause() async {
    final handler = _handler;
    if (handler == null) return;
    if (_isPlaying) {
      await handler.pause();
    } else if (handler.player.processingState == ProcessingState.idle) {
      await handler.playSurah(_displaySurah.number, widget.selectedReciter);
    } else {
      await handler.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                ),
              ),
              const Spacer(),
              const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _bootstrap,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Tekrar dene'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      );
    }

    if (!_ready || _handler == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final surah = _displaySurah;
    final maxMs = _duration.inMilliseconds.toDouble();
    final cap = maxMs > 0 ? maxMs : 1.0;
    final posMs = _position.inMilliseconds.toDouble().clamp(0.0, cap);
    final mekki = surah.revelationType == 'Meccan';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const Spacer(),
            _buildArtwork(surah),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Text(
                    '${surah.englishNameTranslation} Suresi',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.selectedReciter,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${surah.numberOfAyahs} ayet · ${mekki ? 'Mekki' : 'Medeni'}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSecondaryActions(context, surah),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: posMs,
                      max: cap,
                      onChanged: (v) => _handler!.seek(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _format(_position),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          _duration.inMilliseconds > 0 ? _format(_duration) : '--:--',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildMainControls(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 4, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 34),
            tooltip: 'Küçült',
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.repeat_rounded, color: Colors.white.withOpacity(0.65), size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.graphic_eq_rounded, color: Colors.white.withOpacity(0.65), size: 22),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: _displaySurah)),
              );
            },
            icon: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.65), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(Surah surah) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo.png',
              width: 88,
              height: 88,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            surah.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sure ${surah.number}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions(BuildContext context, Surah surah) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _smallAction(icon: Icons.queue_music_rounded, onTap: () => Navigator.pop(context)),
          _smallAction(icon: Icons.favorite_border_rounded, onTap: () {}),
          _smallAction(
            icon: Icons.chrome_reader_mode_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: surah)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _smallAction({required IconData icon, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white.withOpacity(0.75), size: 26),
    );
  }

  Widget _buildMainControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlBtn(icon: Icons.shuffle_rounded, size: 24, onTap: () {}),
          _controlBtn(
            icon: Icons.skip_previous_rounded,
            size: 34,
            onTap: () async {
              await _handler!.skipToPrevious();
              setState(() => _currentSurah = _handler!.currentSurah);
            },
          ),
          _controlBtn(
            icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 38,
            filled: true,
            large: true,
            onTap: _togglePlayPause,
          ),
          _controlBtn(
            icon: Icons.skip_next_rounded,
            size: 34,
            onTap: () async {
              await _handler!.skipToNext();
              setState(() => _currentSurah = _handler!.currentSurah);
            },
          ),
          _controlBtn(
            icon: Icons.lyrics_outlined,
            size: 24,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => QuranReaderScreen(surah: _displaySurah)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool filled = false,
    bool large = false,
  }) {
    final dim = large ? 68.0 : 44.0;
    return Material(
      color: filled ? Colors.white : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: dim,
          height: dim,
          child: Icon(
            icon,
            size: size,
            color: filled ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
