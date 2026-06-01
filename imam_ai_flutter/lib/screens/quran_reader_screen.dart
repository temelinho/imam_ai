import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/theme/app_colors.dart';
import '../models/surah.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;

  const QuranReaderScreen({
    super.key,
    required this.surah,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  List<dynamic> _arabicAyahs = [];
  List<dynamic> _turkishAyahs = [];
  bool _isLoading = true;
  bool _hasError = false;
  double _fontSizeArabic = 26.0;
  double _fontSizeTurkish = 14.5;
  String _viewMode = 'both'; // 'both', 'arabic', 'turkish'

  @override
  void initState() {
    super.initState();
    _fetchSurahData();
  }

  Future<void> _fetchSurahData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = 'https://api.alquran.cloud/v1/surah/${widget.surah.number}/editions/quran-uthmani,tr.diyanet';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null && data['data'].length == 2) {
          setState(() {
            _arabicAyahs = data['data'][0]['ayahs'] ?? [];
            _turkishAyahs = data['data'][1]['ayahs'] ?? [];
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.surah.englishNameTranslation} Suresi',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Arapça: ${widget.surah.name} · ${widget.surah.numberOfAyahs} Ayet',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildControlBar(),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: const Border(
          bottom: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // View Mode Selector (ChoiceChips)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildModeChip(label: 'Mealli', mode: 'both'),
                  const SizedBox(width: 6),
                  _buildModeChip(label: 'Sadece Arapça', mode: 'arabic'),
                  const SizedBox(width: 6),
                  _buildModeChip(label: 'Sadece Meal', mode: 'turkish'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Font Adjusters
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.text_decrease, size: 20, color: AppColors.primaryDark),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    if (_fontSizeArabic > 20) _fontSizeArabic -= 2;
                    if (_fontSizeTurkish > 11) _fontSizeTurkish -= 1;
                  });
                },
                tooltip: 'Yazı Boyutunu Küçült',
              ),
              const SizedBox(width: 6),
              const Text(
                'Boyut',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.text_increase, size: 20, color: AppColors.primaryDark),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    if (_fontSizeArabic < 40) _fontSizeArabic += 2;
                    if (_fontSizeTurkish < 22) _fontSizeTurkish += 1;
                  });
                },
                tooltip: 'Yazı Boyutunu Büyüt',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({required String label, required String mode}) {
    final isSelected = _viewMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.primaryDark,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.cardBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onSelected: (val) {
        if (val) {
          setState(() {
            _viewMode = mode;
          });
        }
      },
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Sure ayetleri yükleniyor...',
              style: TextStyle(color: AppColors.primaryDark, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🕌',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ayetler yüklenirken bir bağlantı hatası oluştu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchSurahData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Yeniden Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _arabicAyahs.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.separator,
        height: 24,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        final arabicText = _arabicAyahs[index]['text'] ?? '';
        final turkishText = _turkishAyahs[index]['text'] ?? '';
        final ayahNumber = _arabicAyahs[index]['numberInSurah'] ?? (index + 1);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah Info Header (Ayet No, Kopyala butonu)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ayet $ayahNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: AppColors.primaryDark),
                    onPressed: () {
                      final shareText = 'Ayet $ayahNumber:\n\n$arabicText\n\nMeal:\n$turkishText\n\n- ${widget.surah.englishNameTranslation} Suresi (İmam AI)';
                      Clipboard.setData(ClipboardData(text: shareText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ayet panoya kopyalandı!'),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Arabic text
              if (_viewMode == 'both' || _viewMode == 'arabic') ...[
                Text(
                  arabicText,
                  style: TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: _fontSizeArabic,
                    color: AppColors.neutral900,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
              ],
              // Turkish text
              if (_viewMode == 'both' || _viewMode == 'turkish') ...[
                Text(
                  turkishText,
                  style: TextStyle(
                    fontSize: _fontSizeTurkish,
                    color: AppColors.neutral700,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
