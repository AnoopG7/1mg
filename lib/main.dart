import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/interaction_provider.dart';
import 'providers/lab_provider.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/pro_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/saved_provider.dart';
import 'providers/symptom_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final storage = await StorageService.init();
  final auth = AuthProvider();
  await auth.ready;
  await storage.hydrateFromFirestore();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => CartProvider(storage)),
        ChangeNotifierProvider(create: (_) => OrderProvider(storage)),
        ChangeNotifierProvider(create: (_) => ReminderProvider(storage)),
        ChangeNotifierProxyProvider<AuthProvider, ProProvider>(
          create: (_) => ProProvider(storage),
          update: (_, auth, pro) {
            final value = pro ?? ProProvider(storage);
            value.syncAccountName(auth.accountName);
            return value;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SavedProvider>(
          create: (_) => SavedProvider(storage),
          update: (_, auth, saved) {
            final value = saved ?? SavedProvider(storage);
            value.syncAccountName(auth.accountName);
            return value;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(storage),
          update: (_, auth, profile) {
            final value = profile ?? ProfileProvider(storage);
            value.syncFromAccount(
              name: auth.accountName,
              email: auth.user?.email,
            );
            return value;
          },
        ),
        ChangeNotifierProvider(create: (_) => LabProvider(storage)),
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
        ChangeNotifierProvider(create: (_) => InteractionProvider()),
      ],
      child: const OneMgApp(),
    ),
  );
}

class OneMgApp extends StatelessWidget {
  const OneMgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '1mg Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        // Keep text scaled to a readable range across devices.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
    );
  }
}
