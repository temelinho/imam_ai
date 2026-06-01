import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';

class ZekatScreen extends StatefulWidget {
  const ZekatScreen({super.key});

  @override
  State<ZekatScreen> createState() => _ZekatScreenState();
}

class _ZekatScreenState extends State<ZekatScreen> {
  int _currentStep = 0; // 0 to 4 (4 is result screen)
  
  // Input controllers
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _investmentsController = TextEditingController();
  final TextEditingController _debtsController = TextEditingController();

  final double _nisapLimit = 250000.0; // Simulated Nisap value in TL

  double _totalAssets = 0.0;
  double _debtsVal = 0.0;
  double _netWealth = 0.0;
  double _zekatToPay = 0.0;
  bool _isEligible = false;

  @override
  void dispose() {
    _cashController.dispose();
    _goldController.dispose();
    _investmentsController.dispose();
    _debtsController.dispose();
    super.dispose();
  }

  void _calculateZekat() {
    double cash = double.tryParse(_cashController.text.trim()) ?? 0.0;
    double gold = double.tryParse(_goldController.text.trim()) ?? 0.0;
    double investments = double.tryParse(_investmentsController.text.trim()) ?? 0.0;
    double debts = double.tryParse(_debtsController.text.trim()) ?? 0.0;

    double assets = cash + gold + investments;
    double net = assets - debts;

    setState(() {
      _totalAssets = assets;
      _debtsVal = debts;
      _netWealth = net;
      _isEligible = net >= _nisapLimit;
      _zekatToPay = _isEligible ? (net * 0.025) : 0.0;
      _currentStep = 4; // Move to result screen
    });
  }

  void _reset() {
    setState(() {
      _cashController.clear();
      _goldController.clear();
      _investmentsController.clear();
      _debtsController.clear();
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (_currentStep < 4) ...[
            // Progress Indicator text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Zekat Hesaplayıcı · Adım ${_currentStep + 1}/4',
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Nisap: 250.000 TL',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 4.0,
                color: AppColors.primary,
                backgroundColor: AppColors.surface2,
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 20),
            // Wizard Steps content
            _buildStepContent(),
            const SizedBox(height: 24),
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Opacity(
                  opacity: _currentStep > 0 ? 1.0 : 0.0,
                  child: ElevatedButton(
                    onPressed: _currentStep > 0
                        ? () => setState(() => _currentStep--)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(110, 44),
                    ),
                    child: const Text(
                      'Geri',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                ),
                // Next / Calculate Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 3) {
                      _calculateZekat();
                    } else {
                      setState(() => _currentStep++);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(130, 44),
                  ),
                  child: Text(
                    _currentStep == 3 ? 'Hesapla' : 'İleri',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildResultContent(),
          ]
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    String title = '';
    String helperText = '';
    TextEditingController activeController;
    IconData icon;

    switch (_currentStep) {
      case 0:
        title = 'Nakit ve Banka';
        helperText = 'Elinizdeki nakit parayı ve banka hesaplarınızda bulunan toplam birikiminizi TL cinsinden giriniz.';
        activeController = _cashController;
        icon = Icons.account_balance_wallet_outlined;
        break;
      case 1:
        title = 'Altın ve Gümüş';
        helperText = 'Zekata tabi olan altın ve gümüş varlıklarınızın toplam piyasa değerini TL cinsinden giriniz.';
        activeController = _goldController;
        icon = Icons.generating_tokens_outlined;
        break;
      case 2:
        title = 'Yatırım ve Hisseler';
        helperText = 'Hisse senetleri, fonlar, ticari mallar ve diğer yatırım araçlarınızın değerini TL cinsinden giriniz.';
        activeController = _investmentsController;
        icon = Icons.show_chart;
        break;
      case 3:
      default:
        title = 'Borçlar ve Giderler';
        helperText = 'Ödemeniz gereken borçlarınızı veya zekattan düşülecek olan zorunlu giderlerinizi giriniz.';
        activeController = _debtsController;
        icon = Icons.money_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            helperText,
            style: const TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.45),
          ),
          const SizedBox(height: 20),
          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: TextField(
              controller: activeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '0.00 TL',
                border: InputBorder.none,
                suffixText: 'TL',
                suffixStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final currencyFormat = NumberFormat('#,##0.00', 'tr_TR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zekat Sonuç Raporu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        // Main Result Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isEligible ? AppColors.cardBorder : Colors.orange.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isEligible ? 'Zekat Vermeniz Farzdır' : 'Zekat Yükümlülüğünüz Bulunmuyor',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: _isEligible ? AppColors.primary : Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 12),
              if (_isEligible) ...[
                const Text(
                  'Ödenmesi Gereken Zekat Tutarı',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                Text(
                  '${currencyFormat.format(_zekatToPay)} TL',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ] else ...[
                Text(
                  'Net birikiminiz (${currencyFormat.format(_netWealth)} TL), nisap miktarının (250.000,00 TL) altında kaldığı için zekat vermeniz farz değildir.',
                  style: const TextStyle(fontSize: 13.5, height: 1.45, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Breakdown bar chart if eligible
        if (_isEligible) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Varlık - Borç Dağılımı',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                // Custom double bars
                _buildProgressBar(
                  label: 'Zekata Tabi Toplam Varlık',
                  value: _totalAssets,
                  color: AppColors.primary,
                  max: _totalAssets,
                  currencyFormat: currencyFormat,
                ),
                const SizedBox(height: 12),
                _buildProgressBar(
                  label: 'Düşülen Borç/Giderler',
                  value: _debtsVal,
                  color: Colors.red.shade700,
                  max: _totalAssets,
                  currencyFormat: currencyFormat,
                ),
                const SizedBox(height: 12),
                _buildProgressBar(
                  label: 'Zekat Hesabına Esas Net Varlık',
                  value: _netWealth,
                  color: AppColors.primaryLight,
                  max: _totalAssets,
                  currencyFormat: currencyFormat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Reset/Recalculate Button
        ElevatedButton(
          onPressed: _reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            'Yeniden Hesapla',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double value,
    required Color color,
    required double max,
    required NumberFormat currencyFormat,
  }) {
    double ratio = max > 0 ? (value / max) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
            Text('${currencyFormat.format(value)} TL', style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            color: color,
            backgroundColor: AppColors.surface2,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
