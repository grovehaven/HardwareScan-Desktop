import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class SystemScreen extends StatelessWidget {
  final SystemOverview? sys;

  const SystemScreen({super.key, required this.sys});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'System & Platform Firmware',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hardware Platform & Board',
                  style: TextStyle(
                    color: AppColors.cyanAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 6),
                InfoRow(label: 'Brand / Manufacturer', value: sys?.motherboardManufacturer ?? 'N/A'),
                InfoRow(label: 'Model / Product', value: sys?.motherboardModel ?? 'N/A'),
                InfoRow(label: 'Serial Number / Hardware', value: sys?.motherboardSerial ?? 'N/A'),
                InfoRow(label: 'Firmware Vendor', value: sys?.biosManufacturer ?? 'N/A'),
                InfoRow(label: 'Firmware Fingerprint', value: sys?.biosVersion ?? 'N/A'),
                InfoRow(label: 'Security Patch / Release Date', value: sys?.biosDate ?? 'N/A'),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operating System Details',
                  style: TextStyle(
                    color: AppColors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 6),
                InfoRow(label: 'OS Distribution', value: sys?.osName ?? 'N/A'),
                InfoRow(label: 'OS Version / SDK', value: sys?.osVersion ?? 'N/A'),
                InfoRow(label: 'Build ID / Release', value: sys?.osBuild ?? 'N/A'),
                InfoRow(label: 'Kernel / Architecture', value: sys?.osArch ?? 'N/A'),
                InfoRow(label: 'System Boot Timestamp', value: sys?.bootTime ?? 'N/A'),
                InfoRow(label: 'Active Uptime', value: '${sys?.uptimeHours ?? 0} Hours'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
