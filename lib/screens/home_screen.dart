import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/device_data_service.dart';
import '../models/spec_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SpecCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final service = DeviceDataService.instance;
    final specs = service.specs;

    final filteredSpecs = _selectedCategory == null
        ? specs
        : specs.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Specifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Hardware, OS, Display & Architecture',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Specs',
            onPressed: () async {
              await service.loadDeviceSpecs();
              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Device specifications refreshed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header Quick Status Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _buildHeaderCard(context, specs),
            ),
          ),

          // Category Chips Filter
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Specs'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...SpecCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(_getCategoryLabel(cat)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 12),
          ),

          // Specs List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredSpecs[index];
                  return _buildSpecCard(context, item);
                },
                childCount: filteredSpecs.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(SpecCategory cat) {
    switch (cat) {
      case SpecCategory.general:
        return 'General';
      case SpecCategory.hardware:
        return 'SoC / CPU';
      case SpecCategory.system:
        return 'System';
      case SpecCategory.display:
        return 'Display';
      case SpecCategory.battery:
        return 'Battery';
      case SpecCategory.network:
        return 'Network';
      case SpecCategory.storage:
        return 'Storage';
      case SpecCategory.security:
        return 'Security';
    }
  }

  Widget _buildHeaderCard(BuildContext context, List<SpecItem> specs) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final brandSpec = specs.firstWhere(
      (s) => s.id == 'brand_model' || s.id == 'browser_name' || s.id == 'ios_name' || s.id == 'gen_device',
      orElse: () => const SpecItem(
        id: 'default',
        title: 'Device',
        value: 'Android Device',
        category: SpecCategory.general,
        icon: Icons.phone_android,
        conceptExplanation: '',
        howToEvaluate: '',
        benchmarkAdvice: '',
      ),
    );

    final osSpec = specs.firstWhere(
      (s) => s.id == 'android_version' || s.id == 'ios_version',
      orElse: () => const SpecItem(
        id: 'default_os',
        title: 'Operating System',
        value: 'Mobile OS',
        category: SpecCategory.system,
        icon: Icons.android,
        conceptExplanation: '',
        howToEvaluate: '',
        benchmarkAdvice: '',
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.devices_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE DEVICE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      brandSpec.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  osSpec.value,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.lightGreenAccent, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(color: Colors.lightGreenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(BuildContext context, SpecItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showSpecDetailSheet(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(item.icon, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.categoryName,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy spec',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '${item.title}: ${item.value}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied "${item.title}" to clipboard'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tap to view concept explanation & evaluation guide',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpecDetailSheet(BuildContext context, SpecItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(item.icon, color: colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              item.categoryName,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reported Device Value:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          item.value,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Concept Explanation
                  _buildSectionHeader(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'What does this spec mean?',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.conceptExplanation,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // How to evaluate
                  _buildSectionHeader(
                    context,
                    icon: Icons.check_circle_outline_rounded,
                    title: 'How to Evaluate & Compare',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.howToEvaluate,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Benchmark tip
                  _buildSectionHeader(
                    context,
                    icon: Icons.speed_rounded,
                    title: 'Benchmark & Testing Advice',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorScheme.tertiary.withAlpha(50)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates_rounded, size: 20, color: colorScheme.tertiary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.benchmarkAdvice,
                            style: TextStyle(fontSize: 13, color: colorScheme.onTertiaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: '${item.title}: ${item.value}\nConcept: ${item.conceptExplanation}\nEvaluation: ${item.howToEvaluate}'));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied full details of ${item.title}')),
                        );
                      },
                      icon: const Icon(Icons.copy_all_rounded),
                      label: const Text('Copy Full Spec & Explanation'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
