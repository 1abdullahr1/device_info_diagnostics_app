import 'package:flutter/material.dart';
import '../data/device_data_service.dart';
import '../models/spec_item.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final terms = DeviceDataService.instance.getGlossaryTerms();

    final categories = ['All', ...terms.map((t) => t.category).toSet().toList()];

    final filteredTerms = _selectedCategory == 'All'
        ? terms
        : terms.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hardware Concepts & Guide',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'How to understand & evaluate smartphone specs',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Educational Header Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade800,
                      Colors.blueGrey.shade900,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, color: Colors.amberAccent, size: 26),
                        SizedBox(width: 10),
                        Text(
                          'Specs Evaluation Masterclass',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Smartphone marketing is filled with confusing numbers and acronyms. Learn what each hardware spec really means and how to separate marketing hype from genuine performance.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories Filter
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Terms List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final term = filteredTerms[index];
                  return _buildTermCard(context, term);
                },
                childCount: filteredTerms.length,
              ),
            ),
          ),

          // Buying Advice Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildBuyingRulesCard(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildTermCard(BuildContext context, GlossaryTerm term) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    term.category,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              term.term,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            // Definition
            Text(
              term.definition,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),

            // Practical Meaning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Why It Matters in Real Life:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    term.practicalMeaning,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Buying Rule / Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withAlpha(60)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.thumb_up_alt_rounded, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Evaluation Rule: ${term.buyingTip}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyingRulesCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.surfaceContainerHigh,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rtl_rounded, color: colorScheme.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Quick Smartphone Evaluation Checklist',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildChecklistItem('1. Processor (SoC)', 'Look for 4nm / 3nm chips with modern Cortex-X cores.'),
            _buildChecklistItem('2. RAM Capacity', 'Minimum 8GB RAM for Android 14+ multitasking.'),
            _buildChecklistItem('3. Storage Speed', 'Verify UFS 3.1 or UFS 4.0; reject eMMC 5.1 storage.'),
            _buildChecklistItem('4. Display Tech', '120Hz AMOLED with DC Dimming / high PWM frequency.'),
            _buildChecklistItem('5. Streaming DRM', 'Verify Widevine L1 for 1080p Full HD Netflix & streaming.'),
            _buildChecklistItem('6. Software Updates', 'Check if brand promises at least 3-4 years of Android OS updates.'),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
