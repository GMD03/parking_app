import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for LogicalKeyboardKey
import 'package:get/get.dart';
import '../controllers/device_registration_controller.dart';
import '../../../core/theme/app_colors.dart'; // Imported your AppColors

class DeviceRegistrationView extends GetView<DeviceRegistrationController> {
  const DeviceRegistrationView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Replaced local surface color with AppColors.backgroundDark
      backgroundColor: AppColors.backgroundDark,
      // Wrap the entire body in a Focus widget to catch Enter key presses
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // If the user presses the 'Enter' key on their keyboard...
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            // ...and we aren't already loading...
            if (!controller.isRegistering.value) {
              // ...trigger the registration function!
              controller.registerTerminal();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                decoration: BoxDecoration(
                  // Replaced local surfaceContainer color with AppColors.surface
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTerminalIdDisplay(),
                          const SizedBox(height: 32),
                          _buildInputField(
                            label: 'FACILITY CODE',
                            ctrl: controller.facilityCodeController,
                            icon: Icons.domain,
                            isObscure: false,
                            // Next action to move to the token field
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 24),
                          _buildInputField(
                            label: 'SECURITY TOKEN',
                            ctrl: controller.securityTokenController,
                            icon: Icons.vpn_key,
                            isObscure: true,
                            // Done action to submit the form
                            textInputAction: TextInputAction.done,
                            // Allow 'Enter' key inside the text field to trigger submission
                            onSubmitted: (_) => controller.registerTerminal(),
                          ),
                          const SizedBox(height: 48),
                          _buildRegisterButton(),
                        ],
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Replaced local onSurface color with AppColors.textMain
              Text(
                'DEVICE REGISTRATION',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'NEW NODE DETECTED',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.router,
              color: AppColors.primary,
              size: 20,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTerminalIdDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASSIGNED TERMINAL ID',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            // Replaced local surfaceContainerLow color with AppColors.backgroundDark
            color: AppColors.backgroundDark,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    controller.terminalId.value,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: AppColors.success,
                    ),
                  )),
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 16,
              )
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildInputField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required bool isObscure,
    required TextInputAction textInputAction,
    Function(String)? onSubmitted,
  }) {
    
    // 1. Helper method to build the TextField so we don't repeat code
    Widget buildTextField(bool isHidden) {
      return TextField(
        controller: ctrl,
        obscureText: isHidden,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          letterSpacing: isHidden ? 4 : 2,
          color: AppColors.textMain,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.muted, size: 18),
          suffixIcon: isObscure
              ? IconButton(
                  icon: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.muted,
                    size: 18,
                  ),
                  onPressed: controller.toggleTokenVisibility,
                  splashRadius: 20,
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1.5,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        // 2. THE FIX: Only wrap in Obx if this field is meant to be obscured (Security Token).
        // If it's a standard field (Facility Code), just return the normal TextField.
        isObscure 
            ? Obx(() => buildTextField(controller.isTokenObscured.value)) 
            : buildTextField(false),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isRegistering.value ? null : controller.registerTerminal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark, // onPrimaryFixed equivalent
            disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: Center(
            child: controller.isRegistering.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.backgroundDark,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '[ AUTHENTICATE DEVICE ]',
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
          ),
        ));
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PING',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),
                  const Text(
                    '12ms',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEC_LVL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),
                  const Text(
                    'HIGH',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'UTC: ${DateTime.now().toUtc().toString().substring(0, 19).replaceAll(' ', '_')}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}