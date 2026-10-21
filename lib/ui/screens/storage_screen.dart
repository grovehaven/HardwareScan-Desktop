import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class FileTypeCategory {
  final String title;
  final IconData icon;
  final Color color;
  final int fileCount;
  final double sizeGb;
  final String formats;
  final String properties;

  const FileTypeCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.fileCount,
    required this.sizeGb,
    required this.formats,
    required this.properties,
  });
}

const List<FileTypeCategory> kFileTypeCategories = [
  FileTypeCategory(
    title: 'Graphics & Pictures',
    icon: Icons.photo_library,
    color: AppColors.cyanAccent,
    fileCount: 3420,
    sizeGb: 12.4,
    formats: 'JPEG, PNG, WEBP, HEIC, GIF, SVG',
    properties: 'Camera DCIM, Screenshots, Downloads, Image Cache',
  ),
  FileTypeCategory(
    title: 'Videos',
    icon: Icons.video_library,
    color: AppColors.purpleAccent,
    fileCount: 185,
    sizeGb: 28.6,
    formats: 'MP4, MKV, MOV, AVI, WEBM',
    properties: '4K / 1080p Video Recordings, Screen Records, Movies',
  ),
  FileTypeCategory(
    title: 'Programs & Executables',
    icon: Icons.code,
    color: AppColors.orangeAccent,
    fileCount: 64,
    sizeGb: 8.2,
    formats: 'APK, AAB, EXE, ELF, SH, BIN',
    properties: 'Installer Packages, Command-line Binaries, Scripts',
  ),
  FileTypeCategory(
    title: 'Apps & Applications',
    icon: Icons.apps,
    color: AppColors.greenAccent,
    fileCount: 142,
    sizeGb: 24.1,
    formats: 'Installed App Packages, ART Runtime, OBB Data',
    properties: '108 User Applications, 34 System Services & Libraries',
  ),
];

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
          'File Types Stored',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'File count, total size, and format properties across storage categories',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        ...kFileTypeCategories.map(
          (cat) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(cat.icon, color: cat.color, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            cat.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cat.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cat.color.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${cat.fileCount} Files / Items',
                          style: TextStyle(
                            color: cat.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 6),
                  InfoRow(label: 'Total Allocated Size', value: '${cat.sizeGb.toStringAsFixed(1)} GB'),
                  InfoRow(label: 'Supported Formats', value: cat.formats),
                  InfoRow(label: 'Properties & Locations', value: cat.properties),
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
