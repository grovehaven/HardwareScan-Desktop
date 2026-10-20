import 'package:flutter/material.dart';
import 'services/hardware_scanner.dart';
import 'theme/app_theme.dart';
import 'ui/hardware_scan_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final scanner = HardwareScanner();

  runApp(
    MaterialApp(
      title: 'Hardware Scan All - PC & Mobile Diagnostics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HardwareScanApp(scanner: scanner),
    ),
  );
}
