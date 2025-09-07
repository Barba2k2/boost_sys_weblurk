import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/timezone_service.dart';
import '../app_colors.dart';
import '../widgets/messages.dart';

/// Dialog for selecting timezone
class TimezoneDialog extends StatefulWidget {
  final TimezoneService timezoneService;
  final String currentTimezone;

  const TimezoneDialog({
    super.key,
    required this.timezoneService,
    required this.currentTimezone,
  });

  @override
  State<TimezoneDialog> createState() => _TimezoneDialogState();
}

class _TimezoneDialogState extends State<TimezoneDialog> {
  late String _selectedTimezone;

  @override
  void initState() {
    super.initState();
    _selectedTimezone = widget.currentTimezone;
  }

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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cosmicButtonStart,
                        AppColors.cosmicButtonEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cosmicAccent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.schedule,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fuso Horário',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cosmicAccent,
                          fontFamily: 'Ibrand',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Selecione seu fuso horário local para converter para horário do Brasil',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Ibrand',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Current timezone info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cosmicDarkPurple.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cosmicBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cosmicAccent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seu Fuso Horário Local:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cosmicAccent,
                      fontFamily: 'Ibrand',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.timezoneService.getTimezoneName(_selectedTimezone),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Ibrand',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Será convertido para horário do Brasil (GMT-3)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Ibrand',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Timezone list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: TimezoneService.availableTimezones.length,
                itemBuilder: (context, index) {
                  final timezone = TimezoneService.availableTimezones[index];
                  final isSelected = _selectedTimezone == timezone['id'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTimezone = timezone['id']!;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.cosmicAccent.withValues(alpha: 0.2)
                              : AppColors.cosmicDarkPurple
                                  .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.cosmicAccent
                                : AppColors.cosmicBorder.withValues(alpha: 0.5),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.cosmicAccent
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Selection indicator
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.cosmicAccent
                                      : AppColors.cosmicBorder,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? AppColors.cosmicAccent
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),

                            // Timezone icon
                            Icon(
                              _getTimezoneIcon(timezone['id']!),
                              size: 20,
                              color: isSelected
                                  ? AppColors.cosmicAccent
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 12),

                            // Timezone info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timezone['name']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.cosmicAccent
                                          : Colors.white,
                                      fontFamily: 'Ibrand',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'GMT ${timezone['offset']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontFamily: 'Ibrand',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(
                        color: AppColors.cosmicBorder,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Ibrand',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                      onPressed: () async {
                        try {
                          await widget.timezoneService
                              .setSelectedTimezone(_selectedTimezone);
                          if (mounted) {
                            context.pop(_selectedTimezone);
                          }
                        } catch (e) {
                          if (mounted) {
                            Messages.error('Erro ao salvar fuso horário: $e');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
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
          ],
        ),
      ),
    );
  }

  IconData _getTimezoneIcon(String timezoneId) {
    // All GMT offsets use the same icon
    return Icons.schedule;
  }
}
