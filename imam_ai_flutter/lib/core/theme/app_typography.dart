import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Başlıklar — Poppins SemiBold
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.neutral900,
  );
  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.neutral900,
  );
  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.neutral900,
  );

  // Gövde — Lora
  static TextStyle body = GoogleFonts.lora(
    fontSize: 18, fontWeight: FontWeight.w500,
    color: AppColors.neutral800, height: 1.65,
  );
  static TextStyle bodySmall = GoogleFonts.lora(
    fontSize: 15, fontWeight: FontWeight.w500,
    color: AppColors.neutral600, height: 1.5,
  );

  // Navigasyon ve etiketler — Poppins Medium
  static TextStyle label = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.neutral500,
  );
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.neutral400,
  );

  // Vakit sayıları — Poppins Bold
  static TextStyle clock = GoogleFonts.poppins(
    fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.white,
    letterSpacing: 1.5,
  );
  static TextStyle clockSmall = GoogleFonts.poppins(
    fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.white,
  );

  // Arapça — Scheherazade New (Asset)
  static TextStyle arabic = const TextStyle(
    fontFamily: 'ScheherazadeNew',
    fontSize: 30, fontWeight: FontWeight.w400,
    color: AppColors.primary, height: 1.8,
  );
  static TextStyle arabicLarge = const TextStyle(
    fontFamily: 'ScheherazadeNew',
    fontSize: 38, fontWeight: FontWeight.w400,
    color: AppColors.white, height: 2.0,
  );

  // Chat baloncuk metni
  static TextStyle chatText = GoogleFonts.lora(
    fontSize: 18, fontWeight: FontWeight.w500,
    color: AppColors.neutral800, height: 1.55,
  );
  static TextStyle chatTime = GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.neutral400,
  );
}
