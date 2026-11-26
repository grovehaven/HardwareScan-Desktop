import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class CpuScreen extends StatelessWidget {
  final CpuSnapshot? cpu;

  const CpuScreen({super.key, required this.cpu});

  @override
  Widget build(BuildContext context) {
    final totalCores = cpu?.logicalCores ?? Platform.numberOfProcessors;

    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Central Processing Unit (CPU)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  cpu?.model ?? 'Scanning...',
                  style: const TextStyle(
                    color: AppColors.cyanAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cyanAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cyanAccent.withOpacity(0.4)),
              ),
              child: Text(
                '$totalCores CPU Cores Active',
                style: const TextStyle(
                  color: AppColors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth > 500 ? 240.0 : 180.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Processor Specifications',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 4),
                    InfoRow(label: 'Manufacturer / Vendor', value: cpu?.vendor ?? 'N/A', labelWidth: width),
                    InfoRow(label: 'Microarchitecture', value: cpu?.architecture ?? 'ARM64 / x86_64', labelWidth: width),
                    InfoRow(label: 'Physical Sockets', value: '${cpu?.sockets ?? 1}', labelWidth: width),
                    InfoRow(label: 'Physical Cores', value: '${cpu?.physicalCores ?? totalCores}', labelWidth: width),
                    InfoRow(label: 'Logical Processors (Threads)', value: '$totalCores', labelWidth: width),
                    InfoRow(label: 'CPU Family / Stepping', value: '${cpu?.family ?? "N/A"} (${cpu?.stepping ?? "N/A"})', labelWidth: width),
                    InfoRow(label: 'Processor ID / ABI', value: cpu?.processorId ?? 'N/A', labelWidth: width),
                    InfoRow(label: '64-Bit Instruction Set', value: cpu?.is64Bit == true ? 'Yes (64-Bit)' : 'No', labelWidth: width),
                    if (cpu != null && cpu!.temperatureCelsius > 0)
                      InfoRow(label: 'CPU Temperature', value: '${cpu!.temperatureCelsius.toStringAsFixed(1)} °C', labelWidth: width),
                    if (cpu != null && cpu!.voltageVolts > 0)
                      InfoRow(label: 'CPU Core Voltage', value: '${cpu!.voltageVolts.toStringAsFixed(2)} V', labelWidth: width),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Individual CPU Core Real-Time Utilization',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Total Load: ${cpu?.totalLoadPercent.toStringAsFixed(1) ?? "0"}%',
              style: const TextStyle(
                color: AppColors.cyanAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (cpu != null && cpu!.coreLoads.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemCount: cpu!.coreLoads.length,
            itemBuilder: (context, index) {
              final load = cpu!.coreLoads[index];
              final freq = cpu!.coreFrequenciesGhz.length > index ? cpu!.coreFrequenciesGhz[index] : 0.0;
              final isHighLoad = load > 80;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Core #$index',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (freq > 0)
                            Text(
                              '${freq.toStringAsFixed(2)} GHz',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${load.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isHighLoad ? AppColors.redAccent : AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (load / 100.0).clamp(0.0, 1.0),
                          minHeight: 4,
                          color: isHighLoad ? AppColors.redAccent : AppColors.cyanAccent,
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
    );
  }
}
