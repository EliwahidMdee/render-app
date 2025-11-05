import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/core/presentation/providers/theme_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/notifications/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase may not be configured yet, continue anyway
    print('Firebase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: LiveAgentApp(),
    ),
  );
}

class LiveAgentApp extends ConsumerStatefulWidget {
  const LiveAgentApp({super.key});

  @override
  ConsumerState<LiveAgentApp> createState() => _LiveAgentAppState();
}

class _LiveAgentAppState extends ConsumerState<LiveAgentApp> {
  FCMService? _fcmService;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      final dioClient = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);
      _fcmService = FCMService(dioClient, storage);
      await _fcmService!.initialize();
    } catch (e) {
      print('FCM initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _fcmService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      home: authState.isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : authState.isLoggedIn
              ? const DashboardScreen()
              : const LoginScreen(),
    );
  }
}
