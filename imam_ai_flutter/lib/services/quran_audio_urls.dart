/// Sesli Kuran MP3 adresleri (sure bazlı).
class QuranAudioUrls {
  QuranAudioUrls._();

  static String surahUrl(String reciterName, int surahNumber) {
    final n = surahNumber.clamp(1, 114);
    switch (reciterName) {
      case 'Abdul Rahman':
        final padded = n.toString().padLeft(3, '0');
        return 'https://server11.mp3quran.net/sudais/$padded.mp3';
      case 'Maher Al Muaiqly':
        final padded = n.toString().padLeft(3, '0');
        return 'https://server12.mp3quran.net/maher/$padded.mp3';
      case 'Mishary Rashid':
      default:
        return 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$n.mp3';
    }
  }
}
