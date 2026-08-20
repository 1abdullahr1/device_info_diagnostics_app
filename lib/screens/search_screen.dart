import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/device_data_service.dart';
import '../models/spec_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<String> _quickFilters = [
    'RAM',
    'CPU / SoC',
    'Display',
    'UFS Storage',
    'Widevine',
    'Battery',
    'API Level',
    '64-bit ABI',
    'Refresh Rate',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allSpecs = DeviceDataService.instance.specs;
    final glossaryTerms = DeviceDataService.instance.getGlossaryTerms();

    final filteredSpecs = _query.isEmpty
        ? allSpecs
        : allSpecs.where((item) {
            final q = _query.toLowerCase();
            final inTitle = item.title.toLowerCase().contains(q);
            final inValue = item.value.toLowerCase().contains(q);
            final inConcept = item.conceptExplanation.toLowerCase().contains(q);
            final inKeywords = item.searchKeywords.any((k) => k.toLowerCase().contains(q));
            final inCategory = item.categoryName.toLowerCase().contains(q);
            return inTitle || inValue || inConcept || inKeywords || inCategory;
          }).toList();

    final filteredGlossary = _query.isEmpty
        ? []
        : glossaryTerms.where((term) {
            final q = _query.toLowerCase();
            return term.term.toLowerCase().contains(q) ||
                term.definition.toLowerCase().contains(q) ||
                term.practicalMeaning.toLowerCase().contains(q) ||
                term.category.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Specs & Knowledge',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search specs, terms (e.g. RAM, UFS, SoC, L1)...',
              leading: const Icon(Icons.search_rounded),
              trailing: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                });
              },
            ),
          ),

          // Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _quickFilters.map((filter) {
                final isSelected = _query.toLowerCase() == filter.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    avatar: Icon(Icons.search_rounded, size: 14, color: colorScheme.primary),
                    label: Text(filter),
                    backgroundColor: isSelected ? colorScheme.primaryContainer : null,
                    onPressed: () {
                      _searchController.text = filter;
                      setState(() {
                        _query = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Results Count Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _query.isEmpty
                      ? 'All Specifications (${filteredSpecs.length})'
                      : 'Results (${filteredSpecs.length} specs, ${filteredGlossary.length} glossary terms)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: filteredSpecs.isEmpty && filteredGlossary.isEmpty
                ? _buildEmptyState(context)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Specs Section
                      if (filteredSpecs.isNotEmpty) ...[
                        if (_query.isNotEmpty)
                          _buildSectionTitle(context, 'Matched Hardware & Device Specs'),
                        ...filteredSpecs.map((item) => _buildSpecItemCard(context, item)),
                      ],

                      // Matched Glossary Terms Section
                      if (filteredGlossary.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionTitle(context, 'Matched Concept & Evaluation Guides'),
                        ...filteredGlossary.map((term) => _buildGlossaryCard(context, term)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSpecItemCard(BuildContext context, SpecItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(item.icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.conceptExplanation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: () => _showDetailDialog(context, item),
      ),
    );
  }

  Widget _buildGlossaryCard(BuildContext context, GlossaryTerm term) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: colorScheme.secondaryContainer.withAlpha(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.secondary.withAlpha(50)),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(Icons.school_rounded, color: colorScheme.secondary, size: 20),
        ),
        title: Text(
          term.term,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          term.category,
          style: TextStyle(fontSize: 12, color: colorScheme.secondary),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  'Definition:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(term.definition, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Text(
                  'Practical Impact:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(term.practicalMeaning, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          term.buyingTip,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withAlpha(120)),
          const SizedBox(height: 16),
          const Text(
            'No matching specs or concepts found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try searching for "RAM", "UFS", "SoC", "Display", or "Battery"',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, SpecItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(item.icon, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'What it means:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(item.conceptExplanation, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 12),
                const Text(
                  'How to Evaluate:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(item.howToEvaluate, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '${item.title}: ${item.value}'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Spec copied to clipboard')),
                );
              },
              child: const Text('Copy Spec'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
