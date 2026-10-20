import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class GpuScreen extends StatelessWidget {
  final List<GpuSnapshot> gpus;
  final List<DisplayInfo> displays;

  const GpuScreen({
    super.key,
    required this.gpus,
    required this.displays,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Graphics Processing Units (GPU)',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...gpus.map(
          (gpu) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gpu.name,
                    style: const TextStyle(
                      color: AppColors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 6),
                  InfoRow(
                    label: 'Dedicated Video Memory (VRAM)',
                    value: gpu.vramMb > 0 ? '${gpu.vramMb} MB (${(gpu.vramMb / 1024).toStringAsFixed(1)} GB)' : 'Shared Unified Memory',
                  ),
                  InfoRow(label: 'Driver & Graphics API', value: gpu.driverVersion),
                  InfoRow(label: 'Vendor / Device ID', value: gpu.deviceId),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Displays & Monitors',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...displays.map(
          (disp) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          disp.deviceName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (disp.isPrimary)
                        const Text(
                          'PRIMARY DISPLAY',
                          style: TextStyle(
                            color: AppColors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 6),
                  InfoRow(label: 'Active Screen Resolution', value: disp.resolution),
                  InfoRow(label: 'Refresh Rate', value: '${disp.refreshRateHz} Hz'),
                  InfoRow(label: 'Color Depth', value: '${disp.bitDepth}-bit'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
