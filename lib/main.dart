import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/hardware_scanner.dart';
import 'theme/app_theme.dart';
import 'ui/hardware_scan_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

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
