import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

class EzberScreen extends StatefulWidget {
  const EzberScreen({super.key});

  @override
  State<EzberScreen> createState() => _EzberScreenState();
}

class _EzberScreenState extends State<EzberScreen> {
  String _selectedSurah = 'Kevser';
  bool _isRecording = false;
  int _currentWordIndex = -1;
  int _errorWordIndex = -1;
  bool _isErrorCorrectionActive = false;
  
  Timer? _waveTimer;
  List<double> _waveValues = List.generate(20, (index) => 5.0);
  
  String _viewLanguage = 'latin'; // 'latin' or 'arabic'
  String _hideMode = 'none'; // 'none', 'half', 'all'
  String _statusMessage = 'Sureyi okumaya başlamak için mikrofona basın';
  
  int _accuracyScore = 100;
  int _tecvidScore = 100;

  final Map<String, Map<String, List<String>>> _surahTexts = {
    'Fatiha': {
      'latin': [
        'Elhamdü', 'lillâhi', 'rabbil\'alemin',
        'Errahmânirrahîm',
        'Mâliki', 'yevmiddîn',
        'İyyâke', 'na\'büdü', 've', 'iyyâke', 'neste\'în',
        'İhdinessırâtel', 'müstakîm',
        'Sırâtellezîne', 'en\'amte', 'aleyhim',
        'ğayrilmağdûbi', 'aleyhim', 'veleddâllîn'
      ],
      'arabic': [
        'ٱلْحَمْدُ', 'لِلَّهِ', 'رَبِّ', 'ٱلْعَٰلَمِينَ',
        'ٱلرَّحْمَٰنِ', 'ٱلرَّحِيمِ',
        'مَٰلِكِ', 'يَوْمِ', 'ٱلدِّينِ',
        'إِيَّاكَ', 'نَعْبُdُ', 'وَإِيَّاكَ', 'نَسْتَعِينُ',
        'ٱهْدِنَا', 'ٱلصِّرَٰطَ', 'ٱلْمُسْتَقِيمَ',
        'صِرَٰطَ', 'ٱلَّذِينَ', 'أَنْعَمْتَ', 'عَلَيْهِمْ',
        'غَيْرِ', 'ٱلْمَغْضُوبِ', 'عَلَيْهِمْ', 'وَلَا', 'ٱلضَّآلِّينَ'
      ]
    },
    'Kevser': {
      'latin': [
        'İnnâ', 'a\'taynâkel', 'kevser.',
        'Fesalli', 'lirabbike', 'venhar.',
        'İnne', 'şânieke', 'hüvel', 'ebter.'
      ],
      'arabic': [
        'إِنَّآ', 'أَعْطَيْنَٰكَ', 'ٱلْكَوْثَرَ',
        'فَصَلِّ', 'لِرَبِّكَ', 'وَٱنْحَرْ',
        'إِنَّ', 'شَانِئَكَ', 'هُوَ', 'ٱلْأَبْتَرُ'
      ]
    },
    'İhlas': {
      'latin': [
        'Kul', 'hüvellâhü', 'ehad.',
        'Allâhüssamed.',
        'Lem', 'yelid', 've', 'lem', 'yûled.',
        'Ve', 'lem', 'yekün', 'lehû', 'küfüven', 'ehad.'
      ],
      'arabic': [
        'قُلْ', 'هُوَ', 'ٱللَّهُ', 'أَحَدٌ',
        'ٱللَّهُ', 'ٱلصَّمَدُ',
        'لَمْ', 'يَلِدْ', 'وَلَمْ', 'يُولَدْ',
        'وَلَمْ', 'يَكُن', 'لَّهُۥ', 'كُفُوًا', 'أَحَدٌ'
      ]
    },
    'Felak': {
      'latin': [
        'Kul', 'eûzü', 'birabbil', 'felak.',
        'Min', 'şerri', 'mâ', 'halak.',
        'Ve', 'min', 'şerri', 'ğâsikın', 'izâ', 'vekab.',
        'Ve', 'min', 'şerrin', 'neffâsâti', 'fil', 'ukad.',
        'Ve', 'min', 'şerri', 'hâsidin', 'izâ', 'hased.'
      ],
      'arabic': [
        'قُلْ', 'أَعُوذُ', 'بِرَبِّ', 'ٱلْفَلَقِ',
        'مِن', 'شَرِّ', 'مَا', 'خَلَقَ',
        'وَمِن', 'شَرِّ', 'غَاسِقٍ', 'إِذَا', 'وَقَبَ',
        'وَمِن', 'شَرِّ', 'ٱلنَّفَّٰثَٰtِ', 'فِي', 'ٱلْعُقَدِ',
        'وَمِن', 'شَرِّ', 'حَاسِدٍ', 'إِذَا', 'حَسَدَ'
      ]
    },
    'Nâs': {
      'latin': [
        'Kul', 'eûzü', 'birabbin', 'nâs.',
        'Melikin', 'nâs.',
        'İlâhin', 'nâs.',
        'Min', 'şerril', 'vesvâsil', 'hannâs.',
        'Ellezî', 'yuvesvisu', 'fî', 'sudûrin', 'nâs.',
        'Minel', 'cinneti', 'ven', 'nâs.'
      ],
      'arabic': [
        'قُلْ', 'أَعُوذُ', 'بِرَبِّ', 'ٱلنَّاسِ',
        'مَلِكِ', 'ٱلنَّاسِ',
        'إِلَٰهِ', 'ٱلنَّاسِ',
        'مِن', 'شَرِّ', 'ٱلْوَسْوَاسِ', 'ٱلْخَنَّاسِ',
        'ٱلَّذِي', 'يُوَسْوِسُ', 'fِي', 'صُدُورِ', 'ٱلنَّاسِ',
        'مِنَ', 'ٱلْجِنَّةِ', 'وَٱلنَّاسِ'
      ]
    },
    'Fil': {
      'latin': [
        'Elem', 'tera', 'keyfe', 'fe\'ale', 'rabbüke', 'biashâbil', 'fîl.',
        'Elem', 'yec\'al', 'keydehüm', 'fî', 'tadlil.',
        'Ve', 'ersele', 'aleyhim', 'tayran', 'ebâbîl.',
        'Termîhim', 'bihicâratin', 'min', 'siccîl.',
        'Fece\'alehüm', 'ke\'asfin', 'me\'kûl.'
      ],
      'arabic': [
        'أَلَمْ', 'تَرَ', 'كَيْفَ', 'فَعَلَ', 'رَبُّكَ', 'بِأَصْحَٰبِ', 'ٱلْفِيلِ',
        'أَلَمْ', 'يَجْعَلْ', 'كَيْدَهُمْ', 'fِي', 'تَضْلِيلٍ',
        'وَأَرْسَلَ', 'عَلَيْهِمْ', 'طَيْرًا', 'أَبَابِيلَ',
        'تَرْمِيهِم', 'بِحِجَارَةٍ', 'mِّن', 'سِجِّيلٍ',
        'فَجَعَلَهُمْ', 'كَعَصْفٍ', 'mَّأْكُولٍ'
      ]
    },
    'Kureyş': {
      'latin': [
        'Liîlâfi', 'kureyş.',
        'Îlâfihim', 'rihleteş', 'şitâi', 'ves', 'sayf.',
        'Felye\'büdû', 'rabbe', 'hâzel', 'beyt.',
        'Ellezî', 'et\'amehüm', 'min', 'cû\'in', 've', 'âmenehüm', 'min', 'havf.'
      ],
      'arabic': [
        'لِإِيلَٰفِ', 'قُرَيْشٍ',
        'إِۦلَٰفِهِمْ', 'رِحْلَةَ', 'ٱلشِّتَآءِ', 'وَٱلصَّيْفِ',
        'فَلْyَعْبُدُواْ', 'رَبَّ', 'هَٰذَا', 'ٱلْبَيْتِ',
        'ٱلَّذِيٓ', 'أَطْعَمَهُم', 'mِّن', 'جُوعٍ', 'وَءَامَنَهُم', 'mِّنْ', 'خَوْفٍۭ'
      ]
    }
  };

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }

  void _startEzberCheck() {
    setState(() {
      _isRecording = true;
      _currentWordIndex = -1;
      _errorWordIndex = -1;
      _isErrorCorrectionActive = false;
      _statusMessage = '🎙️ Dinleme başlatıldı. Okuyun...';
      _accuracyScore = 100;
      _tecvidScore = 100;
    });

    _scheduleNextWord();

    // Simulate microphone waveform animations
    final random = math.Random();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (_isErrorCorrectionActive) {
          // Flatten waveform when pausing for correction
          _waveValues = List.generate(25, (index) => 3.0);
        } else {
          _waveValues = List.generate(25, (index) => random.nextDouble() * 26.0 + 4.0);
        }
      });
    });
  }

  void _scheduleNextWord() {
    if (!_isRecording || !mounted) return;

    final words = _surahTexts[_selectedSurah]?[_viewLanguage] ?? [];
    final int nextIndex = _currentWordIndex + 1;

    if (nextIndex >= words.length) {
      _stopEzberCheck(completed: true);
      return;
    }

    final random = math.Random();
    // 12% chance to trigger simulated AI error correction
    final bool isError = random.nextDouble() < 0.12 && nextIndex > 1 && nextIndex < words.length - 1 && !_isErrorCorrectionActive;

    if (isError) {
      setState(() {
        _errorWordIndex = nextIndex;
        _isErrorCorrectionActive = true;
        _statusMessage = '⚠️ Mahreç hatası algılandı! Tekrar okuyun...';
      });
      HapticFeedback.heavyImpact();

      // Pause for 2.2 seconds before the user "corrects" it
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (!mounted || !_isRecording) return;
        setState(() {
          _currentWordIndex = nextIndex;
          _errorWordIndex = -1;
          _isErrorCorrectionActive = false;
          _statusMessage = '🎙️ Harika, doğru mahreç. Devam edin...';
        });
        HapticFeedback.lightImpact();
        
        // Decrease score values realistically
        _accuracyScore = math.max(75, _accuracyScore - 6);
        _tecvidScore = math.max(80, _tecvidScore - 5);
        
        _scheduleNextWord();
      });
    } else {
      // Normal word reading delay simulation (randomized to feel natural)
      final delayMs = random.nextInt(700) + 650;
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted || !_isRecording || _isErrorCorrectionActive) return;

        setState(() {
          _currentWordIndex = nextIndex;
          _statusMessage = '🎙️ Ezberinizi dinliyorum...';
        });

        _scheduleNextWord();
      });
    }
  }

  void _stopEzberCheck({bool completed = false}) {
    _waveTimer?.cancel();
    setState(() {
      _isRecording = false;
      _statusMessage = completed
          ? 'Sure tamamlandı!'
          : 'Sureyi okumaya başlamak için mikrofona basın';
      if (!completed) {
        _currentWordIndex = -1;
        _errorWordIndex = -1;
        _isErrorCorrectionActive = false;
      }
    });

    if (completed) {
      _showReportDialog();
    }
  }

  void _showReportDialog() {
    final random = math.Random();
    final int accuracy = _accuracyScore;
    final int tecvid = _tecvidScore;
    final int fluency = random.nextInt(10) + 90;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Text('🏆 ', style: TextStyle(fontSize: 22)),
              Text(
                'Ezber Analiz Raporu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_selectedSurah Suresi Okuma Raporu',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              // Graphical progress report
              _buildScoreRow('Doğruluk Skoru (Accuracy)', accuracy, Colors.green),
              const SizedBox(height: 10),
              _buildScoreRow('Tecvid ve Mahreç (Tajweed)', tecvid, Colors.teal),
              const SizedBox(height: 10),
              _buildScoreRow('Akıcılık Oranı (Fluency)', fluency, Colors.blue),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              const Text(
                'Yapay Zeka Değerlendirmesi:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                accuracy >= 90
                    ? 'Tebrikler! Sureyi mükemmel derecede doğru ve akıcı okudunuz. Harf çıkışları ve tecvid kurallarınız son derece başarılı.'
                    : 'Güzel bir deneme! Bazı mahreç sapmaları tespit edildi. Özellikle okurken takıldığınız kırmızı kelimelere tekrar çalışmanız faydalı olacaktır.',
                style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.45),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentWordIndex = -1;
                  _errorWordIndex = -1;
                  _statusMessage = 'Sureyi okumaya başlamak için mikrofona basın';
                });
              },
              child: const Text(
                'Kapat ve Yeniden Dene',
                style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreRow(String title, int score, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
            Text('%$score', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: barColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100.0,
            backgroundColor: Colors.grey.shade100,
            color: barColor,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // View Language Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metin Tipi', style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _viewLanguage,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 'latin', child: Text('Okunuş (Latin)')),
                        DropdownMenuItem(value: 'arabic', child: Text('Arapça (Kuran)')),
                      ],
                      onChanged: _isRecording ? null : (val) {
                        if (val != null) {
                          setState(() {
                            _viewLanguage = val;
                            _currentWordIndex = -1;
                            _errorWordIndex = -1;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Hiding Difficulty Dropdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ezber Zorluğu', style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _hideMode,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Normal (Açık)')),
                        DropdownMenuItem(value: 'half', child: Text('Yarı Gizli (%50)')),
                        DropdownMenuItem(value: 'all', child: Text('Tam Gizli (100%)')),
                      ],
                      onChanged: _isRecording ? null : (val) {
                        if (val != null) {
                          setState(() {
                            _hideMode = val;
                            _currentWordIndex = -1;
                            _errorWordIndex = -1;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = _surahTexts[_selectedSurah]?[_viewLanguage] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Surah Label
          const Text(
            'Ezberlemek istediğiniz sureyi seçin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          // Scrollable Surah selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _surahTexts.keys.map((surah) {
                final isSelected = _selectedSurah == surah;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: _isRecording ? null : () {
                      setState(() {
                        _selectedSurah = surah;
                        _currentWordIndex = -1;
                        _errorWordIndex = -1;
                        _isErrorCorrectionActive = false;
                        _statusMessage = 'Sureyi okumaya başlamak için mikrofona basın';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppColors.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        surah,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Settings configuration panel (language and hiding level)
          _buildSettingsRow(),
          const SizedBox(height: 14),
          // Recitation text board card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Directionality(
                      textDirection: _viewLanguage == 'arabic' ? TextDirection.rtl : TextDirection.ltr,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(words.length, (index) {
                          final isRead = index <= _currentWordIndex;
                          final isError = index == _errorWordIndex;
                          final isHidden = (_hideMode == 'all' && !isRead) || (_hideMode == 'half' && index % 2 == 1 && !isRead);
                          final wordText = isHidden ? '_____' : words[index];

                          Color textColor = Colors.black87;
                          FontWeight fontWeight = FontWeight.w500;

                          if (isRead) {
                            textColor = AppColors.primary;
                            fontWeight = FontWeight.bold;
                          } else if (isError) {
                            textColor = Colors.redAccent;
                            fontWeight = FontWeight.bold;
                          } else if (isHidden) {
                            textColor = Colors.grey.shade400;
                          }

                          return Text(
                            wordText,
                            style: TextStyle(
                              fontFamily: _viewLanguage == 'arabic' ? 'ScheherazadeNew' : null,
                              fontSize: _viewLanguage == 'arabic' ? 26 : 20,
                              fontWeight: fontWeight,
                              color: textColor,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Audio Visualizer Wave block (if recording)
          if (_isRecording) ...[
            Container(
              height: 40,
              width: double.infinity,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_waveValues.length, (index) {
                  return Container(
                    width: 3,
                    height: _waveValues[index],
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Start / Stop Microphone button and status
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopEzberCheck();
                    } else {
                      _startEzberCheck();
                    }
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : AppColors.primary).withOpacity(0.25),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isRecording ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: _isErrorCorrectionActive ? FontWeight.bold : FontWeight.normal,
                    color: _isErrorCorrectionActive ? Colors.redAccent : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
