import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/update_progress_model.dart';
import '../app_colors.dart';

/// Dialog showing download progress
class DownloadProgressDialog extends StatelessWidget {
  final ValueListenable<UpdateProgressModel> progressNotifier;

  const DownloadProgressDialog({
    super.key,
    required this.progressNotifier,
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
        padding: const EdgeInsets.all(32),
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
        child: ValueListenableBuilder<UpdateProgressModel>(
          valueListenable: progressNotifier,
          builder: (context, progress, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cosmicButtonStart,
                        AppColors.cosmicButtonEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cosmicAccent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          value:
                              progress.showDeterminate ? progress.value : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.cosmicAccent,
                          ),
                          backgroundColor:
                              AppColors.cosmicAccent.withValues(alpha: 0.2),
                        ),
                      ),
                      Icon(
                        progress.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  progress.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cosmicAccent,
                    fontFamily: 'Ibrand',
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  progress.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                    fontFamily: 'Ibrand',
                  ),
                ),
                const SizedBox(height: 20),

                // Linear progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.cosmicAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.cosmicBorder,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.showDeterminate ? progress.value : null,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.cosmicAccent,
                      ),
                    ),
                  ),
                ),
                if (progress.showPercentage) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${(progress.value * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cosmicAccent,
                      fontFamily: 'Ibrand',
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
