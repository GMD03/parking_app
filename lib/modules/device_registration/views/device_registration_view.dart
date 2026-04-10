import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/device_registration_controller.dart';

class DeviceRegistrationView extends GetView<DeviceRegistrationController> {
  const DeviceRegistrationView({Key? key}) : super(key: key);

  // Colors mapped from the provided Tailwind config
  static const Color surface = Color(0xFF121416);
  static const Color surfaceContainer = Color(0xFF1E2022);
  static const Color surfaceContainerLow = Color(0xFF1A1C1E);
  static const Color onSurface = Color(0xFFE2E2E5);
  static const Color outlineVariant = Color(0xFF524533);
  static const Color outline = Color(0xFF9F8E78);
  static const Color primaryFixedDim = Color(0xFFFFBA43);
  static const Color primaryContainer = Color(0xFFFFB000);
  static const Color onPrimaryFixed = Color(0xFF281800);
  static const Color secondaryFixedDim = Color(0xFF00E475);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // Fix applied here
              decoration: BoxDecoration(
                color: surfaceContainer,
                border: Border.all(color: outlineVariant.withOpacity(0.3)),
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
                        _buildTerminalIdField(),
                        const SizedBox(height: 24),
                        _buildFacilityCodeField(),
                        const SizedBox(height: 24),
                        _buildSecurityTokenField(),
                        const SizedBox(height: 32),
                        _buildActionSection(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: outlineVariant.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'DEVICE_REGISTRATION_PORTAL',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: onSurface,
                ),
              ),
              Icon(
                Icons.settings_input_component,
                color: primaryFixedDim,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SYS.NODE.REG.V2.0',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 2.0,
              color: primaryFixedDim.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TERMINAL ID',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 10,
            letterSpacing: 1.5,
            color: outline,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceContainerLow,
            border: Border.all(color: outlineVariant.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Text(
                'ID_',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: outline.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  controller.terminalId.value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: secondaryFixedDim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FACILITY CODE',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 10,
            letterSpacing: 1.5,
            color: outline,
          ),
        ),
        TextField(
          controller: controller.facilityCodeController,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: onSurface,
          ),
          cursorColor: primaryFixedDim,
          decoration: const InputDecoration(
            hintText: '####-####-####',
            hintStyle: TextStyle(color: Color(0xFF333537)), // surface-variant
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: outlineVariant),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryFixedDim),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTokenField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SECURITY TOKEN',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 10,
            letterSpacing: 1.5,
            color: outline,
          ),
        ),
        Obx(
          () => TextField(
            controller: controller.securityTokenController,
            obscureText: controller.isTokenObscured.value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: onSurface,
            ),
            cursorColor: primaryFixedDim,
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: outlineVariant),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: primaryFixedDim),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isTokenObscured.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: outline,
                  size: 18,
                ),
                onPressed: controller.toggleTokenVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isRegistering.value
                  ? null
                  : controller.registerTerminal,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryContainer,
                disabledBackgroundColor: primaryContainer.withOpacity(0.5),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              child: controller.isRegistering.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          onPrimaryFixed,
                        ),
                      ),
                    )
                  : const Text(
                      '[ REGISTER TERMINAL ]',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: onPrimaryFixed,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: outlineVariant,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: outlineVariant.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'NODE_PENDING_REGISTRATION',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: outline.withOpacity(0.6),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.1))),
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
                    'LATENCY',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: outline.withOpacity(0.4),
                    ),
                  ),
                  const Text(
                    '12ms',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: secondaryFixedDim,
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
                      color: outline.withOpacity(0.4),
                    ),
                  ),
                  const Text(
                    'HIGH',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: primaryFixedDim,
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
              color: outline.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
