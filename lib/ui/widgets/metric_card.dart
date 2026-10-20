import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final double? progress;
  final Color progressColor;
  final IconData? icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle = '',
    this.progress,
    this.progressColor = AppColors.cyanAccent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: progressColor, size: 22),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  minHeight: 6,
                  color: progressColor,
                  backgroundColor: AppColors.darkBackground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
