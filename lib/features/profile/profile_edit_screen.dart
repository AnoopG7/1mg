import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/profile_provider.dart';
import '../../shared/widgets/common.dart';

/// Editable personal profile page.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _city;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: p.name);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _city = TextEditingController(text: p.city);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }
    context.read<ProfileProvider>().update(
      name: name,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      city: _city.text.trim(),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Personal details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.xxl,
        ),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                p.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _city,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save changes'),
          ),
          const SizedBox(height: AppSpacing.md),
          const NoticeBanner(
            color: AppColors.textTertiary,
            icon: Icons.info_rounded,
            message:
                'Profile is saved only on this device for this demo. No data '
                'is uploaded anywhere.',
          ),
        ],
      ),
    );
  }
}
