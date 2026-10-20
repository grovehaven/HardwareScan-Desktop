import '../models/hardware_models.dart';

class UpgradeAdvisor {
  static UpgradeRecommendation evaluateMemory(MemorySnapshot? mem, SystemOverview? sys) {
    if (mem == null) {
      return const UpgradeRecommendation(
        category: 'Memory (RAM)',
        currentHardware: 'Scanning...',
        status: UpgradeStatus.OPTIONAL,
        headline: 'Memory Telemetry Required',
        recommendedAction: 'Inspect memory specifications.',
        expectedImpact: 'N/A',
        technicalDetails: [],
      );
    }

    final totalGb = mem.totalGb;
    final sticks = mem.physicalSticks;
    final stickCount = sticks.length;
    final ddrType = sticks.isNotEmpty ? sticks.first.memoryType : 'LPDDR5';
    final speed = sticks.isNotEmpty ? sticks.first.clockSpeedMhz : 3200;

    final details = <String>[
      'Total Installed: ${totalGb.toStringAsFixed(1)} GB ($stickCount populated channels)',
      if (speed > 0) 'Memory Frequency: $speed MHz ($ddrType architecture)',
      'Virtual Memory / Swap: ${mem.swapTotalGb.toStringAsFixed(1)} GB',
      'Form Factor: Unified Mobile/LPDDR Subsystem (Soldered)',
    ];

    if (totalGb < 6.0) {
      return UpgradeRecommendation(
        category: 'Memory (RAM)',
        currentHardware: '${totalGb.toStringAsFixed(1)} GB $ddrType',
        status: UpgradeStatus.CRITICAL_UPGRADE,
        headline: 'Low Memory Capacity Pressure',
        recommendedAction: 'Device has under 6 GB RAM. Modern OS background tasks and heavy browser apps may undergo memory compression and app reloads.',
        expectedImpact: 'High: Upgrading to an 8 GB or 12 GB device prevents aggressive background app killing and improves multitasking.',
        technicalDetails: details + ['Recommended Target: 8 GB to 12 GB unified memory'],
      );
    } else if (totalGb < 10.0) {
      return UpgradeRecommendation(
        category: 'Memory (RAM)',
        currentHardware: '${totalGb.toStringAsFixed(1)} GB $ddrType',
        status: UpgradeStatus.RECOMMENDED,
        headline: 'Optimal Standard Workload RAM',
        recommendedAction: '8 GB RAM is ideal for standard daily use, media streaming, and mobile gaming.',
        expectedImpact: 'Moderate: 12 GB+ target recommended if running local AI models, 4K video recording, or high-end games.',
        technicalDetails: details + ['Multi-channel memory bandwidth enabled'],
      );
    } else {
      return UpgradeRecommendation(
        category: 'Memory (RAM)',
        currentHardware: '${totalGb.toStringAsFixed(1)} GB $ddrType',
        status: UpgradeStatus.OPTIMAL,
        headline: 'High-Performance Unified Memory Tier',
        recommendedAction: 'Your system memory capacity (${totalGb.toStringAsFixed(1)} GB) provides ample headroom for heavy multi-tasking, high-framerate mobile gaming, and background processes.',
        expectedImpact: 'Optimal: Peak memory bandwidth and background retention achieved.',
        technicalDetails: details,
      );
    }
  }

