import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for LogicalKeyboardKey
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // Wrap the entire body in a Focus widget to catch Enter key presses
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // If the user presses the 'Enter' key on their keyboard...
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            // ...and we aren't already loading...
            if (!controller.isLoading.value) {
              // ...trigger the login function!
              controller.authenticate();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: [
                Expanded(child: _buildBrandingSection()),
                Expanded(child: _buildLoginSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/logo.png', width: 80, height: 80),
          const SizedBox(height: 32),
          Text(
            'LuvPark',
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 56,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aero-utility parking management system.\nSecure authorized access only.',
            style: GoogleFonts.inter(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSection() {
    return Container(
      margin: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(14, 29, 40, 0.08),
            blurRadius: 48,
            offset: Offset(0, 24),
            spreadRadius: -12,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLoginHeader(),
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  label: 'OPERATOR ID',
                  controller: controller.operatorIdController,
                  icon: Icons.badge_outlined,
                  isObscured: false,
                ),
                const SizedBox(height: 32),
                _buildInputField(
                  label: 'SECURITY PASSCODE',
                  controller: controller.passcodeController,
                  icon: Icons.password_outlined,
                  isObscured: true,
                ),
                const SizedBox(height: 48),
                _buildLoginButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LuvPark Network',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Obx(() => _buildStatusIndicator()),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isSuccess = controller.isStatusSuccess.value;
    final color = isSuccess ? AppColors.secondaryContainer : AppColors.danger;
    final textColor = isSuccess ? AppColors.onSecondaryContainer : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            controller.nodeStatus.value,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isObscured,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // We use textInputAction to determine what the 'Enter' key does natively on the field
        TextField(
          controller: controller,
          obscureText: isObscured,
          style: GoogleFonts.inter(
            color: AppColors.onSurface,
            fontSize: 16,
          ),
          textInputAction: isObscured ? TextInputAction.done : TextInputAction.next,
          // When the user hits 'Enter' while typing in the passcode field, submit!
          onSubmitted: isObscured ? (_) => this.controller.authenticate() : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.authenticate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.surfaceContainerLowest,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
          disabledForegroundColor: AppColors.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Center(
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.surfaceContainerLowest,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Access Console',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      ),
    ));
  }
}