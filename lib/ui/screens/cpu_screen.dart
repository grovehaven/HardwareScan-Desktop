import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class CpuScreen extends StatelessWidget {
  final CpuSnapshot? cpu;

  const CpuScreen({super.key, required this.cpu});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Central Processing Unit (CPU)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          cpu?.model ?? 'Scanning...',
          style: const TextStyle(
            color: AppColors.cyanAccent,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Processor Specifications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                InfoRow(label: 'Manufacturer / Vendor', value: cpu?.vendor ?? 'N/A'),
                InfoRow(label: 'Microarchitecture', value: cpu?.architecture ?? 'ARM64 / x86_64'),
                InfoRow(label: 'Physical Sockets', value: '${cpu?.sockets ?? 1}'),
                InfoRow(label: 'Physical Cores', value: '${cpu?.physicalCores ?? 0}'),
                InfoRow(label: 'Logical Processors (Threads)', value: '${cpu?.logicalCores ?? 0}'),
                InfoRow(label: 'CPU Family / Stepping', value: '${cpu?.family ?? "N/A"} (${cpu?.stepping ?? "N/A"})'),
                InfoRow(label: 'Processor ID / ABI', value: cpu?.processorId ?? 'N/A'),
                InfoRow(label: '64-Bit Instruction Set', value: cpu?.is64Bit == true ? 'Yes (64-Bit)' : 'No'),
                if (cpu != null && cpu!.temperatureCelsius > 0)
                  InfoRow(label: 'CPU Temperature', value: '${cpu!.temperatureCelsius.toStringAsFixed(1)} °C'),
                if (cpu != null && cpu!.voltageVolts > 0)
                  InfoRow(label: 'CPU Core Voltage', value: '${cpu!.voltageVolts.toStringAsFixed(2)} V'),
              ],
            ),
          ),
        ),
        if (cpu != null && cpu!.coreLoads.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Per-Core Real-Time Utilization',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: cpu!.coreLoads.length,
            itemBuilder: (context, index) {
              final load = cpu!.coreLoads[index];
              final freq = cpu!.coreFrequenciesGhz.length > index ? cpu!.coreFrequenciesGhz[index] : 0.0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Core $index',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${load.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (freq > 0)
                        Text(
                          '${freq.toStringAsFixed(2)} GHz',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (load / 100.0).clamp(0.0, 1.0),
                          minHeight: 4,
                          color: load > 80 ? AppColors.redAccent : AppColors.cyanAccent,
                          backgroundColor: AppColors.darkBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
