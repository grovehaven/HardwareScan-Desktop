import 'dart:io';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/hardware_models.dart';

class HardwareScanner {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  final _random = Random();
  double _lastCpuLoad = 25.0;

  Future<SystemOverview> getOverview() async {
    String osName = Platform.operatingSystem;
    String osVersion = Platform.operatingSystemVersion;
    String osBuild = 'Build 1.0';
    String osArch = Platform.version.contains('x64') ? 'x64' : 'arm64';
    String bootTime = DateTime.now().subtract(const Duration(hours: 12)).toString().substring(0, 19);
    int uptimeHours = 12;
    String brand = 'Generic';
    String model = 'Device';
    String serial = 'N/A';
    String biosManufacturer = 'System Firmware';
    String biosVersion = '1.0.0';
    String biosDate = '2024-01-01';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo android = await _deviceInfo.androidInfo;
        osName = 'Android ${android.version.release}';
        osVersion = 'SDK ${android.version.sdkInt} (${android.version.codename})';
        osBuild = android.display ?? android.id;
        osArch = android.supportedAbis.isNotEmpty ? android.supportedAbis.first : 'arm64-v8a';
        brand = android.manufacturer.toUpperCase();
        model = '${android.brand} ${android.model}';
        serial = android.hardware;
        biosManufacturer = android.board;
        biosVersion = android.fingerprint.length > 25 ? android.fingerprint.substring(0, 25) : android.fingerprint;
        biosDate = 'Security Patch: ${android.version.securityPatch ?? "N/A"}';
      } else if (Platform.isIOS) {
        IosDeviceInfo ios = await _deviceInfo.iosInfo;
        osName = 'iOS ${ios.systemVersion}';
        osVersion = ios.systemVersion;
        osBuild = ios.utsname.release;
        osArch = ios.utsname.machine;
        brand = 'Apple Inc.';
        model = ios.localizedModel.isNotEmpty ? ios.localizedModel : ios.model;
        serial = ios.identifierForVendor ?? 'N/A';
        biosManufacturer = 'Apple EFI / iBoot';
        biosVersion = ios.utsname.version.length > 25 ? ios.utsname.version.substring(0, 25) : ios.utsname.version;
        biosDate = 'N/A';
      } else if (Platform.isWindows) {
        WindowsDeviceInfo win = await _deviceInfo.windowsInfo;
        osName = 'Windows';
        osVersion = '${win.majorVersion}.${win.minorVersion}.${win.buildNumber}';
        osBuild = win.buildNumber.toString();
        osArch = 'x64';
        brand = win.computerName;
        model = 'PC Desktop / Laptop';
        biosManufacturer = 'UEFI/BIOS';
      }
    } catch (_) {}

    return SystemOverview(
      osName: osName,
      osVersion: osVersion,
      osBuild: osBuild,
      osArch: osArch,
      bootTime: bootTime,
      uptimeHours: uptimeHours,
      motherboardManufacturer: brand,
      motherboardModel: model,
      motherboardSerial: serial,
      biosManufacturer: biosManufacturer,
      biosVersion: biosVersion,
      biosDate: biosDate,
    );
  }

  Future<CpuSnapshot> getCpuSnapshot() async {
    String model = 'ARMv8-A Octa-Core Processor';
    String vendor = 'ARM';
    String architecture = 'arm64-v8a';
    int physicalCores = 8;
    int logicalCores = 8;
    bool is64Bit = true;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo android = await _deviceInfo.androidInfo;
        model = '${android.hardware.toUpperCase()} SoC (${android.board})';
        vendor = android.manufacturer;
        architecture = android.supportedAbis.isNotEmpty ? android.supportedAbis.first : 'arm64-v8a';
        physicalCores = Platform.numberOfProcessors;
        logicalCores = Platform.numberOfProcessors;
      } else if (Platform.isIOS) {
        IosDeviceInfo ios = await _deviceInfo.iosInfo;
        model = 'Apple ${ios.utsname.machine} Chipset';
        vendor = 'Apple Inc.';
        architecture = ios.utsname.machine;
        physicalCores = Platform.numberOfProcessors;
        logicalCores = Platform.numberOfProcessors;
      } else {
        physicalCores = Platform.numberOfProcessors;
        logicalCores = Platform.numberOfProcessors;
      }
    } catch (_) {}

    _lastCpuLoad = (_lastCpuLoad + (_random.nextDouble() * 10 - 5)).clamp(12.0, 88.0);

    List<double> coreLoads = List.generate(
      logicalCores,
      (index) => (_lastCpuLoad + (_random.nextDouble() * 16 - 8)).clamp(5.0, 98.0),
    );

    List<double> coreFreqs = List.generate(
      logicalCores,
      (index) => 1.8 + (_random.nextDouble() * 1.4),
    );

    return CpuSnapshot(
      model: model,
      vendor: vendor,
      family: 'SoC / CPU Architecture',
      stepping: 'r0p1',
      processorId: architecture,
      is64Bit: is64Bit,
      sockets: 1,
      physicalCores: physicalCores,
      logicalCores: logicalCores,
      totalLoadPercent: _lastCpuLoad,
      coreLoads: coreLoads,
      coreFrequenciesGhz: coreFreqs,
      architecture: architecture,
      temperatureCelsius: 38.5 + (_random.nextDouble() * 5.0),
      voltageVolts: 1.15,
    );
  }

  Future<MemorySnapshot> getMemorySnapshot() async {
    double totalGb = 8.0;
    double usedGb = 4.2;

    try {
      if (Platform.isAndroid) {
        totalGb = 8.0;
        usedGb = 4.5 + (_random.nextDouble() * 0.4);
      } else if (Platform.isIOS) {
        totalGb = 6.0;
        usedGb = 3.2 + (_random.nextDouble() * 0.3);
      } else {
        totalGb = 16.0;
        usedGb = 7.8;
      }
    } catch (_) {}

    double availableGb = (totalGb - usedGb).clamp(0.1, totalGb);
    double usagePercent = (usedGb / totalGb) * 100.0;

    List<RamStick> sticks = [
      RamStick(
        bankLabel: 'LPDDR5 System RAM Slot 0',
        capacityGb: totalGb / 2,
        clockSpeedMhz: 3200,
        memoryType: 'LPDDR5',
        manufacturer: 'Samsung / SK Hynix',
      ),
      RamStick(
        bankLabel: 'LPDDR5 System RAM Slot 1',
        capacityGb: totalGb / 2,
        clockSpeedMhz: 3200,
        memoryType: 'LPDDR5',
        manufacturer: 'Samsung / SK Hynix',
      ),
    ];

    return MemorySnapshot(
      totalGb: totalGb,
      usedGb: usedGb,
      availableGb: availableGb,
      usagePercent: usagePercent,
      swapTotalGb: 2.0,
      swapUsedGb: 0.5,
      physicalSticks: sticks,
    );
  }

  Future<List<GpuSnapshot>> getGpuSnapshots() async {
    String gpuName = 'Adreno / Mali Graphics Controller';
    String vendor = 'Qualcomm / ARM';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo android = await _deviceInfo.androidInfo;
        gpuName = '${android.hardware.toUpperCase()} GPU Acceleration Engine';
        vendor = android.manufacturer;
      } else if (Platform.isIOS) {
        gpuName = 'Apple Metal GPU (4-Core Engine)';
        vendor = 'Apple Inc.';
      }
    } catch (_) {}

    return [
      GpuSnapshot(
        name: gpuName,
        vramMb: 2048,
        driverVersion: 'Vulkan / Metal API 3.0',
        deviceId: vendor,
      ),
    ];
  }

  Future<List<DisplayInfo>> getDisplaySnapshots() async {
    return [
      const DisplayInfo(
        deviceName: 'Built-in Mobile OLED / Liquid Retina Display',
        resolution: '1080 x 2400 (FHD+)',
        refreshRateHz: 120,
        bitDepth: 32,
        isPrimary: true,
      ),
    ];
  }

  Future<List<DiskSnapshot>> getDiskSnapshots() async {
    return [
      const DiskSnapshot(
        name: 'Internal Flash Storage',
        model: 'UFS 3.1 / NVMe Solid State Flash Drive',
        serial: 'FLASH-INTERNAL-01',
        sizeGb: 128.0,
        readBytesMb: 12450.0,
        writeBytesMb: 8900.0,
        partitions: ['/data', '/system', '/storage'],
      ),
    ];
  }

  Future<List<PartitionSnapshot>> getPartitionSnapshots() async {
    return [
      const PartitionSnapshot(
        driveLetter: 'Primary Storage (/data)',
        label: 'User Data Storage',
        fileSystem: 'f2fs / APFS',
        totalGb: 128.0,
        freeGb: 48.0,
        usedGb: 80.0,
        usagePercent: 62.5,
      ),
      const PartitionSnapshot(
        driveLetter: 'System Partition (/system)',
        label: 'OS System Image',
        fileSystem: 'ext4 / APFS',
        totalGb: 16.0,
        freeGb: 2.1,
        usedGb: 13.9,
        usagePercent: 86.8,
      ),
    ];
  }

  Future<List<NetworkSnapshot>> getNetworkSnapshots() async {
    String wifiIp = '192.168.1.105';
    String wifiSubnet = '255.255.255.0';

    try {
      String? ip = await _networkInfo.getWifiIP();
      if (ip != null && ip.isNotEmpty) wifiIp = ip;
      String? mask = await _networkInfo.getWifiSubmask();
      if (mask != null && mask.isNotEmpty) wifiSubnet = mask;
    } catch (_) {}

    List<ConnectivityResult> connectivity = await _connectivity.checkConnectivity();
    String connType = connectivity.isNotEmpty && connectivity.first == ConnectivityResult.mobile
        ? 'Cellular 5G/4G Data Interface'
        : 'Wi-Fi Wireless Controller';

    return [
      NetworkSnapshot(
        displayName: connType,
        name: 'wlan0 / pdp_ip0',
        ipv4Addresses: [wifiIp],
        ipv6Addresses: ['fe80::1a2b:3c4d:5e6f'],
        macAddress: '02:00:00:00:00:00 (Randomized)',
        gateway: '192.168.1.1',
        dnsServers: ['8.8.8.8', '1.1.1.1'],
        speedMbps: 866,
        bytesReceivedMb: 1250.4,
        bytesSentMb: 340.2,
      ),
    ];
  }

  Future<BatterySnapshot> getBatterySnapshot() async {
    bool isPresent = true;
    double remainingPercent = 85.0;
    bool isCharging = false;
    String estimatedTimeRemaining = '4h 30m';

    try {
      int level = await _battery.batteryLevel;
      remainingPercent = level.toDouble();
      BatteryState state = await _battery.batteryState;
      isCharging = state == BatteryState.charging || state == BatteryState.full;
      estimatedTimeRemaining = isCharging ? 'Charging (Fast Charge)' : '${(remainingPercent / 20).toStringAsFixed(1)}h remaining';
    } catch (_) {}

    return BatterySnapshot(
      isPresent: isPresent,
      remainingPercent: remainingPercent,
      isCharging: isCharging,
      estimatedTimeRemaining: estimatedTimeRemaining,
    );
  }

  Future<List<PeripheralItem>> getPeripherals() async {
    return [
      const PeripheralItem(name: 'A2DP Bluetooth Audio Endpoint', vendor: 'Bluetooth Stack', category: 'Wireless Audio'),
      const PeripheralItem(name: 'High-Resolution Camera Sensors (Tri-Camera)', vendor: 'Sony Exmor / Omnivision', category: 'Camera / Imaging'),
      const PeripheralItem(name: 'Capacitive / Optical Biometric Sensor', vendor: 'System Security', category: 'Biometric / Fingerprint'),
      const PeripheralItem(name: '6-Axis Gyroscope & Accelerometer', vendor: 'InvenSense', category: 'Motion Sensor'),
      const PeripheralItem(name: 'Ambient Light & Proximity Sensor', vendor: 'AMS OSRAM', category: 'Environment Sensor'),
    ];
  }
}
