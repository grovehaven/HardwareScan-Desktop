import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class StorageScreen extends StatelessWidget {
  final List<PartitionSnapshot> partitions;
  final List<DiskSnapshot> disks;

  const StorageScreen({
    super.key,
    required this.partitions,
    required this.disks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Logical Storage Partitions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...partitions.map(
          (part) => Card(
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
                        '${part.label} [${part.driveLetter}]',
                        style: const TextStyle(
                          color: AppColors.cyanAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${part.usagePercent.toStringAsFixed(1)}% Used',
                        style: TextStyle(
                          color: part.usagePercent > 85 ? AppColors.redAccent : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (part.usagePercent / 100.0).clamp(0.0, 1.0),
                      minHeight: 8,
                      color: part.usagePercent > 85 ? AppColors.redAccent : AppColors.cyanAccent,
                      backgroundColor: AppColors.darkBackground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Used: ${part.usedGb.toStringAsFixed(1)} GB', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('Free: ${part.freeGb.toStringAsFixed(1)} GB', style: const TextStyle(color: AppColors.greenAccent, fontSize: 13)),
                      Text('Total: ${part.totalGb.toStringAsFixed(1)} GB (${part.fileSystem})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Physical Storage Devices & Flash Units',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...disks.map(
          (disk) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disk.model,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 6),
                  InfoRow(label: 'Device Identifier', value: disk.name),
                  InfoRow(label: 'Serial Number', value: disk.serial),
                  InfoRow(label: 'Raw Drive Capacity', value: '${disk.sizeGb.toStringAsFixed(1)} GB'),
                  InfoRow(label: 'Lifetime Reads', value: '${disk.readBytesMb.toStringAsFixed(0)} MB'),
                  InfoRow(label: 'Lifetime Writes', value: '${disk.writeBytesMb.toStringAsFixed(0)} MB'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
