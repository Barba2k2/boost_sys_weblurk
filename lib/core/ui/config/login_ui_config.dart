import 'package:flutter/foundation.dart';

class LoginUiConfig {
  // Flags para otimização Android
  static const bool enableAndroidOptimization = true;

  // Configurações de altura da logo
  static const double androidLogoHeight = 120.0;
  static const double desktopLogoHeight = 200.0;

  // Configurações de tamanho de fonte do título principal
  static const double androidTitleFontSize = 28.0;
  static const double desktopTitleFontSize = 36.0;

  // Configurações de tamanho de fonte do subtítulo
  static const double androidSubtitleFontSize = 16.0;
  static const double desktopSubtitleFontSize = 20.0;

  // Configurações de tamanho de fonte do título do formulário
  static const double androidFormTitleFontSize = 22.0;
  static const double desktopFormTitleFontSize = 28.0;

  // Configurações de espaçamento vertical
  static const double androidVerticalSpacing = 24.0;
  static const double desktopVerticalSpacing = 40.0;

  // Configurações de padding horizontal
  static const double androidHorizontalPadding = 20.0;
  static const double desktopHorizontalPadding = 30.0;

  // Configurações de padding vertical
  static const double androidVerticalPadding = 24.0;
  static const double desktopVerticalPadding = 40.0;

  // Configurações de espaçamento entre elementos
  static const double androidElementSpacing = 16.0;
  static const double desktopElementSpacing = 24.0;

  // Configurações de espaçamento pequeno
  static const double androidSmallSpacing = 8.0;
  static const double desktopSmallSpacing = 10.0;

  // Configurações de espaçamento muito pequeno
  static const double androidTinySpacing = 4.0;
  static const double desktopTinySpacing = 8.0;

  // Configurações de letter spacing
  static const double androidTitleLetterSpacing = 2.0;
  static const double desktopTitleLetterSpacing = 3.0;

  static const double androidSubtitleLetterSpacing = 1.5;
  static const double desktopSubtitleLetterSpacing = 2.0;

  static const double androidFormTitleLetterSpacing = 1.0;
  static const double desktopFormTitleLetterSpacing = 1.5;

  // Métodos para obter valores baseados na plataforma
  static double getLogoHeight() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidLogoHeight
        : desktopLogoHeight;
  }

  static double getTitleFontSize() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidTitleFontSize
        : desktopTitleFontSize;
  }

  static double getSubtitleFontSize() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidSubtitleFontSize
        : desktopSubtitleFontSize;
  }

  static double getFormTitleFontSize() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidFormTitleFontSize
        : desktopFormTitleFontSize;
  }

  static double getVerticalSpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidVerticalSpacing
        : desktopVerticalSpacing;
  }

  static double getHorizontalPadding() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidHorizontalPadding
        : desktopHorizontalPadding;
  }

  static double getVerticalPadding() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidVerticalPadding
        : desktopVerticalPadding;
  }

  static double getElementSpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidElementSpacing
        : desktopElementSpacing;
  }

  static double getSmallSpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidSmallSpacing
        : desktopSmallSpacing;
  }

  static double getTinySpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidTinySpacing
        : desktopTinySpacing;
  }

  static double getTitleLetterSpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidTitleLetterSpacing
        : desktopTitleLetterSpacing;
  }

  static double getSubtitleLetterSpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidSubtitleLetterSpacing
        : desktopSubtitleLetterSpacing;
  }

  static double getFormTitleLetterSpacing() {
    return defaultTargetPlatform == TargetPlatform.android &&
            enableAndroidOptimization
        ? androidFormTitleLetterSpacing
        : desktopFormTitleLetterSpacing;
  }
}
