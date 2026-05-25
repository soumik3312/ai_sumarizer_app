import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int noteCount;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.noteCount = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? noteCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      noteCount: noteCount ?? this.noteCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'noteCount': noteCount,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue']),
      noteCount: json['noteCount'] ?? 0,
    );
  }
}

// Predefined categories
class DefaultCategories {
  static List<Category> get all => [
    Category(
      id: 'work',
      name: 'Work',
      icon: Icons.work_outline,
      color: const Color(0xFF7C3AED),
    ),
    Category(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person_outline,
      color: const Color(0xFF06B6D4),
    ),
    Category(
      id: 'study',
      name: 'Study',
      icon: Icons.school_outlined,
      color: const Color(0xFF10B981),
    ),
    Category(
      id: 'ideas',
      name: 'Ideas',
      icon: Icons.lightbulb_outline,
      color: const Color(0xFFF59E0B),
    ),
    Category(
      id: 'meetings',
      name: 'Meetings',
      icon: Icons.groups_outlined,
      color: const Color(0xFFEC4899),
    ),
    Category(
      id: 'research',
      name: 'Research',
      icon: Icons.science_outlined,
      color: const Color(0xFF6366F1),
    ),
  ];
}
