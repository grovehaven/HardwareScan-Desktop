import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';

class PeripheralsScreen extends StatelessWidget {
  final List<PeripheralItem> peripherals;

  const PeripheralsScreen({super.key, required this.peripherals});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Connected Peripherals & Hardware Sensors',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Audio endpoints, motion sensors, cameras, and USB/Bluetooth devices',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        if (peripherals.isNotEmpty)
          ...peripherals.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.vendor,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AppColors.cyanAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No external USB or audio peripherals reported.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
