import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import 'info_row.dart';

class UpgradeCard extends StatelessWidget {
  final IconData icon;
  final UpgradeRecommendation recommendation;

  const UpgradeCard({
    super.key,
    required this.icon,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (recommendation.status) {
      UpgradeStatus.CRITICAL_UPGRADE => AppColors.redAccent,
      UpgradeStatus.RECOMMENDED => AppColors.orangeAccent,
      UpgradeStatus.OPTIONAL => AppColors.blueAccent,
      UpgradeStatus.OPTIMAL => AppColors.greenAccent,
    };

    final badgeText = switch (recommendation.status) {
      UpgradeStatus.CRITICAL_UPGRADE => 'CRITICAL UPGRADE',
      UpgradeStatus.RECOMMENDED => 'RECOMMENDED UPGRADE',
      UpgradeStatus.OPTIONAL => 'OPTIONAL / EXPANSION',
      UpgradeStatus.OPTIMAL => 'OPTIMAL HARDWARE',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.cyanAccent, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      recommendation.category,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              recommendation.headline,
              style: const TextStyle(
                color: AppColors.cyanAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            InfoRow(label: 'Current Detected Hardware', value: recommendation.currentHardware),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECOMMENDED UPGRADE PATH:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.recommendedAction,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'EXPECTED PERFORMANCE GAIN:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation.expectedImpact,
                    style: const TextStyle(color: AppColors.greenAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (recommendation.technicalDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Technical & Compatibility Details:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...recommendation.technicalDetails.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: AppColors.cyanAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          detail,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
