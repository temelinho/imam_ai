import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class DailyShareScreen extends StatefulWidget {
  const DailyShareScreen({super.key});

  @override
  State<DailyShareScreen> createState() => _DailyShareScreenState();
}

class _DailyShareScreenState extends State<DailyShareScreen> {
  // Pre-selected inspiring Verses and Hadiths
  final List<Map<String, String>> _dailyQuotes = [
    {
      'type': 'Günün Ayeti',
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': 'Şüphesiz güçlükle beraber bir kolaylık vardır.',
      'reference': 'İnşirâh Suresi, 6. Ayet',
    },
    {
      'type': 'Günün Hadisi',
      'arabic': 'الدِّينُ النَّصِيحَةُ',
      'translation': 'Din, samimi olmaktan (nasihatten) ibarettir.',
      'reference': 'Müslim, Îmân, 95',
    },
    {
      'type': 'Günün Ayeti',
      'arabic': 'وَقُلْ رَبِّ زِدْنِي عِلْمًا',
      'translation': 'De ki: Rabbim, benim ilmimi artır.',
      'reference': 'Tâhâ Suresi, 114. Ayet',
    },
    {
      'type': 'Günün Hadisi',
      'arabic': 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      'translation': 'Güzel ve hoş söz sadakadır.',
      'reference': 'Buhârî, Cihâd, 128',
    },
    {
      'type': 'Günün Ayeti',
      'arabic': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      'translation': 'Şüphesiz Allah, sabredenlerle beraberdir.',
      'reference': 'Bakara Suresi, 153. Ayet',
    },
    {
      'type': 'Günün Hadisi',
      'arabic': 'لاَ تَمَارَ فَيَذْهَبَ بَهَاؤُكَ',
      'translation': 'Mümin kardeşinle münakaşa etme, onun hoşuna gitmeyecek şakalar yapma.',
      'reference': 'Tirmizî, Birr, 58',
    },
  ];

  late Map<String, String> _todaysQuote;

  @override
  void initState() {
    super.initState();
    _loadTodaysQuote();
  }

  void _loadTodaysQuote() {
    // Select quote dynamically based on the day of the year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final index = dayOfYear % _dailyQuotes.length;
    _todaysQuote = _dailyQuotes[index];
  }

  void _copyToClipboard() {
    final text = '${_todaysQuote['type']}\n\n"${_todaysQuote['translation']}"\n\n- ${_todaysQuote['reference']}\n\nİmam AI Uygulamasından Paylaşılmıştır.';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Metin panoya kopyalandı! İstediğiniz yerde yapıştırıp paylaşabilirsiniz.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Poster Frame Card (representing Instagram Story layout aspect ratio)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.cardBorder, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _todaysQuote['type']!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Arabic text
                  Text(
                    _todaysQuote['arabic']!,
                    style: const TextStyle(
                      fontFamily: 'ScheherazadeNew',
                      fontSize: 34,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Translation quote text
                  Text(
                    '“${_todaysQuote['translation']}”',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Reference
                  Text(
                    _todaysQuote['reference']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Branding logo at bottom of poster
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🕌', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'İmam AI',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Share Actions Button
          ElevatedButton.icon(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.share, color: Colors.white, size: 18),
            label: const Text(
              'Paylaşım Metnini Kopyala',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Story veya durum paylaşımı için ekran görüntüsü de alabilirsiniz.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
