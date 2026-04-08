import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: GridPainter()),
            ),
          ),
          Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  _buildLabel('Operator ID', 'REQ_01'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.operatorIdController, // Bind Controller
                    style: GoogleFonts.ibmPlexMono(color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: 'ENTER_ID...',
                      hintStyle: GoogleFonts.ibmPlexMono(color: AppColors.muted.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Passcode', 'REQ_02'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.passcodeController, // Bind Controller
                    obscureText: true,
                    style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, letterSpacing: 4),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: GoogleFonts.ibmPlexMono(color: AppColors.muted.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  
                  // Wrap the button in Obx to listen to loading state
                  Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      foregroundColor: AppColors.backgroundDark,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading.value 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: AppColors.backgroundDark, strokeWidth: 2)
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '[ AUTHENTICATE ]',
                                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.login, size: 18),
                            ],
                          ),
                  )),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),
                  
                  // Wrap Status in Obx to react to changes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: controller.isStatusSuccess.value ? AppColors.success : AppColors.danger,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: controller.isStatusSuccess.value ? AppColors.success : AppColors.danger, 
                                  blurRadius: 5
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.nodeStatus.value,
                            style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10),
                          ),
                        ],
                      )),
                      Text(
                        'TERM: LCL-4A',
                        style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 10),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            'SYSTEM_ACCESS_PORTAL',
            style: GoogleFonts.ibmPlexMono(color: AppColors.muted, fontSize: 12, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            'SYS.LOGIN.V1.4',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.5),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }

  Widget _buildLabel(String mainText, String subText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          mainText.toUpperCase(),
          style: GoogleFonts.ibmPlexSans(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        Text(
          subText,
          style: GoogleFonts.ibmPlexMono(color: AppColors.muted.withOpacity(0.5), fontSize: 10),
        ),
      ],
    );
  }
}

// Background Pattern
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 40) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 40) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}