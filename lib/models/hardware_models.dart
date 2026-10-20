class CpuSnapshot {
  final String model;
  final String vendor;
  final String family;
  final String stepping;
  final String processorId;
  final bool is64Bit;
  final int sockets;
  final int physicalCores;
  final int logicalCores;
  final double totalLoadPercent;
  final List<double> coreLoads;
  final List<double> coreFrequenciesGhz;
  final String architecture;
  final double temperatureCelsius;
  final double voltageVolts;

  const CpuSnapshot({
    required this.model,
    required this.vendor,
    required this.family,
    required this.stepping,
    required this.processorId,
    required this.is64Bit,
    required this.sockets,
    required this.physicalCores,
    required this.logicalCores,
    required this.totalLoadPercent,
    required this.coreLoads,
    required this.coreFrequenciesGhz,
    required this.architecture,
    required this.temperatureCelsius,
    required this.voltageVolts,
  });
}

class RamStick {
  final String bankLabel;
  final double capacityGb;
  final int clockSpeedMhz;
  final String memoryType;
  final String manufacturer;

  const RamStick({
    required this.bankLabel,
    required this.capacityGb,
    required this.clockSpeedMhz,
    required this.memoryType,
    required this.manufacturer,
  });
}

class MemorySnapshot {
  final double totalGb;
  final double usedGb;
  final double availableGb;
  final double usagePercent;
  final double swapTotalGb;
  final double swapUsedGb;
  final List<RamStick> physicalSticks;

  const MemorySnapshot({
    required this.totalGb,
    required this.usedGb,
    required this.availableGb,
    required this.usagePercent,
    required this.swapTotalGb,
    required this.swapUsedGb,
    required this.physicalSticks,
  });
}

class DisplayInfo {
  final String deviceName;
  final String resolution;
  final int refreshRateHz;
  final int bitDepth;
  final bool isPrimary;

  const DisplayInfo({
    required this.deviceName,
    required this.resolution,
    required this.refreshRateHz,
    required this.bitDepth,
    required this.isPrimary,
  });
}

class GpuSnapshot {
  final String name;
  final int vramMb;
  final String driverVersion;
  final String deviceId;

  const GpuSnapshot({
    required this.name,
    required this.vramMb,
    required this.driverVersion,
    required this.deviceId,
  });
}

class PartitionSnapshot {
  final String driveLetter;
  final String label;
  final String fileSystem;
  final double totalGb;
  final double freeGb;
  final double usedGb;
  final double usagePercent;

  const PartitionSnapshot({
    required this.driveLetter,
    required this.label,
    required this.fileSystem,
    required this.totalGb,
    required this.freeGb,
    required this.usedGb,
    required this.usagePercent,
  });
}

class DiskSnapshot {
  final String name;
  final String model;
  final String serial;
  final double sizeGb;
  final double readBytesMb;
  final double writeBytesMb;
  final List<String> partitions;

  const DiskSnapshot({
    required this.name,
    required this.model,
    required this.serial,
    required this.sizeGb,
    required this.readBytesMb,
    required this.writeBytesMb,
    required this.partitions,
  });
}

class NetworkSnapshot {
  final String displayName;
  final String name;
  final List<String> ipv4Addresses;
  final List<String> ipv6Addresses;
  final String macAddress;
  final String gateway;
  final List<String> dnsServers;
  final int speedMbps;
  final double bytesReceivedMb;
  final double bytesSentMb;

  const NetworkSnapshot({
    required this.displayName,
    required this.name,
    required this.ipv4Addresses,
    required this.ipv6Addresses,
    required this.macAddress,
    required this.gateway,
    required this.dnsServers,
    required this.speedMbps,
    required this.bytesReceivedMb,
    required this.bytesSentMb,
  });
}

class SystemOverview {
  final String osName;
  final String osVersion;
  final String osBuild;
  final String osArch;
  final String bootTime;
  final int uptimeHours;
  final String motherboardManufacturer;
  final String motherboardModel;
  final String motherboardSerial;
  final String biosManufacturer;
  final String biosVersion;
  final String biosDate;

  const SystemOverview({
    required this.osName,
    required this.osVersion,
    required this.osBuild,
    required this.osArch,
    required this.bootTime,
    required this.uptimeHours,
    required this.motherboardManufacturer,
    required this.motherboardModel,
    required this.motherboardSerial,
    required this.biosManufacturer,
    required this.biosVersion,
    required this.biosDate,
  });
}

class BatterySnapshot {
  final bool isPresent;
  final double remainingPercent;
  final bool isCharging;
  final String estimatedTimeRemaining;

  const BatterySnapshot({
    required this.isPresent,
    required this.remainingPercent,
    required this.isCharging,
    required this.estimatedTimeRemaining,
  });
}

class PeripheralItem {
  final String name;
  final String vendor;
  final String category;

  const PeripheralItem({
    required this.name,
    required this.vendor,
    required this.category,
  });
}

enum UpgradeStatus {
  CRITICAL_UPGRADE,
  RECOMMENDED,
  OPTIONAL,
  OPTIMAL,
}

class UpgradeRecommendation {
  final String category;
  final String currentHardware;
  final UpgradeStatus status;
  final String headline;
  final String recommendedAction;
  final String expectedImpact;
  final List<String> technicalDetails;

  const UpgradeRecommendation({
    required this.category,
    required this.currentHardware,
    required this.status,
    required this.headline,
    required this.recommendedAction,
    required this.expectedImpact,
    required this.technicalDetails,
  });
}
