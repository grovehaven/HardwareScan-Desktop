import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hardwarescan/services/hardware_scanner.dart';
import 'package:hardwarescan/theme/app_theme.dart';
import 'package:hardwarescan/ui/hardware_scan_app.dart';

void main() {
  testWidgets('Hardware Scan All loads dashboard successfully', (WidgetTester tester) async {
    final scanner = HardwareScanner();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: HardwareScanApp(scanner: scanner),
      ),
    );

    expect(find.text('Hardware Diagnostics'), findsOneWidget);
  });
}
