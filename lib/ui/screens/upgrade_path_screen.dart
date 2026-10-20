import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../services/upgrade_advisor.dart';
import '../../theme/app_colors.dart';
import '../widgets/upgrade_card.dart';

class UpgradePathScreen extends StatelessWidget {
  final CpuSnapshot? cpu;
  final MemorySnapshot? mem;
  final List<PartitionSnapshot> partitions;
  final List<DiskSnapshot> disks;
  final SystemOverview? sys;

  const UpgradePathScreen({
    super.key,
    required this.cpu,
    required this.mem,
    required this.partitions,
    required this.disks,
    required this.sys,
  });

  @override
  Widget build(BuildContext context) {
    final memUpgrade = UpgradeAdvisor.evaluateMemory(mem, sys);
    final cpuUpgrade = UpgradeAdvisor.evaluateCpu(cpu, sys);
    final storageUpgrade = UpgradeAdvisor.evaluateStorage(partitions, disks);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Hardware Upgrade Path',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Intelligent hardware evaluation for Memory, Processor, and Storage drives',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.surfaceDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.cyanAccent, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Upgrade Intelligence',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Analyzing component capability, memory pressure, processor cores, and storage IOPS performance.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        UpgradeCard(
          icon: Icons.storage,
          recommendation: memUpgrade,
        ),
        const SizedBox(height: 12),
        UpgradeCard(
          icon: Icons.memory,
          recommendation: cpuUpgrade,
        ),
        const SizedBox(height: 12),
        UpgradeCard(
          icon: Icons.folder,
          recommendation: storageUpgrade,
        ),
      ],
    );
  }
}
