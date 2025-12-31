import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {

  bool get isDarkMode =>
      Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get textMuted =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textMuted;

  Color get textOnPrimary => AppColors.textOnPrimary;

  Color get background =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get surface =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;

  Color get surfaceVariant =>
      isDarkMode ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

  Color get inputFill =>
      isDarkMode ? AppColors.darkSurfaceVariant : AppColors.inputFill;

  Color get border =>
      isDarkMode ? AppColors.darkBorder : AppColors.border;

  Color get divider =>
      isDarkMode ? AppColors.darkBorder : AppColors.divider;

  List<BoxShadow> get cardShadow => AppColors.cardShadow;

  List<BoxShadow> get buttonShadow => AppColors.buttonShadow;
}