  static UpgradeRecommendation evaluateCpu(CpuSnapshot? cpu, SystemOverview? sys) {
    if (cpu == null) {
      return const UpgradeRecommendation(
        category: 'Processor (CPU & SoC)',
        currentHardware: 'Scanning...',
        status: UpgradeStatus.OPTIONAL,
        headline: 'CPU Telemetry Required',
        recommendedAction: 'Inspect processor specifications.',
        expectedImpact: 'N/A',
        technicalDetails: [],
      );
    }

    final model = cpu.model;
    final cores = cpu.physicalCores;

    final details = <String>[
      'Architecture: ${cpu.architecture} ($cores Cores)',
      'Vendor / Manufacturer: ${cpu.vendor}',
      'Instruction Set: ${cpu.is64Bit ? "64-Bit ARM / x86_64" : "32-Bit Legacy"}',
      'Operating Frequency: ${cpu.coreFrequenciesGhz.isNotEmpty ? cpu.coreFrequenciesGhz.first.toStringAsFixed(2) : "N/A"} GHz',
    ];

    if (cores < 6) {
      return UpgradeRecommendation(
        category: 'Processor (CPU & SoC)',
        currentHardware: model,
        status: UpgradeStatus.CRITICAL_UPGRADE,
        headline: 'Legacy Low Core-Count Processor',
        recommendedAction: 'Quad-core processors bottleneck under modern multi-threaded operating systems. Consider updating to an octa-core platform.',
        expectedImpact: 'Transformative: Eliminates system stuttering and speeds up application loading.',
        technicalDetails: details,
      );
    } else {
      return UpgradeRecommendation(
        category: 'Processor (CPU & SoC)',
        currentHardware: model,
        status: UpgradeStatus.OPTIMAL,
        headline: 'Modern Octa-Core Architecture',
        recommendedAction: 'Your octa-core CPU architecture provides fast compute performance, thermal efficiency, and dynamic clock scaling across efficiency and performance cores.',
        expectedImpact: 'Optimal compute foundation.',
        technicalDetails: details,
      );
    }
  }

  static UpgradeRecommendation evaluateStorage(List<PartitionSnapshot> partitions, List<DiskSnapshot> disks) {
    if (partitions.isEmpty && disks.isEmpty) {
      return const UpgradeRecommendation(
        category: 'Storage & Flash Memory',
        currentHardware: 'Scanning...',
        status: UpgradeStatus.OPTIONAL,
        headline: 'Storage Telemetry Required',
        recommendedAction: 'Inspect storage devices.',
        expectedImpact: 'N/A',
        technicalDetails: [],
      );
    }

    final primaryPartition = partitions.isNotEmpty ? partitions.first : null;
    final totalCapacityGb = primaryPartition?.totalGb ?? 128.0;
    final usedPercent = primaryPartition?.usagePercent ?? 60.0;
    final freeGb = primaryPartition?.freeGb ?? 48.0;

    final details = <String>[
      'Total System Storage: ${totalCapacityGb.toStringAsFixed(1)} GB',
      'Free Capacity: ${freeGb.toStringAsFixed(1)} GB remaining',
      'High-Speed Flash Interface: UFS 3.1 / NVMe Flash',
    ];

    if (usedPercent >= 85.0) {
      return UpgradeRecommendation(
        category: 'Storage & Flash Memory',
        currentHardware: '${usedPercent.toStringAsFixed(1)}% Full (${freeGb.toStringAsFixed(1)} GB free)',
        status: UpgradeStatus.CRITICAL_UPGRADE,
        headline: 'Storage Capacity Warning (>85% Full)',
        recommendedAction: 'High storage utilization reduces wear-leveling efficiency and flash write performance. Offload media files or expand storage.',
        expectedImpact: 'High: Frees up IOPS performance and ensures uninterrupted OS updates.',
        technicalDetails: details + ['Action: Clear cache or expand with high-speed MicroSD / Cloud backup'],
      );
    } else if (totalCapacityGb < 64.0) {
      return UpgradeRecommendation(
        category: 'Storage & Flash Memory',
        currentHardware: '${totalCapacityGb.toStringAsFixed(0)} GB Flash Storage',
        status: UpgradeStatus.RECOMMENDED,
        headline: 'Limited Storage Capacity Tier',
        recommendedAction: '64 GB or lower fills rapidly with apps and high-resolution videos. Recommend targeting 128 GB or 256 GB for future device upgrades.',
        expectedImpact: 'Moderate: Eliminates storage management maintenance.',
        technicalDetails: details,
      );
    } else {
      return UpgradeRecommendation(
        category: 'Storage & Flash Memory',
        currentHardware: '${totalCapacityGb.toStringAsFixed(0)} GB Flash Storage (${freeGb.toStringAsFixed(1)} GB Free)',
        status: UpgradeStatus.OPTIMAL,
        headline: 'Healthy Storage Capacity',
        recommendedAction: 'Flash storage has ample free capacity and operates at high sustained random IOPS speeds.',
        expectedImpact: 'Optimal storage health.',
        technicalDetails: details,
      );
    }
  }
}
