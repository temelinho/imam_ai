import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../l10n/l10n_scope.dart';

class AbdestScreen extends StatelessWidget {
  final String selectedMezhep;

  const AbdestScreen({
    super.key,
    required this.selectedMezhep,
  });

  bool _isFarz(String title, String description, String? note) {
    final lowerTitle = title.toLowerCase();
    final lowerDesc = description.toLowerCase();
    final lowerNote = (note ?? '').toLowerCase();
    return lowerTitle.contains('farz') ||
        lowerDesc.contains('farzdır') ||
        lowerNote.contains('farzdır') ||
        lowerNote.contains('farz kabul');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nScope.of(context);
    final guidePath = l10n.guideAsset('guide_abdest');

    return Column(
      children: [
        // Sub-header for current Mezhep
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Text(
              l10n.mezhepBadge(l10n.mezhepName(selectedMezhep)),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
        // Step List
        Expanded(
          child: FutureBuilder<String>(
            future: DefaultAssetBundle.of(context).loadString(guidePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text(l10n.dataLoadError));
              }

              try {
                final Map<String, dynamic> rawJson = jsonDecode(snapshot.data!);
                final List<dynamic> steps = rawJson[selectedMezhep] ?? rawJson['Hanefi'] ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index] as Map<String, dynamic>;
                    final stepNumber = step['stepNumber'] ?? (index + 1);
                    final title = step['title'] ?? '';
                    final description = step['description'] ?? '';
                    final arabicText = step['arabicText'] as String?;
                    final note = step['note'] as String?;
                    final isFarzStep = _isFarz(title, description, note);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Circular Step Badge (32x32)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              stepNumber.toString(),
                              style: const TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                ),
                                if (arabicText != null && arabicText.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.scaffoldBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      arabicText,
                                      style: AppTypography.arabic.copyWith(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                                if (note != null && note.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    note,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Farz or Sunnet Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCF5EC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isFarzStep ? l10n.farz : l10n.sunnet,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } catch (e) {
                return Center(child: Text(l10n.dataParseError));
              }
            },
          ),
        ),
      ],
    );
  }
}
