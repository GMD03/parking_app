import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'core/routes/app_pages.dart'; // Import your new AppPages
import 'core/routes/app_routes.dart'; // Import your new Routes

Process? _hardwareDaemon;

void main() async {
  // Ensure Flutter bindings are initialized before async tasks
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize standard DatabaseService
  await DatabaseService.init();

  // Encapsulated Python Hardware Daemon
  try {
    // During dev it routes locally, during exe deployment it routes alongside the exe
    final exePath = 'hardware_api\\hardware_daemon.exe';
    
    _hardwareDaemon = await Process.start(
      exePath,
      [],
      mode: ProcessStartMode.normal, // Ties the daemon lifecycle directly to Flutter
    );
    print('✅ Hardware Daemon launched natively.');

    // Capture logs straight from the python EXE!
    _hardwareDaemon?.stdout.listen((event) {
      final log = String.fromCharCodes(event).trim();
      if (log.isNotEmpty) print('[DAEMON] $log');
    });
    
    _hardwareDaemon?.stderr.listen((event) {
      final log = String.fromCharCodes(event).trim();
      if (log.isNotEmpty) print('[DAEMON ERR] $log');
    });
  } catch (e) {
    print('❌ Failed to start hardware daemon: $e');
  }

  runApp(const SystemAccessPortal());
}

class SystemAccessPortal extends StatelessWidget {
  const SystemAccessPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LuvPark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.surface,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: AppColors.onSurface,
          displayColor: AppColors.onSurface,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: UnderlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      // GetX Routing Setup - Using the new modular AppPages list
      // Initial route set to SPLASH to handle the one-time setup logic
      initialRoute: Routes.SPLASH,
      getPages: AppPages.pages,
    );
  }
}
