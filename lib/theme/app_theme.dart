// lib/theme/app_theme.dart
//
// Tema global do app. Use AppTheme.colors para acessar as cores
// e AppTheme.data para configurar o MaterialApp.

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F1117);
  static const card = Color(0xFF1A1D27);
  static const accent = Color(0xFF00E5A0);
  static const accentDim = Color(0x2200E5A0);
  static const danger = Color(0xFFFF4D6A);
  static const textPrimary = Color(0xFFEEEEF5);
  static const textMuted = Color(0xFF6B7280);
  static const divider = Color(0x0FFFFFFF); // white 6%
  static const border = Color(0x0DFFFFFF); // white 5%

  // Status
  static const statusSolicitado = Color(0xFFFFB347);
  static const statusEmSelecao = Color(0xFF00E5A0);
  static const statusAprovado = Color(0xFF00E5A0);
  static const statusCancelado = Color(0xFFFF4D6A);
  static const statusRecusado = Color(0xFFFF4D6A);
  static const statusFinalizado = Color(0xFF6B7280);

  static Color forStatus(String status) {
    switch (status) {
      case 'solicitado':
        return statusSolicitado;
      case 'em_selecao':
        return statusEmSelecao;
      case 'aprovado':
        return statusAprovado;
      case 'cancelado':
        return statusCancelado;
      case 'recusado':
        return statusRecusado;
      case 'finalizado':
        return statusFinalizado;
      default:
        return textMuted;
    }
  }
}

class AppTheme {
  static final data = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(color: AppColors.textMuted),
    ),

    // Drawer
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.card),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(color: AppColors.divider),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textMuted,
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
    ),

    // CheckboxTheme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.accent;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.background),
      side: const BorderSide(color: AppColors.textMuted),
    ),

    // ProgressIndicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),

    // DropdownMenu
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.card),
      ),
    ),

    // Text
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textMuted),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(color: AppColors.textMuted),
    ),
  );
}

/// Badge de status reutilizável (ex: 'solicitado', 'aprovado')
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge de accent (ex: nome da função, role do usuário)
class AccentBadge extends StatelessWidget {
  final String label;
  const AccentBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
