import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  final CpuSnapshot? cpu;
  final MemorySnapshot? mem;
  final SystemOverview? sys;
  final BatterySnapshot? battery;
  final List<GpuSnapshot> gpus;
  final List<PartitionSnapshot> partitions;
  final VoidCallback onOpenUpgrades;

  const DashboardScreen({
    super.key,
    required this.cpu,
    required this.mem,
    required this.sys,
    required this.battery,
    required this.gpus,
    required this.partitions,
    required this.onOpenUpgrades,
  });

  @override
  Widget build(BuildContext context) {
    final primaryDrive = partitions.isNotEmpty ? partitions.first : null;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hardware Diagnostics',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Real-time telemetry and component inspection',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onOpenUpgrades,
              icon: const Icon(Icons.trending_up, size: 18),
              label: const Text('Upgrade Path', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanAccent,
                foregroundColor: AppColors.darkBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 400 ? 2 : 1);
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                MetricCard(
                  title: 'CPU Utilization',
                  value: '${(cpu?.totalLoadPercent ?? 0.0).toStringAsFixed(1)}%',
                  subtitle: cpu?.model ?? 'Scanning...',
                  progress: (cpu?.totalLoadPercent ?? 0.0) / 100.0,
                  progressColor: AppColors.cyanAccent,
                  icon: Icons.memory,
                ),
                MetricCard(
                  title: 'RAM Usage',
                  value: '${(mem?.usagePercent ?? 0.0).toStringAsFixed(1)}%',
                  subtitle: '${mem?.usedGb.toStringAsFixed(1) ?? "0"} / ${mem?.totalGb.toStringAsFixed(1) ?? "0"} GB',
                  progress: (mem?.usagePercent ?? 0.0) / 100.0,
                  progressColor: AppColors.blueAccent,
                  icon: Icons.storage,
                ),
                MetricCard(
                  title: 'Primary Storage',
                  value: '${(primaryDrive?.usagePercent ?? 0.0).toStringAsFixed(1)}%',
                  subtitle: '${primaryDrive?.freeGb.toStringAsFixed(1) ?? "0"} GB free',
                  progress: (primaryDrive?.usagePercent ?? 0.0) / 100.0,
                  progressColor: AppColors.orangeAccent,
                  icon: Icons.folder,
                ),
                if (battery?.isPresent == true)
                  MetricCard(
                    title: 'Battery',
                    value: '${battery?.remainingPercent.toStringAsFixed(0)}%',
                    subtitle: battery?.isCharging == true ? 'Charging (AC)' : 'On Battery (${battery?.estimatedTimeRemaining})',
                    progress: (battery?.remainingPercent ?? 0.0) / 100.0,
                    progressColor: AppColors.greenAccent,
                    icon: Icons.battery_charging_full,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Summary',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                InfoRow(label: 'Operating System', value: sys?.osName ?? 'N/A'),
                InfoRow(label: 'OS Build / Kernel', value: sys?.osBuild ?? 'N/A'),
                InfoRow(label: 'Manufacturer & Model', value: '${sys?.motherboardManufacturer ?? ""} ${sys?.motherboardModel ?? ""}'),
                InfoRow(label: 'Primary GPU Acceleration', value: gpus.isNotEmpty ? gpus.first.name : 'N/A'),
                InfoRow(label: 'Firmware / Board', value: sys?.biosManufacturer ?? 'N/A'),
                InfoRow(label: 'System Boot Time', value: sys?.bootTime ?? 'N/A'),
                InfoRow(label: 'Uptime', value: '${sys?.uptimeHours ?? 0} Hours'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
