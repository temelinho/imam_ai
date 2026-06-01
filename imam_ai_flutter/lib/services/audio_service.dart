import 'package:just_audio/just_audio.dart';

class QuranAudioService {
  final AudioPlayer player = AudioPlayer();
  static const String _baseUrl = 'https://cdn.islamic.network/quran/audio/128';

  // Reciter codes mapping
  static const Map<String, String> reciters = {
    'Mishary Rashid': 'ar.alafasy',
    'Abdul Rahman': 'ar.sudais',
    'Maher Al Muaiqly': 'ar.maheralmuaiqly',
  };

  Future<void> playSurah(int surahNumber, String reciterName) async {
    final reciterCode = reciters[reciterName] ?? 'ar.alafasy';
    final url = '$_baseUrl/$reciterCode/$surahNumber.mp3';
    try {
      await player.setUrl(url);
      await player.play();
    } catch (e) {
      // Handle error in UI
    }
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> resume() async {
    await player.play();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  void dispose() {
    player.dispose();
  }
}
