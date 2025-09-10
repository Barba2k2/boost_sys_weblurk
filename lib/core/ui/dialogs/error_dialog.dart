import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Error dialog
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? technicalDetails;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.technicalDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cosmicNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColors.cosmicBorder,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cosmicNavy,
              AppColors.cosmicBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cosmicBorder.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cosmicButtonStart,
                    AppColors.cosmicButtonEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cosmicAccent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.cosmicAccent,
                fontFamily: 'Ibrand',
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
                fontFamily: 'Ibrand',
              ),
            ),

            // Technical details (if provided)
            if (technicalDetails != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cosmicDarkPurple.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.cosmicBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalhes técnicos:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        fontFamily: 'Ibrand',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technicalDetails!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Close button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.cosmicButtonStart,
                      AppColors.cosmicButtonEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cosmicAccent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Ibrand',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
