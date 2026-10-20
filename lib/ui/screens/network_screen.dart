import 'package:flutter/material.dart';
import '../../models/hardware_models.dart';
import '../../theme/app_colors.dart';
import '../widgets/info_row.dart';

class NetworkScreen extends StatelessWidget {
  final List<NetworkSnapshot> networks;

  const NetworkScreen({super.key, required this.networks});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Network Adapters & Connectivity',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...networks.map(
          (net) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    net.displayName,
                    style: const TextStyle(
                      color: AppColors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 6),
                  InfoRow(label: 'IPv4 Address', value: net.ipv4Addresses.join(', ')),
                  if (net.ipv6Addresses.isNotEmpty)
                    InfoRow(label: 'IPv6 Address', value: net.ipv6Addresses.first),
                  InfoRow(label: 'Physical / MAC Address', value: net.macAddress),
                  InfoRow(label: 'Default Gateway', value: net.gateway),
                  if (net.dnsServers.isNotEmpty)
                    InfoRow(label: 'DNS Servers', value: net.dnsServers.join(', ')),
                  InfoRow(label: 'Max Link Speed', value: net.speedMbps > 0 ? '${net.speedMbps} Mbps' : 'Dynamic'),
                  InfoRow(label: 'Data Received', value: '${net.bytesReceivedMb.toStringAsFixed(1)} MB'),
                  InfoRow(label: 'Data Sent', value: '${net.bytesSentMb.toStringAsFixed(1)} MB'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
