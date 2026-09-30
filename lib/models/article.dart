import 'package:flutter/material.dart';

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
    required this.accentColor,
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
  final Color accentColor;

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
