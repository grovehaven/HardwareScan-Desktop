import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';
import '../widgets/metric_card.dart';

class MemoryScreen extends StatelessWidget {
  final MemorySnapshot? mem;

  const MemoryScreen({super.key, required this.mem});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Memory & RAM Architecture',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int count = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 400 ? 2 : 1);
            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                MetricCard(
                  title: 'Physical RAM Installed',
                  value: '${mem?.totalGb.toStringAsFixed(1) ?? "0"} GB',
                  subtitle: 'Total Unified Memory',
                  progressColor: AppColors.cyanAccent,
                  icon: Icons.memory,
                ),
                MetricCard(
                  title: 'RAM In Use',
                  value: '${mem?.usedGb.toStringAsFixed(1) ?? "0"} GB',
                  subtitle: '${mem?.usagePercent.toStringAsFixed(1) ?? "0"}% utilized',
                  progress: (mem?.usagePercent ?? 0.0) / 100.0,
                  progressColor: AppColors.blueAccent,
                  icon: Icons.storage,
                ),
                MetricCard(
                  title: 'Available Memory',
                  value: '${mem?.availableGb.toStringAsFixed(1) ?? "0"} GB',
                  subtitle: 'Ready for allocation',
                  progressColor: AppColors.greenAccent,
                  icon: Icons.check_circle,
                ),
                MetricCard(
                  title: 'Virtual / Swap Memory',
                  value: '${mem?.swapTotalGb.toStringAsFixed(1) ?? "0"} GB',
                  subtitle: '${mem?.swapUsedGb.toStringAsFixed(1) ?? "0"} GB committed',
                  progressColor: AppColors.purpleAccent,
                  icon: Icons.folder,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Physical Memory Banks & Channels',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (mem != null && mem!.physicalSticks.isNotEmpty)
          ...mem!.physicalSticks.map(
            (stick) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stick.bankLabel,
                          style: const TextStyle(
                            color: AppColors.cyanAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${stick.capacityGb.toStringAsFixed(1)} GB ${stick.memoryType}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 6),
                    InfoRow(label: 'Manufacturer', value: stick.manufacturer),
                    InfoRow(label: 'Clock Speed / Frequency', value: '${stick.clockSpeedMhz} MHz (MT/s)'),
                    InfoRow(label: 'Memory Architecture', value: stick.memoryType),
                  ],
                ),
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Memory bank telemetry managed by OS hardware abstract layer.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
