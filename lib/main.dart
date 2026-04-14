import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'core/routes/app_pages.dart'; // Import your new AppPages
import 'core/routes/app_routes.dart'; // Import your new Routes

Process? _hardwareDaemon;

Future<void> writeLog(String message) async {
  final logFile = File('luvpark_system.log');
  final timestamp =
      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';
  try {
    await logFile.writeAsString(
      '[$timestamp] $message\n',
      mode: FileMode.append,
    );
  } catch (e) {
    // Failsafe if file is locked
  }
}

void main() async {
  // Ensure Flutter bindings are initialized before async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize standard DatabaseService
  await DatabaseService.init();

  // await DatabaseService.eraseAll();
  // await DatabaseService.seedTestTickets();
  // Encapsulated Python Hardware Daemon
  try {
    writeLog('SYSTEM BOOT: Initializing Local Environment...');

    // robust path resolution for Release vs Debug vs CWD
    final String executableDir = File(Platform.resolvedExecutable).parent.path;
    String exePath = '$executableDir\\hardware_api\\hardware_daemon.exe';

    if (!File(exePath).existsSync()) {
      // Fallback for 'flutter run' (Current Working Directory)
      exePath = 'hardware_api\\hardware_daemon.exe';
    }

    if (!File(exePath).existsSync()) {
      // Hardcoded fallback for Development when running release exe directly from build folder
      exePath = 'c:\\parking_app\\hardware_api\\hardware_daemon.exe';
    }

    _hardwareDaemon = await Process.start(
      exePath,
      [],
      mode: ProcessStartMode
          .normal, // Ties the daemon lifecycle directly to Flutter
    );
    writeLog(
      '✅ Hardware Daemon launched natively on process ID: ${_hardwareDaemon?.pid}',
    );

    // Capture logs straight from the python EXE and pipe to text file!
    _hardwareDaemon?.stdout.listen((event) {
      final log = String.fromCharCodes(event).trim();
      if (log.isNotEmpty) {
        print('[DAEMON] $log');
        writeLog('[DAEMON] $log');
      }
    });

    _hardwareDaemon?.stderr.listen((event) {
      final log = String.fromCharCodes(event).trim();
      if (log.isNotEmpty) {
        print('[DAEMON ERR] $log');
        writeLog('[DAEMON ERR] $log');
      }
    });
  } catch (e) {
    writeLog('❌ Failed to start hardware daemon: $e');
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
