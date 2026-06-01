import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../core/constants/surah_list.dart';
import '../models/surah.dart';
import 'quran_audio_urls.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();
  bool _sessionReady = false;

  String _reciterName = 'Mishary Rashid';
  int _currentIndex = 0;

  QuranAudioHandler() {
    _configureAudioSession();
    player.playbackEventStream.listen(_broadcastState);
    player.playerStateStream.listen((_) => _broadcastState());
  }

  Future<void> _configureAudioSession() async {
    if (_sessionReady) return;
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ),
    );
    _sessionReady = true;
  }

  String get reciterName => _reciterName;
  int get currentIndex => _currentIndex;
  Surah? get currentSurah =>
      _currentIndex >= 0 && _currentIndex < quranSurahs.length ? quranSurahs[_currentIndex] : null;

  Future<void> playSurah(int surahNumber, String reciterName) async {
    await _configureAudioSession();
    _reciterName = reciterName;
    final index = quranSurahs.indexWhere((s) => s.number == surahNumber);
    if (index < 0) return;
    await _loadSurahAt(index);
    await player.play();
  }

  Future<void> setReciter(String reciterName) async {
    if (_reciterName == reciterName) return;
    _reciterName = reciterName;
    final wasPlaying = player.playing;
    await _loadSurahAt(_currentIndex);
    if (wasPlaying) await player.play();
  }

  Future<void> _loadSurahAt(int index) async {
    _currentIndex = index.clamp(0, quranSurahs.length - 1);
    final surah = quranSurahs[_currentIndex];
    final item = _mediaItemFor(surah);
    final url = QuranAudioUrls.surahUrl(_reciterName, surah.number);

    queue.add([item]);
    mediaItem.add(item);

    await player.setAudioSource(
      AudioSource.uri(Uri.parse(url), tag: item),
      preload: true,
    );
    _broadcastState();
  }

  MediaItem _mediaItemFor(Surah surah) {
    return MediaItem(
      id: surah.number.toString(),
      title: '${surah.englishNameTranslation} Suresi',
      artist: _reciterName,
      album: 'Kuran-ı Kerim',
      displayTitle: '${surah.englishNameTranslation} Suresi',
      displaySubtitle: _reciterName,
      displayDescription: 'İmam AI · Sesli Kuran',
    );
  }

  void _broadcastState([PlaybackEvent? event]) {
    final processing = _mapProcessingState(player.processingState);
    final playing = player.playing;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: processing,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: 0,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < quranSurahs.length - 1) {
      await _loadSurahAt(_currentIndex + 1);
      await player.play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (player.position.inSeconds > 3) {
      await player.seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      await _loadSurahAt(_currentIndex - 1);
      await player.play();
    } else {
      await player.seek(Duration.zero);
    }
  }

  Future<void> disposePlayer() async {
    await player.dispose();
  }
}
