import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPackageIndex = 1; // Default is Yearly (En Popüler)
  bool _isLoading = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': 'Aylık Üyelik',
      'price': '₺49.99',
      'period': '/ ay',
      'badge': null,
      'description': 'İstediğin zaman iptal et',
    },
    {
      'title': 'Yıllık Üyelik',
      'price': '₺299.99',
      'period': '/ yıl',
      'badge': 'EN POPÜLER (%50 İNDİRİM)',
      'description': 'Aylık sadece ₺25.00\'a gelir',
    },
    {
      'title': 'Ömür Boyu',
      'price': '₺749.99',
      'period': ' tek seferlik',
      'badge': 'EN AVANTAJLI',
      'description': 'Sonsuza kadar senin olsun',
    },
  ];

  final List<Map<String, dynamic>> _proFeatures = [
    {
      'icon': Icons.notifications_active_rounded,
      'color': const Color(0xFFF59E0B),
      'title': 'Sesli Ezan Seçenekleri 🕌',
      'subtitle': 'Mekke, Medine, Mısır ezanları ile namaz vakitlerinde tam sesli ezan bildirimleri.',
    },
    {
      'icon': Icons.auto_awesome_rounded,
      'color': const Color(0xFF8B5CF6),
      'title': 'Sınırsız Yapay Zeka 🤖',
      'subtitle': 'Günlük soru limiti olmadan İmam AI ile sınırsız dini soru-cevap ve sohbet.',
    },
    {
      'icon': Icons.block_rounded,
      'color': const Color(0xFFEF4444),
      'title': 'Tamamen Reklamsız Arayüz 🚫',
      'subtitle': 'Sıfır reklam, ibadetlerinizde huşu içerisinde tertemiz ve sade bir kullanım.',
    },
    {
      'icon': Icons.download_for_offline_rounded,
      'color': const Color(0xFF3B82F6),
      'title': 'Çevrimdışı Kur\'an Dinleme 📥',
      'subtitle': 'Sureleri telefonunuza indirerek internetiniz yokken bile huzurla dinleme imkanı.',
    },
    {
      'icon': Icons.star_rounded,
      'color': const Color(0xFF10B981),
      'title': 'Özel Manevi Alarm & Raporlar 📊',
      'subtitle': 'Teheccüd namazı alarmları ve haftalık/aylık detaylı ibadet gelişim analizleri.',
    },
  ];

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);

    // Simulate purchasing network request delay
    await Future.delayed(const Duration(milliseconds: 2000));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro', true);

    if (mounted) {
      setState(() => _isLoading = false);
      
      // Show Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 52),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Hayırlı Olsun! 🌟',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                ),
                const SizedBox(height: 10),
                const Text(
                  'İmam AI Pro üyeliğiniz başarıyla aktif edildi. Reklamsız ve sınırsız özelliklerin tadını çıkarın!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dismiss dialog
                      Navigator.of(context).pop(true); // Return true to parent to refresh
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kullanmaya Başla', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        title: const Text('İmam AI Pro\'ya Geç 👑', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Premium Header Gradient Banner ────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF005F41), Color(0xFF023223)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 48),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'İmam AI Pro',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uygulamanın tüm özelliklerini sınırsızca açın, dini hayatınızı ve ibadetlerinizi daha huzurlu kılın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(0.85), height: 1.4),
                      ),
                    ],
                  ),
                ),

                // ─── Pro Özellikleri Listesi ─────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Neler Kazanacaksınız?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.neutral900),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.05),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: _proFeatures.map((feat) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (feat['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(feat['icon'] as IconData, color: feat['color'] as Color, size: 20),
                          ),
                          title: Text(
                            feat['title'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.neutral900),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              feat['subtitle'] as String,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ─── Paketler Seçim Kartları ─────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Text(
                    'Size En Uygun Planı Seçin',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.neutral900),
                  ),
                ),
                Column(
                  children: _packages.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pkg = entry.value;
                    final isSelected = _selectedPackageIndex == idx;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPackageIndex = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.02),
                              blurRadius: isSelected ? 12 : 4,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Radio indicator
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.grey,
                                  width: isSelected ? 6 : 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (pkg['badge'] != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFD1FAE5) : const Color(0xFFECEFF1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        pkg['badge'] as String,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? AppColors.primaryDark : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(
                                    pkg['title'] as String,
                                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pkg['description'] as String,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  pkg['price'] as String,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.neutral900),
                                ),
                                Text(
                                  pkg['period'] as String,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ─── Satın Al Butonu ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Şimdi Pro\'ya Geç ve Etkinleştir 👑',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Güvenlik & Gizlilik Açıklamaları ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security_rounded, color: Colors.grey, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Güvenli 256-bit SSL ödeme ve Google Play altyapısı.',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Satın alım onaylandığında Google Play hesabınızdan tahsil edilecektir. İstediğiniz an Google Play aboneliklerinizden iptal edebilirsiniz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500, height: 1.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Ödeme İşleniyor...',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lütfen pencereyi kapatmayınız',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
