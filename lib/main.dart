import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';
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
  final storage = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider(storage)),
        ChangeNotifierProvider(create: (_) => OrderProvider(storage)),
        ChangeNotifierProvider(create: (_) => ReminderProvider(storage)),
        ChangeNotifierProvider(create: (_) => ProProvider(storage)),
        ChangeNotifierProvider(create: (_) => SavedProvider(storage)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(storage)),
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
      home: const AppShell(),
    );
  }
}
