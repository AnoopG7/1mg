import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';

/// Doctor profile that verifies an article.
class Doctor {
  const Doctor({
    required this.name,
    required this.speciality,
    required this.qualification,
    required this.experienceYears,
    required this.verified,
  });

  final String name;
  final String speciality;
  final String qualification;
  final int experienceYears;
  final bool verified;

  Map<String, dynamic> toJson() => {
        'name': name,
        'speciality': speciality,
        'qualification': qualification,
        'experienceYears': experienceYears,
        'verified': verified,
      };

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        name: json['name'] as String? ?? '',
        speciality: json['speciality'] as String? ?? '',
        qualification: json['qualification'] as String? ?? '',
        experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
        verified: json['verified'] as bool? ?? false,
      );
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.doctor,
    required this.readMinutes,
    required this.publishedOn,
    required this.views,
    required this.likes,
    required this.tags,
    required this.accentColorValue,
  });

  final String id;
  final String title;
  final String summary;

  /// Paragraphs, each may start with "## " for a sub-heading.
  final List<String> body;
  final String category;
  final Doctor doctor;
  final int readMinutes;
  final DateTime publishedOn;
  final int views;
  final int likes;
  final List<String> tags;

  /// ARGB int so the accent tint serialises.
  final int accentColorValue;

  Color get accentColor => IconRegistry.colorFromHex(accentColorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'body': body,
        'category': category,
        'doctor': doctor.toJson(),
        'readMinutes': readMinutes,
        'publishedOn': publishedOn.toIso8601String(),
        'views': views,
        'likes': likes,
        'tags': tags,
        'accentColorValue': accentColorValue,
      };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        body: (json['body'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        category: json['category'] as String? ?? '',
        doctor: json['doctor'] is Map<String, dynamic>
            ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
            : const Doctor(
                name: '',
                speciality: '',
                qualification: '',
                experienceYears: 0,
                verified: false,
              ),
        readMinutes: (json['readMinutes'] as num?)?.toInt() ?? 1,
        publishedOn: json['publishedOn'] == null
            ? DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.parse(json['publishedOn'] as String),
        views: (json['views'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        tags: (json['tags'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        accentColorValue: (json['accentColorValue'] as num?)?.toInt() ?? 0xFF2C6BED,
      );

  static const List<String> categories = [
    'Diabetes',
    'Heart Health',
    'Nutrition',
    'Mental Health',
    'Skin',
    'Fitness',
    'Women\'s Health',
    'Common Ailments',
  ];
}
