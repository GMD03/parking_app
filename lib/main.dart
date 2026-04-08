import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'core/routes/app_pages.dart'; // Import your new AppPages
import 'core/routes/app_routes.dart'; // Import your new Routes

void main() {
  runApp(const SystemAccessPortal());
}

class SystemAccessPortal extends StatelessWidget {
  const SystemAccessPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Industrial Control Parking System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        textTheme: GoogleFonts.ibmPlexSansTextTheme().apply(
          bodyColor: AppColors.textMain,
          displayColor: AppColors.textMain,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
      // GetX Routing Setup - Using the new modular AppPages list
      // Set to DEVICE_REGISTRATION to test the UI right now.
      initialRoute: Routes.DEVICE_REGISTRATION,
      getPages: AppPages.pages,
    );
  }
}
