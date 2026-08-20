import 'package:flutter/material.dart';

enum SpecCategory {
  general,
  hardware,
  system,
  display,
  battery,
  network,
  storage,
  security,
}

class SpecItem {
  final String id;
  final String title;
  final String value;
  final SpecCategory category;
  final IconData icon;
  final String conceptExplanation;
  final String howToEvaluate;
  final String benchmarkAdvice;
  final List<String> searchKeywords;

  const SpecItem({
    required this.id,
    required this.title,
    required this.value,
    required this.category,
    required this.icon,
    required this.conceptExplanation,
    required this.howToEvaluate,
    required this.benchmarkAdvice,
    this.searchKeywords = const [],
  });

  String get categoryName {
    switch (category) {
      case SpecCategory.general:
        return 'General Info';
      case SpecCategory.hardware:
        return 'Hardware & SoC';
      case SpecCategory.system:
        return 'OS & System';
      case SpecCategory.display:
        return 'Screen & Display';
      case SpecCategory.battery:
        return 'Battery & Power';
      case SpecCategory.network:
        return 'Network & Wireless';
      case SpecCategory.storage:
        return 'RAM & Storage';
      case SpecCategory.security:
        return 'Security & DRM';
    }
  }
}

class GlossaryTerm {
  final String term;
  final String category;
  final String definition;
  final String practicalMeaning;
  final String buyingTip;
  final String iconName;

  const GlossaryTerm({
    required this.term,
    required this.category,
    required this.definition,
    required this.practicalMeaning,
    required this.buyingTip,
    required this.iconName,
  });
}
