import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/device_data_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _exportDeviceReport(BuildContext context) {
    final specs = DeviceDataService.instance.specs;
    final buffer = StringBuffer();
    buffer.writeln('====================================');
    buffer.writeln('📱 DEVICE SPECIFICATION REPORT');
    buffer.writeln('App: Device Specs & Diagnostics');
    buffer.writeln('Built By: Abdullah Bhatti');
    buffer.writeln('Date: ${DateTime.now().toIso8601String()}');
    buffer.writeln('====================================\n');

    for (final spec in specs) {
      buffer.writeln('• ${spec.title}: ${spec.value}');
      buffer.writeln('  [Category: ${spec.categoryName}]');
      buffer.writeln('  [Concept]: ${spec.conceptExplanation}');
      buffer.writeln('  [Evaluation]: ${spec.howToEvaluate}\n');
    }

    buffer.writeln('====================================');
    buffer.writeln('Report generated successfully.');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full Device Report copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About & Developer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Developer Hero Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.indigoAccent, Colors.purpleAccent],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF334155),
                        child: Icon(Icons.person_rounded, size: 48, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Built by Abdullah Bhatti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Lead Flutter & Android Developer',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'A clean, modern Android application crafted to deliver deep hardware inspection, real-time diagnostic stream benchmarks, and smart smartphone specifications evaluation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Export Device Report Button
            FilledButton.icon(
              onPressed: () => _exportDeviceReport(context),
              icon: const Icon(Icons.share_rounded),
              label: const Text('Export Full Device Report'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),

            const SizedBox(height: 24),

            // App Highlights
            Text(
              'Application Capabilities',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              context,
              icon: Icons.developer_mode_rounded,
              title: 'Comprehensive Device Specs',
              description: 'Examines CPU architecture, ABI instruction sets, OS API levels, and build fingerprints.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.search_rounded,
              title: 'Instant Search Engine',
              description: 'Quickly query any hardware spec, acronym, or concept across all hardware categories.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.school_rounded,
              title: 'Hardware Concepts & Evaluation Guide',
              description: 'Explains what specs mean and guides you on evaluating good vs poor smartphone components.',
            ),
            _buildFeatureTile(
              context,
              icon: Icons.terminal_rounded,
              title: 'Live Text & Diagnostic Benchmarks',
              description: 'Streams thousands of text operations per second, tests CPU throughput, and tests multi-touch responsiveness.',
            ),

            const SizedBox(height: 24),

            // Build Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Device Info & Diagnostics v1.0.0',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Compiled with Flutter & GitHub Actions Cloud CI/CD',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(70)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(description, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
      ),
    );
  }
}
