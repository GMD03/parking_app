import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/theme/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject the controller here so it runs automatically
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}
