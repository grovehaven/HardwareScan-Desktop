import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hardware_models.dart';
import '../services/hardware_scanner.dart';
import '../theme/app_colors.dart';
import 'screens/cpu_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/gpu_screen.dart';
import 'screens/memory_screen.dart';
import 'screens/network_screen.dart';
import 'screens/peripherals_screen.dart';
import 'screens/storage_screen.dart';
import 'screens/system_screen.dart';
import 'screens/upgrade_path_screen.dart';

class NavDestination {
  final String title;
  final IconData icon;

  const NavDestination(this.title, this.icon);
}

const List<NavDestination> kNavItems = [
  NavDestination('Dashboard', Icons.dashboard),
  NavDestination('Upgrade Path', Icons.trending_up),
  NavDestination('Processor', Icons.memory),
  NavDestination('Memory', Icons.storage),
  NavDestination('Storage', Icons.folder),
  NavDestination('Graphics', Icons.tv),
  NavDestination('Network', Icons.wifi),
  NavDestination('System', Icons.computer),
  NavDestination('Peripherals', Icons.usb),
];

class HardwareScanApp extends StatefulWidget {
  final HardwareScanner scanner;

  const HardwareScanApp({super.key, required this.scanner});

  @override
  State<HardwareScanApp> createState() => _HardwareScanAppState();
}

class _HardwareScanAppState extends State<HardwareScanApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Timer? _timer;

  CpuSnapshot? _cpuInfo;
  MemorySnapshot? _memInfo;
  List<GpuSnapshot> _gpus = [];
  List<DisplayInfo> _displays = [];
  List<DiskSnapshot> _disks = [];
  List<PartitionSnapshot> _partitions = [];
  List<NetworkSnapshot> _networks = [];
  SystemOverview? _systemInfo;
  BatterySnapshot? _batteryInfo;
  List<PeripheralItem> _peripherals = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _pollRealtimeData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final sys = await widget.scanner.getOverview();
    final gpus = await widget.scanner.getGpuSnapshots();
    final displays = await widget.scanner.getDisplaySnapshots();
    final disks = await widget.scanner.getDiskSnapshots();
    final partitions = await widget.scanner.getPartitionSnapshots();
    final networks = await widget.scanner.getNetworkSnapshots();
    final battery = await widget.scanner.getBatterySnapshot();
    final peripherals = await widget.scanner.getPeripherals();

    if (mounted) {
      setState(() {
        _systemInfo = sys;
        _gpus = gpus;
        _displays = displays;
        _disks = disks;
        _partitions = partitions;
        _networks = networks;
        _batteryInfo = battery;
        _peripherals = peripherals;
      });
    }

    await _pollRealtimeData();
  }

  Future<void> _pollRealtimeData() async {
    final cpu = await widget.scanner.getCpuSnapshot();
    final mem = await widget.scanner.getMemorySnapshot();
    if (mounted) {
      setState(() {
        _cpuInfo = cpu;
        _memInfo = mem;
      });
    }
  }

  void _showMoreCategoriesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Diagnostic Categories',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: kNavItems.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndex == idx;
                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? AppColors.cyanAccent : AppColors.textSecondary,
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: isSelected ? AppColors.cyanAccent : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          setState(() => _selectedIndex = idx);
                          Navigator.pop(bottomSheetContext);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return switch (_selectedIndex) {
      0 => DashboardScreen(
          cpu: _cpuInfo,
          mem: _memInfo,
          sys: _systemInfo,
          battery: _batteryInfo,
          gpus: _gpus,
          partitions: _partitions,
          onOpenUpgrades: () => setState(() => _selectedIndex = 1),
        ),
      1 => UpgradePathScreen(
          cpu: _cpuInfo,
          mem: _memInfo,
          partitions: _partitions,
          disks: _disks,
          sys: _systemInfo,
        ),
      2 => CpuScreen(cpu: _cpuInfo),
      3 => MemoryScreen(mem: _memInfo),
      4 => StorageScreen(partitions: _partitions, disks: _disks),
      5 => GpuScreen(gpus: _gpus, displays: _displays),
      6 => NetworkScreen(networks: _networks),
      7 => SystemScreen(sys: _systemInfo),
      8 => PeripheralsScreen(peripherals: _peripherals),
      _ => DashboardScreen(
          cpu: _cpuInfo,
          mem: _memInfo,
          sys: _systemInfo,
          battery: _batteryInfo,
          gpus: _gpus,
          partitions: _partitions,
          onOpenUpgrades: () => setState(() => _selectedIndex = 1),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.speed, color: AppColors.cyanAccent, size: 28),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Hardware ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Scan All',
                    style: TextStyle(
                      color: AppColors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: _pollRealtimeData,
            tooltip: 'Refresh Telemetry',
          ),
        ],
      ),
      drawer: !isWideScreen
          ? Drawer(
              backgroundColor: AppColors.surfaceDark,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: AppColors.cardBackground),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.speed, color: AppColors.cyanAccent, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Hardware Scan All',
                          style: TextStyle(color: AppColors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _systemInfo?.osName ?? 'Mobile Telemetry',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ...kNavItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return ListTile(
                      leading: Icon(
                        item.icon,
                        color: _selectedIndex == idx ? AppColors.cyanAccent : AppColors.textSecondary,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: _selectedIndex == idx ? AppColors.cyanAccent : AppColors.textPrimary,
                          fontWeight: _selectedIndex == idx ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: _selectedIndex == idx,
                      onTap: () {
                        setState(() => _selectedIndex = idx);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              destinations: kNavItems
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.title),
                    ),
                  )
                  .toList(),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? BottomNavigationBar(
              currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
              onTap: (index) {
                if (index == 4) {
                  _showMoreCategoriesSheet(context);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              items: [
                BottomNavigationBarItem(icon: Icon(kNavItems[0].icon), label: kNavItems[0].title),
                BottomNavigationBarItem(icon: Icon(kNavItems[1].icon), label: kNavItems[1].title),
                BottomNavigationBarItem(icon: Icon(kNavItems[2].icon), label: kNavItems[2].title),
                BottomNavigationBarItem(icon: Icon(kNavItems[3].icon), label: kNavItems[3].title),
                const BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
              ],
            )
          : null,
    );
  }
}
