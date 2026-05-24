import 'package:flutter/material.dart';

class AppColors {
  // Primary — verde tobacco de Pinar del Río
  static const Color primary = Color(0xFF0D631B);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFCBFFC2);
  static const Color inversePrimary = Color(0xFF88D982);

  // Secondary — azul suave
  static const Color secondary = Color(0xFF0060AC);
  static const Color secondaryContainer = Color(0xFF68ABFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF003E73);

  // Surface — beige cálido
  static const Color surface = Color(0xFFFDF8FD);
  static const Color surfaceDim = Color(0xFFDDD9DE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F2F8);
  static const Color surfaceContainer = Color(0xFFF1ECF2);
  static const Color surfaceContainerHigh = Color(0xFFEBE7EC);
  static const Color surfaceContainerHighest = Color(0xFFE5E1E7);

  // On-surface
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF40493D);
  static const Color inverseSurface = Color(0xFF313034);
  static const Color inverseOnSurface = Color(0xFFF4EFF5);

  // Outline
  static const Color outline = Color(0xFF707A6C);
  static const Color outlineVariant = Color(0xFFBFCABA);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Aliases legacy (no borrar — los usan páginas viejas)
  static const Color background = surface;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textOnPrimary = onPrimary;
  static const Color success = Color(0xFF1B6D24);
  static const Color warning = Color(0xFFF9A825);
  static const Color border = outlineVariant;
  static const Color divider = surfaceContainerHigh;
  static const Color shadow = Color(0x14000000);
  static const Color surfaceVariant = surfaceContainerLow;

  // Stock
  static const Color stockAlto = Color(0xFF1B6D24);
  static const Color stockMedio = Color(0xFFF9A825);
  static const Color stockBajo = Color(0xFFE65100);
  static const Color stockAgotado = Color(0xFFBA1A1A);
}
