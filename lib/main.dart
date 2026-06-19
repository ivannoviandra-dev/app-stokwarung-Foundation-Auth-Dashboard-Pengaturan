import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/pengaturan/presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://exjkwvlaovwbejudhcwn.supabase.co',
    anonKey: 'sb_publishable_CTYudOAovz4tzo786gOnKg_xszgieRC',
  );

  // Inisialisasi notifikasi lokal
  await NotificationService().init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider.select((s) => s.darkMode));

    const seedColor = Color(0xFF10A87A);

    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF4FBF4),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4FBF4),
        foregroundColor: Color(0xFF161D19),
      ),
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF161D19),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E2B22),
        foregroundColor: Color(0xFFE3EAE3),
      ),
    );

    return MaterialApp.router(
      title: 'StokWarung',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
