import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  String t(String tr, String ar) => isArabic ? ar : tr;

  // ─── Genel ───────────────────────────────────────────────────────────────
  String get appName => t('İmam AI', 'إمام AI');
  String get loading => t('Yükleniyor...', 'جاري التحميل...');
  String get retry => t('Yeniden Dene', 'إعادة المحاولة');
  String get close => t('Kapat', 'إغلاق');
  String get back => t('Geri', 'رجوع');
  String get next => t('İleri', 'التالي');
  String get cancel => t('İptal', 'إلغاء');
  String get later => t('Daha Sonra', 'لاحقاً');
  String get explore => t('İncele', 'استكشف');
  String get today => t('Bugün', 'اليوم');
  String get version => t('Sürüm', 'الإصدار');
  String get pro => t('PRO 👑', 'برو 👑');
  String get farz => t('Farz', 'فرض');
  String get sunnet => t('Sünnet', 'سنة');
  String get step => t('Adım', 'خطوة');

  // ─── Alt navigasyon ──────────────────────────────────────────────────────
  String get navHome => t('Ana', 'الرئيسية');
  String get navPrayer => t('Vakit', 'الأوقات');
  String get navQuran => t('Kuran', 'القرآن');
  String get navAssistant => t('Asistan', 'المساعد');
  String get navQibla => t('Kıble', 'القبلة');
  String get navAblution => t('Abdest', 'الوضوء');

  // ─── AppBar başlıkları ───────────────────────────────────────────────────
  String get titlePrayerTimes => t('Namaz vakitleri', 'أوقات الصلاة');
  String get titleQuran => t('Kuran-ı Kerim', 'القرآن الكريم');
  String get titleQibla => t('Kıble yönü', 'اتجاه القبلة');
  String get titleSettings => t('Ayarlar', 'الإعدادات');
  String get titleFasting => t('Oruç bilgisi', 'معلومات الصيام');
  String get titleAblution => t('Abdest rehberi', 'دليل الوضوء');
  String get titleDhikr => t('Zikirmatik', 'عداد الذكر');
  String get titleDailyShare => t('Günün Paylaşımı', 'مشاركة اليوم');
  String get titleTracker => t('İbadet Takipçisi', 'متابعة العبادات');
  String get titleMemorize => t('Sesli Ezber', 'الحفظ الصوتي');
  String get titleMosques => t('Yakın Camiler', 'المساجد القريبة');
  String get titleZakat => t('Zekat Hesaplayıcı', 'حاسبة الزكاة');

  String subtitleHome(String city, String mezhep) =>
      t('$city · $mezhep mezhebi', '$city · مذهب $mezhep');
  String get subtitleQuran => t('114 sure · sesli okuma', '١١٤ سورة · قراءة صوتية');
  String get subtitleQibla => t('GPS ile hesaplandı', 'حُسب عبر GPS');
  String get subtitleSettings => t('Tercihlerinize göre ayarlayın', 'اضبط حسب تفضيلاتك');
  String get subtitleFasting => t('Mezhepler arası karşılaştırma', 'مقارنة بين المذاهب');
  String get subtitleAblution => t('Adım adım anlatım', 'شرح خطوة بخطوة');
  String get subtitleDhikr => t('Günlük zikir sayacı', 'عداد الذكر اليومي');
  String get subtitleDailyShare => t('Ayet ve Hadis kartları', 'بطاقات آية وحديث');
  String get subtitleTracker => t('Haftalık ibadet planı', 'خطة العبادة الأسبوعية');
  String get subtitleMemorize => t('Sure ezber asistanı', 'مساعد حفظ السور');
  String get subtitleMosques => t('Konum bazlı yol tarifi', 'توجيه حسب الموقع');
  String get subtitleZakat => t('Adım adım zekat hesaplama', 'حساب الزكاة خطوة بخطوة');
  String subtitlePrayerDate(String date, String city) => t('$date · $city', '$date · $city');
  String get subtitleChat => t('Ehl-i Sünnet', 'أهل السنة');

  // ─── Dashboard ───────────────────────────────────────────────────────────
  String get nextPrayerTime => t('Sonraki namaz vakti', 'وقت الصلاة القادم');
  String get prayerCountUnit => t('vakit', 'صلاة');
  String get sectionWorship => t('TEMEL İBADETLER & REHBERLER', 'العبادات والأدلة الأساسية');
  String get sectionDaily => t('GÜNLÜK ARAÇLAR & TAKİP', 'أدوات ومتابعة يومية');
  String get sectionServices => t('YARDIMCI HİZMETLER', 'خدمات مساعدة');
  String get menuPrayerTimes => t('Namaz vakitleri', 'أوقات الصلاة');
  String get menuListenQuran => t('Kuran dinle', 'استمع للقرآن');
  String get menuQibla => t('Kıble yönü', 'اتجاه القبلة');
  String get menuAblution => t('Abdest rehberi', 'دليل الوضوء');
  String get menuFasting => t('Oruç bilgisi', 'معلومات الصيام');
  String get menuDhikr => t('Zikirmatik (Sayaç)', 'عداد الذكر');
  String get menuDailyShare => t('Günün Paylaşımı', 'مشاركة اليوم');
  String get menuTracker => t('İbadet Takipçisi', 'متابعة العبادات');
  String get menuMemorize => t('Sesli Ezber', 'الحفظ الصوتي');
  String get menuZakat => t('Zekat Hesaplayıcı', 'حاسبة الزكاة');
  String get menuMosques => t('Yakın Camiler', 'المساجد القريبة');
  String get menuChat => t('Dini Sohbet (AI)', 'الحوار الديني (ذكاء اصطناعي)');

  // ─── Namaz vakitleri ─────────────────────────────────────────────────────
  String get nextPrayer => t('Sonraki vakit', 'الوقت القادم');
  String get currentPrayer => t('Şu anki vakit', 'الوقت الحالي');
  String get upcomingPrayer => t('Sıradaki vakit', 'الوقت التالي');
  String get diyanetApi => t('Diyanet API', 'واجهة ديانيت');
  String notifSet(String name) => t('$name vakti için ezan bildirimi kuruldu 🕌', 'تم ضبط إشعار أذان $name 🕌');
  String notifCancelled(String name) => t('$name vakti bildirimi iptal edildi 🔕', 'أُلغي إشعار $name 🔕');

  String prayerName(String key) {
    switch (key) {
      case 'imsak':
        return t('İmsak', 'الإمساك');
      case 'gunes':
        return t('Güneş', 'الشروق');
      case 'ogle':
        return t('Öğle', 'الظهر');
      case 'ikindi':
        return t('İkindi', 'العصر');
      case 'aksam':
        return t('Akşam', 'المغرب');
      case 'yatsi':
        return t('Yatsı', 'العشاء');
      default:
        return key;
    }
  }

  // ─── Mezhep ──────────────────────────────────────────────────────────────
  String mezhepName(String key) {
    switch (key) {
      case 'Hanefi':
        return t('Hanefi', 'الحنفي');
      case 'Şafi':
        return t('Şafi', 'الشافعي');
      case 'Maliki':
        return t('Maliki', 'المالكي');
      case 'Hanbeli':
        return t('Hanbeli', 'الحنبلي');
      default:
        return key;
    }
  }

  String mezhepDescription(String key) {
    switch (key) {
      case 'Hanefi':
        return t(
          'İmam Ebu Hanife · Türkiye, Orta Asya ve Güney Asya\'da yaygın',
          'الإمام أبو حنيفة · شائع في تركيا وآسيا الوسطى وجنوب آسيا',
        );
      case 'Şafi':
        return t(
          'İmam Şafi · Doğu Anadolu, Mısır ve Güneydoğu Asya\'da yaygın',
          'الإمام الشافعي · شائع في شرق الأناضول ومصر وجنوب شرق آسيا',
        );
      case 'Maliki':
        return t(
          'İmam Malik · Kuzey ve Batı Afrika\'da yaygın',
          'الإمام مالك · شائع في شمال وغرب أفريقيا',
        );
      case 'Hanbeli':
        return t(
          'İmam Ahmed bin Hanbel · Arap Yarımadası\'nda yaygın',
          'الإمام أحمد بن حنبل · شائع في شبه الجزيرة العربية',
        );
      default:
        return '';
    }
  }

  String mezhepBadge(String mezhep) => t('$mezhep mezhebi', 'مذهب $mezhep');

  // ─── Ayarlar ─────────────────────────────────────────────────────────────
  String get settingsLanguage => t('Dil', 'اللغة');
  String get settingsLanguageSubtitle => t('Uygulama arayüz dili', 'لغة واجهة التطبيق');
  String get languageTurkish => t('Türkçe', 'التركية');
  String get languageArabic => t('Arapça', 'العربية');
  String get selectLanguage => t('Dil Seçin', 'اختر اللغة');
  String get sectionLocation => t('Konum', 'الموقع');
  String get sectionLocationSubtitle => t('Namaz vakitleri bu şehre göre hesaplanır', 'تُحسب أوقات الصلاة حسب هذه المدينة');
  String get city => t('Şehir', 'المدينة');
  String get selectCity => t('Şehir Seçin', 'اختر المدينة');
  String get sectionMezhep => t('Mezhep Seçimi', 'اختيار المذهب');
  String get sectionMezhepSubtitle => t('Fıkhi hesaplamalar bu mezhepe göre yapılır', 'تُجرى الحسابات الفقهية وفق هذا المذهب');
  String get sectionEzan => t('Ezan Sesi', 'صوت الأذان');
  String get sectionEzanSubtitle => t('Bildirim geldiğinde çalınacak ezan', 'الأذان عند وصول الإشعار');
  String get sectionReciter => t('Kuran Kârisi', 'قارئ القرآن');
  String get sectionReciterSubtitle => t('Sesli okuma için tercih ettiğiniz kâri', 'القارئ المفضل للقراءة الصوتية');
  String get sectionNotifications => t('Bildirimler', 'الإشعارات');
  String get sectionNotificationsSubtitle => t('Hangi bildirimler gönderilsin?', 'أي إشعارات تُرسل؟');
  String get sectionAbout => t('Hakkında', 'حول التطبيق');
  String get appVersionLine => t('Sürüm 1.0.0 · Ehl-i Sünnet', 'الإصدار ١.٠.٠ · أهل السنة');
  String get geminiBadge => t('Gemini 2.0 Flash', 'Gemini 2.0 Flash');
  String get notifAll => t('Tüm bildirimler', 'جميع الإشعارات');
  String get notifAllSubtitle => t('Ana bildirim anahtarı', 'مفتاح الإشعارات الرئيسي');
  String get notifPrayer => t('Namaz vakti hatırlatıcı', 'تذكير أوقات الصلاة');
  String get notifPrayerSubtitle => t('Her namaz vaktinde bildirim', 'إشعار عند كل وقت صلاة');
  String get notifDaily => t('Günlük ayet & hadis', 'آية وحديث يومي');
  String get notifDailySubtitle => t('Her sabah ilham verici içerik', 'محتوى ملهم كل صباح');
  String get notifFriday => t('Cuma namazı hatırlatıcısı', 'تذكير صلاة الجمعة');
  String get notifFridaySubtitle => t('Her Cuma günü özel bildirim', 'إشعار خاص كل جمعة');
  String get terms => t('Kullanım Koşulları', 'شروط الاستخدام');
  String get privacy => t('Gizlilik Politikası', 'سياسة الخصوصية');
  String get rateApp => t('Uygulamayı Oyla ⭐', 'قيّم التطبيق ⭐');
  String get feedback => t('Geri Bildirim Gönder', 'إرسال ملاحظات');
  String get disclaimer => t(
    'İmam AI referans amaçlıdır. Önemli dini konularda yetkili bir din görevlisine danışınız.',
    'إمام AI للمرجعية فقط. استشر عالماً شرعياً في المسائل الدينية المهمة.',
  );
  String get proUpgrade => t('İmam AI Pro\'ya Yükselt 👑', 'الترقية إلى إمام AI برو 👑');
  String get proUpgradeSubtitle => t('Sesli Ezanlar, Sınırsız Yapay Zeka ve Sıfır Reklam!', 'أذان صوتي، ذكاء اصطناعي غير محدود وبدون إعلانات!');
  String get goPro => t('Pro\'ya Geç 👑', 'انتقل إلى برو 👑');
  String get proEdition => t('Pro sürüm 👑', 'نسخة برو 👑');

  String ezanName(String key) {
    switch (key) {
      case 'Türkiye Diyanet':
        return t('Türkiye Diyanet', 'ديانت تركيا');
      case 'Mısır Usulü':
        return t('Mısır Usulü', 'أسلوب مصر');
      case 'Mekke Ezanı':
        return t('Mekke Ezanı', 'أذان مكة');
      case 'Medine Ezanı':
        return t('Medine Ezanı', 'أذان المدينة');
      case 'Kısa Ezan':
        return t('Kısa Ezan', 'أذان قصير');
      default:
        return key;
    }
  }

  String reciterSubtitle(String key) {
    switch (key) {
      case 'Mishary Rashid':
        return t('Kuveytli ünlü hafız', 'حافظ كويتي مشهور');
      case 'Abdul Rahman':
        return t('Klasik tilâvet stili', 'أسلوب تلاوة كلاسيكي');
      case 'Maher Al Muaiqly':
        return t('Mekke imamı', 'إمام مكة');
      default:
        return '';
    }
  }

  String get premiumEzanTitle => t('Sesli Ezan Seçenekleri 🕌', 'خيارات الأذان الصوتي 🕌');
  String get premiumEzanBody => t(
    'Mekke, Medine, Mısır gibi farklı ezan seslerini seçmek ve vakitlerde tam sesli ezan bildirimleri almak Pro sürüme özeldir. Ezan seslerini huşuyla dinlemek için Pro\'ya geçin!',
    'اختيار أذان مكة والمدينة ومصر والإشعارات الصوتية الكاملة ميزة برو. انتقل إلى برو للاستماع بخشوع!',
  );

  // ─── Sohbet ──────────────────────────────────────────────────────────────
  String get chatAssistant => t('İmam AI Asistan', 'مساعد إمام AI');
  String get chatWelcome => t('Size nasıl yardımcı olabilirim?', 'كيف يمكنني مساعدتك؟');
  String get chatWelcomeSubtitle => t(
    'Dini sorularınızı, ibadet ve fıkıh konularını danışabilirsiniz.',
    'يمكنك طرح أسئلتك الدينية في العبادات والفقه.',
  );
  String get popularQuestions => t('Popüler Sorular', 'أسئلة شائعة');
  String get chatTyping => t('İmam AI yazıyor...', 'إمام AI يكتب...');
  String get chatDisclaimer => t(
    'Önemli dini konularda bir müftüye danışmanız tavsiye edilir.',
    'يُنصح باستشارة عالم شرعي في المسائل الدينية المهمة.',
  );
  String get chatHint => t('Bir soru sorun...', 'اطرح سؤالاً...');
  String get chatError => t(
    'Bağlantı hatası. Lütfen sunucunun açık olduğundan emin olun ve tekrar deneyin.',
    'خطأ في الاتصال. تأكد من تشغيل الخادم وحاول مرة أخرى.',
  );
  String get qAblution => t('Abdestin farzları nelerdir?', 'ما فرائض الوضوء؟');
  String get qFasting => t('Orucu bozan şeyler nelerdir?', 'ما مفطرات الصيام؟');
  String get qPrayerSurah => t('Namazda ne kadar sure okunmalı?', 'كم يُقرأ من السورة في الصلاة؟');
  String get qZakat => t('Zekat kimlere verilir?', 'لمن تُعطى الزكاة؟');
  String get qQuranRead => t('Kur\'an-ı Kerim nasıl doğru okunur?', 'كيف يُقرأ القرآن صحيحاً؟');

  // ─── Oruç ────────────────────────────────────────────────────────────────
  String get suhurTitle => t('Sahur bitiş vakti', 'وقت انتهاء السحور');
  String get suhurDesc => t('Hanefi: İmsak - Şafi: Fecr-i sâdıkta kesilir', 'حنفي: الإمساك - شافعي: ينتهي عند الفجر الصادق');
  String get iftarTitle => t('İftar vakti', 'وقت الإفطار');
  String get iftarDesc => t('Tüm mezhepler: Akşam ezanıyla birlikte', 'جميع المذاهب: مع أذان المغرب');
  String get fastingBreakers => t('Orucu bozan şeyler', 'مفطرات الصيام');
  String get fastingBreakersDesc => t('Yemek, içmek, cinsel birliktelik ve daha fazlası', 'الأكل والشرب والجماع وغيرها');
  String get chatForDetails => t('Detay için sohbet', 'تفاصيل في المحادثة');
  String get allMezheps => t('Tüm mezhepler', 'جميع المذاهب');
  String get hanefiShafi => t('Hanefi - Şafi', 'حنفي - شافعي');

  // ─── Abdest ──────────────────────────────────────────────────────────────
  String get dataLoadError => t('Veri yüklenemedi.', 'تعذر تحميل البيانات.');
  String get dataParseError => t('Veri ayrıştırılamadı.', 'تعذر تحليل البيانات.');
  String guideAsset(String baseName) =>
      isArabic ? 'assets/data/${baseName}_ar.json' : 'assets/data/$baseName.json';

  // ─── Kıble ───────────────────────────────────────────────────────────────
  String get qiblaAligned => t('Kâbe\'ye Doğru Hizalandınız!', 'أنت موجه نحو الكعبة!');
  String get qiblaFollow => t('Telefonu çevirerek yeşil oku takip edin', 'أدر الهاتف واتبع السهم الأخضر');
  String get qiblaByCity => t('Şehir konumuna göre hesaplandı', 'حُسب حسب موقع المدينة');
  String qiblaByCityNamed(String city) => t('$city konumuna göre hesaplandı', 'حُسب حسب موقع $city');
  String get qiblaByGps => t('GPS ile hesaplandı', 'حُسب عبر GPS');
  String qiblaDirection(String dir) => t('$dir · Kâbe yönü', '$dir · اتجاه الكعبة');
  String qiblaDistance(String city) => t('$city ➔ Mekke mesafesi', 'مسافة $city ➔ مكة');

  String directionName(String key) {
    switch (key) {
      case 'Kuzey':
        return t('Kuzey', 'شمال');
      case 'Doğu':
        return t('Doğu', 'شرق');
      case 'Güney':
        return t('Güney', 'جنوب');
      case 'Batı':
        return t('Batı', 'غرب');
      case 'Kuzeydoğu':
        return t('Kuzeydoğu', 'شمال شرق');
      case 'Güneydoğu':
        return t('Güneydoğu', 'جنوب شرق');
      case 'Güneybatı':
        return t('Güneybatı', 'جنوب غرب');
      case 'Kuzeybatı':
        return t('Kuzeybatı', 'شمال غرب');
      default:
        return key;
    }
  }

  // ─── Kuran ───────────────────────────────────────────────────────────────
  String get quranAudio => t('🎧 Sesli Kur\'an', '🎧 قرآن صوتي');
  String get quranText => t('📖 Yazılı Kur\'an', '📖 قرآن مكتوب');
  String get searchSurah => t('Sure ara...', 'ابحث عن سورة...');
  String surahTitle(String name) => t('$name Suresi', 'سورة $name');
  String ayetCount(int n, String type) => t('$n ayet · $type', '$n آية · $type');
  String get meccan => t('Mekki', 'مكية');
  String get medinan => t('Medeni', 'مدنية');

  // ─── Camiler ─────────────────────────────────────────────────────────────
  String get sortedByCity => t('Şehir merkezine göre sıralandı', 'مرتب حسب مركز المدينة');
  String get sortedByGps => t('Canlı GPS konumuna göre sıralandı', 'مرتب حسب GPS المباشر');
  String get mapsError => t('Harita uygulaması açılamadı. Google Maps yüklü olduğundan emin olun.', 'تعذر فتح الخريطة. تأكد من تثبيت خرائط Google.');
  String distanceLabel(String d) => t('📍 Uzaklık: $d', '📍 المسافة: $d');
  String get openMap => t('Harita', 'خريطة');
  String get enableLocation => t('Konumu etkinleştir', 'تفعيل الموقع');
  String get nearestTag => t('En yakın', 'الأقرب');
  String nearestMosqueHint(String name) =>
      t('En yakın cami: $name', 'أقرب مسجد: $name');
  String get locationAutoCity => t('Konumunuza göre şehir güncellendi', 'تم تحديث المدينة حسب موقعك');

  // ─── Zikirmatik ──────────────────────────────────────────────────────────
  String get weeklyDhikrStats => t('Haftalık Zikir İstatistiği', 'إحصاء الذكر الأسبوعي');
  String get congratulations => t('Tebrikler!', 'تهانينا!');
  String goalReached(String name) => t('$name hedefine ulaştınız.', 'بلغت هدف $name.');
  String get reset => t('Sıfırla', 'إعادة تعيين');

  List<String> get dhikrNames => isArabic
      ? ['سبحان الله', 'الحمد لله', 'الله أكبر', 'لا إله إلا الله', 'أستغفر الله']
      : ['Sübhanallah', 'Elhamdülillah', 'Allahü Ekber', 'Lâ ilâhe illallah', 'Estağfirullah'];

  List<String> get weekdayShort => isArabic
      ? ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح']
      : ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  // ─── Premium ───────────────────────────────────────────────────────────
  String get premiumTitle => t('İmam AI Pro\'ya Geç 👑', 'الترقية إلى إمام AI برو 👑');
  String get premiumWhatYouGet => t('Neler Kazanacaksınız?', 'ماذا ستحصل؟');
  String get premiumChoosePlan => t('Size En Uygun Planı Seçin', 'اختر الخطة الأنسب');
  String get activatePro => t('Şimdi Pro\'ya Geç ve Etkinleştir 👑', 'فعّل برو الآن 👑');
  String get paymentProcessing => t('Ödeme İşleniyor...', 'جاري معالجة الدفع...');
  String get dontCloseWindow => t('Lütfen pencereyi kapatmayınız', 'يرجى عدم إغلاق النافذة');
  String get congrats => t('Hayırlı Olsun! 🌟', 'مبارك! 🌟');
  String get startUsing => t('Kullanmaya Başla', 'ابدأ الاستخدام');

  // ─── Günlük paylaşım ─────────────────────────────────────────────────────
  String get dailyVerse => t('Günün Ayeti', 'آية اليوم');
  String get dailyHadith => t('Günün Hadisi', 'حديث اليوم');
  String get copyShareText => t('Paylaşım Metnini Kopyala', 'نسخ نص المشاركة');
  String get copiedToClipboard => t(
    'Metin panoya kopyalandı! İstediğiniz yerde yapıştırıp paylaşabilirsiniz.',
    'نُسخ النص! الصقه وشاركه حيث تشاء.',
  );

  // ─── Ezber ───────────────────────────────────────────────────────────────
  String get tapMicToStart => t('Sureyi okumaya başlamak için mikrofona basın', 'اضغط الميكروفون لبدء قراءة السورة');
  String get listeningStarted => t('🎙️ Dinleme başlatıldı. Okuyun...', '🎙️ بدأ الاستماع. اقرأ...');
  String get tajweedError => t('⚠️ Mahreç hatası algılandı! Tekrar okuyun...', '⚠️ خطأ في التجويد! أعد القراءة...');
  String get tajweedGood => t('🎙️ Harika, doğru mahreç. Devam edin...', '🎙️ ممتاز، تجويد صحيح. تابع...');
  String get surahCompleted => t('Sure tamamlandı!', 'اكتملت السورة!');
  String get memorizeReport => t('Ezber Analiz Raporu', 'تقرير تحليل الحفظ');
  String get selectSurahToMemorize => t('Ezberlemek istediğiniz sureyi seçin', 'اختر السورة للحفظ');

  // ─── Takipçi ─────────────────────────────────────────────────────────────
  String get trackWeekly => t('Bu Haftaki İbadetlerinizi Takip Edin', 'تابع عباداتك هذا الأسبوع');
  String get worship => t('İbadet', 'عبادة');
  String get weeklyAnalysis => t('Haftalık İbadet Analizi', 'تحليل العبادة الأسبوعي');
  String get getAiReport => t('AI Raporu Al', 'احصل على تقرير ذكاء اصطناعي');
  String weeklyScore(int p) => t('Haftalık Başarı Skoru: %$p', 'نسبة النجاح الأسبوعية: %$p');
  String get aiDetailedView => t('AI ile Detaylı Görüş', 'رأي مفصل بالذكاء الاصطناعي');

  List<String> get trackerTasks => isArabic
      ? ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء', 'قراءة القرآن']
      : ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı', 'Kuran Okuma'];

  // ─── Zekat ───────────────────────────────────────────────────────────────
  String get zakatCalculator => t('Zekat Hesaplayıcı', 'حاسبة الزكاة');
  String stepOf(int n) => t('Adım $n/4', 'الخطوة $n/4');
  String get calculate => t('Hesapla', 'احسب');
  String get zakatReport => t('Zekat Sonuç Raporu', 'تقرير نتيجة الزكاة');
  String get zakatObligatory => t('Zekat Vermeniz Farzdır', 'الزكاة واجبة عليك');
  String get zakatNotObligatory => t('Zekat Yükümlülüğünüz Bulunmuyor', 'لا تجب عليك الزكاة');
  String get recalculate => t('Yeniden Hesapla', 'إعادة الحساب');
}
