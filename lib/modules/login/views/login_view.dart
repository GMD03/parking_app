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
      backgroundColor: AppColors.backgroundDark,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.grid_4x4, color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 32),
          Text(
            'PARKING\nCONTROL\nSYSTEM',
            style: GoogleFonts.ibmPlexSans(
              color: AppColors.textMain,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AUTHORIZED PERSONNEL ONLY.\nALL ACTIVITY IS LOGGED AND MONITORED.',
            style: GoogleFonts.ibmPlexMono(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.5,
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
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, 15),
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
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUTHENTICATION',
                style: GoogleFonts.ibmPlexSans(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SECURE NODE',
                style: GoogleFonts.ibmPlexMono(
                  color: AppColors.primary,
                  fontSize: 10,
                  letterSpacing: 1.5,
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
    final color = isSuccess ? AppColors.success : AppColors.danger;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          controller.nodeStatus.value,
          style: GoogleFonts.ibmPlexMono(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
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
          style: GoogleFonts.ibmPlexMono(
            color: AppColors.muted,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        // We use textInputAction to determine what the 'Enter' key does natively on the field
        TextField(
          controller: controller,
          obscureText: isObscured,
          style: GoogleFonts.ibmPlexMono(
            color: AppColors.textMain,
            fontSize: 16,
          ),
          textInputAction: isObscured ? TextInputAction.done : TextInputAction.next,
          // When the user hits 'Enter' while typing in the passcode field, submit!
          onSubmitted: isObscured ? (_) => this.controller.authenticate() : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
            filled: true,
            fillColor: AppColors.backgroundDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.authenticate,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDark,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
      ),
      child: Center(
        child: controller.isLoading.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.backgroundDark,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '[ INITIATE HANDSHAKE ]',
                    style: GoogleFonts.ibmPlexSans(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.login, size: 18),
                ],
              ),
      ),
    ));
  }
}