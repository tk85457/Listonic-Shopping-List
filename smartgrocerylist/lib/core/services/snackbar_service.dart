import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackbarService {
  static void _show({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String message,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      boxShadows: [
        BoxShadow(
          color: bgColor.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static void showSuccess(String title, String message) => _show(
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF4ADE80),
        bgColor: const Color(0xFF166534),
        title: title,
        message: message,
      );

  static void showError(String title, String message) => _show(
        icon: Icons.error_rounded,
        iconColor: const Color(0xFFF87171),
        bgColor: const Color(0xFF7F1D1D),
        title: title,
        message: message,
      );

  static void showWarning(String title, String message) => _show(
        icon: Icons.warning_rounded,
        iconColor: const Color(0xFFFBBF24),
        bgColor: const Color(0xFF78350F),
        title: title,
        message: message,
      );

  static void showInfo(String title, String message) => _show(
        icon: Icons.info_rounded,
        iconColor: const Color(0xFF60A5FA),
        bgColor: const Color(0xFF1E3A5F),
        title: title,
        message: message,
      );

  static void showSimple(String message) => _show(
        icon: Icons.notifications_rounded,
        iconColor: Colors.white,
        bgColor: const Color(0xFF1C1C2E),
        title: message,
        message: '',
      );
}

