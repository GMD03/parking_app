import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'modules/login/bindings/login_binding.dart';
import 'modules/login/views/login_view.dart';

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
      // GetX Routing Setup
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: LoginBinding(), // Injects Controller
        ),
        // Add Dashboard route here later!
      ],
    );
  }
}