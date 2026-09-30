import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/services/storage_service.dart';

/// The account profile shown at the top of the Profile tab and editable from
/// the "Personal details" page.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
  });

  final String name;
  final String email;
  final String phone;
  final String city;

  static const UserProfile defaultProfile = UserProfile(
    name: 'Anoop Gupta',
    email: 'anoop.gupta@example.com',
    phone: '1234567890',
    city: 'Mumbai',
  );

  /// Two-letter avatar initials derived from the first and last word.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0].toUpperCase();
    final last = parts.length > 1 && parts.last.isNotEmpty
        ? parts.last[0].toUpperCase()
        : '';
    return '$first$last';
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'city': city,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? defaultProfile.name,
    email: json['email'] as String? ?? defaultProfile.email,
    phone: json['phone'] as String? ?? defaultProfile.phone,
    city: json['city'] as String? ?? defaultProfile.city,
  );
}

/// Persists and exposes the editable user profile.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._storage) {
    _profile = _read();
  }

  final StorageService _storage;
  late UserProfile _profile;

  static const _key = 'user_profile';

  UserProfile get profile => _profile;

  UserProfile _read() {
    final raw = _storage.readString(_key);
    if (raw.isEmpty) return UserProfile.defaultProfile;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile.defaultProfile;
    }
  }

  void update({String? name, String? email, String? phone, String? city}) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      phone: phone,
      city: city,
    );
    _storage.writeString(_key, jsonEncode(_profile.toJson()));
    notifyListeners();
  }
}
