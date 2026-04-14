import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/login_controller.dart';
import '../../../core/widgets/aerostatic_button.dart';
import 'dart:ui';
import 'dart:math' as math;

// ---------------------------------------------------------------------------
// UI/UX Pro Max References Applied:
//   Colors:  Parking Finder (#154) — Available blue/green + occupied red
//   Styles:  Glassmorphism (#3) + Aurora UI (#10) + Dimensional Layering (#46)
//   Landing: Enterprise Gateway (#25) + Real-Time Ops (#34)
//   Typo:    Minimal Swiss (#5) — Inter single-family system
//   UX:      Duration 150-300ms (#8), Easing ease-out (#14), Active States (#30)
// ---------------------------------------------------------------------------

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (!controller.isLoading.value) {
              controller.authenticate();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // Layer 1: Aurora mesh gradient background
            Positioned.fill(
              child: CustomPaint(
                painter: AuroraBackgroundPainter(screenSize: screenSize),
              ),
            ),

            // Layer 2: Floating geometric accents
            ..._buildFloatingAccents(screenSize),

            // Layer 3: Main content
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildHeroContent(screenSize)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Floating geometric accents (dots, rings, striped elements) ───
  List<Widget> _buildFloatingAccents(Size screenSize) {
    return [
      // Top-left dot cluster
      Positioned(
        top: 120,
        left: 60,
        child: _DotCluster(count: 5, color: AppColors.primaryContainer),
      ),

      // Bottom-right dot cluster
      Positioned(
        bottom: 100,
        right: 80,
        child: _DotCluster(count: 4, color: AppColors.secondary),
      ),

      // Top-right floating ring
      Positioned(
        top: 80,
        right: 120,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.18),
              width: 2,
            ),
          ),
        ),
      ),

      // Bottom-left floating ring (larger)
      Positioned(
        bottom: 150,
        left: 40,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              width: 2,
            ),
          ),
        ),
      ),

      // Small striped pattern — top right area
      Positioned(
        top: 200,
        right: 200,
        child: Column(
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),

      // Cross/plus accent — bottom center area
      Positioned(
        bottom: 60,
        left: screenSize.width * 0.35,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CustomPaint(
            painter: _CrossPainter(
              color: AppColors.secondary.withValues(alpha: 0.22),
            ),
          ),
        ),
      ),

      // Diamond accent — mid-left
      Positioned(
        top: screenSize.height * 0.52,
        left: 75,
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.16),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),

      // Small filled dot — upper center
      Positioned(
        top: 145,
        left: screenSize.width * 0.43,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
        ),
      ),

      // Vertical bar cluster — right side
      Positioned(
        top: screenSize.height * 0.42,
        right: 55,
        child: Row(
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(right: 5),
              width: 3,
              height: 20 + (i * 4.0),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.10 + (i * 0.04)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),

      // Arc ring — lower right
      Positioned(
        bottom: 200,
        right: 160,
        child: SizedBox(
          width: 36,
          height: 36,
          child: CustomPaint(
            painter: _ArcPainter(
              color: AppColors.secondary.withValues(alpha: 0.14),
            ),
          ),
        ),
      ),

      // Small rotated square — top mid-left
      Positioned(
        top: 260,
        left: 180,
        child: Transform.rotate(
          angle: math.pi / 6,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ];
  }

  // ─── Top navigation header ───
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 28.0),
      child: Row(
        children: [
          // Logo + Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/logo.png', width: 32, height: 32),
              ),
              const SizedBox(width: 16),
              Text(
                'LuvPark',
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Nav-style secondary text
          Text(
            'Parking Management System',
            style: GoogleFonts.inter(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(width: 32),

          // Status indicator
          Obx(() => _buildStatusIndicator()),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isSuccess = controller.isStatusSuccess.value;
    final color = isSuccess ? AppColors.secondaryContainer : AppColors.danger;
    final textColor = isSuccess
        ? AppColors.onSecondaryContainer
        : AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            controller.nodeStatus.value,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero content area ───
  Widget _buildHeroContent(Size screenSize) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Column(
        children: [
          SizedBox(height: screenSize.height * 0.04),

          // Overline tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'ENTERPRISE GATEWAY',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Headline
          Text(
            'Secure Access\nConsole',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 1.08,
              letterSpacing: -1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          SizedBox(
            width: 420,
            child: Text(
              'Authorized personnel only. Authenticate with your operator credentials to access the LuvPark Network.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.muted,
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 56),

          // Login card
          _buildLoginCard(),
        ],
      ),
    );
  }

  // ─── Glassmorphic login card with dimensional layering ───
  Widget _buildLoginCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Shadow layer for depth (Dimensional Layering style #46)
        Positioned(
          left: 12,
          right: -12,
          top: 12,
          bottom: -12,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryContainer.withValues(alpha: 0.06),
                  AppColors.secondary.withValues(alpha: 0.04),
                ],
              ),
            ),
          ),
        ),

        // Main card
        Container(
          width: 460,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.06),
                blurRadius: 80,
                offset: const Offset(0, 32),
                spreadRadius: -16,
              ),
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.04),
                blurRadius: 60,
                offset: const Offset(0, -8),
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card header
                  _buildCardHeader(),

                  // Form content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 36, 40, 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          label: 'OPERATOR ID',
                          ctrl: controller.operatorIdController,
                          icon: Icons.badge_outlined,
                          isObscured: false,
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => _buildInputField(
                            label: 'SECURITY PASSCODE',
                            ctrl: controller.passcodeController,
                            icon: Icons.lock_outline_rounded,
                            isObscured: controller.isPasswordObscured.value,
                            onToggleVisibility:
                                controller.togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Obx(
                          () => AerostaticButton(
                            label: 'Access Console',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.authenticate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceVariant.withValues(alpha: 0.6),
            AppColors.surfaceContainerLow.withValues(alpha: 0.4),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
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
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LuvPark Network',
                style: GoogleFonts.inter(
                  color: AppColors.primaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          // Decorative shield icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryContainer,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input fields with focus-glow effect ───
  Widget _buildInputField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    required bool isObscured,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: isObscured,
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textInputAction: onToggleVisibility != null
                ? TextInputAction.done
                : TextInputAction.next,
            onSubmitted: onToggleVisibility != null
                ? (_) => controller.authenticate()
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(icon, color: AppColors.primaryContainer, size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              suffixIcon: onToggleVisibility != null
                  ? IconButton(
                      icon: Icon(
                        isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                      splashRadius: 20,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Custom painters & helper widgets
// ═══════════════════════════════════════════════════════════════════════════════

/// Aurora UI style (#10) — multi-color flowing mesh gradient background
/// with organic curved shapes using the app's color tokens.
class AuroraBackgroundPainter extends CustomPainter {
  final Size screenSize;
  AuroraBackgroundPainter({required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    // ── Wave 1: Top-right — Primary blue tint ──
    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryContainer.withValues(alpha: 0.09),
          AppColors.primaryFixed.withValues(alpha: 0.14),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));

    final path1 = Path();
    path1.moveTo(size.width * 0.45, 0);
    path1.cubicTo(
      size.width * 0.7,
      size.height * 0.05,
      size.width * 1.1,
      size.height * 0.1,
      size.width,
      size.height * 0.28,
    );
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // ── Wave 2: Left side — Cyan / secondary accent ──
    final paint2 = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondary.withValues(alpha: 0.06),
              AppColors.secondaryContainer.withValues(alpha: 0.09),
            ],
          ).createShader(
            Rect.fromLTWH(0, size.height * 0.2, size.width * 0.6, size.height),
          );

    final path2 = Path();
    path2.moveTo(0, size.height * 0.30);
    path2.cubicTo(
      size.width * 0.18,
      size.height * 0.24,
      size.width * 0.28,
      size.height * 0.44,
      size.width * 0.12,
      size.height * 0.62,
    );
    path2.cubicTo(
      0,
      size.height * 0.72,
      0,
      size.height * 0.50,
      0,
      size.height * 0.30,
    );
    path2.close();
    canvas.drawPath(path2, paint2);

    // ── Wave 3: Bottom — Soft surface wave ──
    final paint3 = Paint()
      ..color = AppColors.surfaceVariant.withValues(alpha: 0.6);

    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.80);
    path3.cubicTo(
      size.width * 0.2,
      size.height * 0.87,
      size.width * 0.4,
      size.height * 0.73,
      size.width * 0.65,
      size.height * 0.81,
    );
    path3.cubicTo(
      size.width * 0.85,
      size.height * 0.87,
      size.width * 0.95,
      size.height * 0.76,
      size.width,
      size.height * 0.83,
    );
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);

    // ── Wave 4: Top-left — Subtle surface accent ──
    final paint4 = Paint()
      ..color = AppColors.surfaceContainerHigh.withValues(alpha: 0.32);

    final path4 = Path();
    path4.moveTo(0, 0);
    path4.lineTo(0, size.height * 0.20);
    path4.cubicTo(
      size.width * 0.1,
      size.height * 0.24,
      size.width * 0.25,
      size.height * 0.13,
      size.width * 0.37,
      size.height * 0.08,
    );
    path4.cubicTo(
      size.width * 0.44,
      size.height * 0.05,
      size.width * 0.32,
      0,
      size.width * 0.37,
      0,
    );
    path4.close();
    canvas.drawPath(path4, paint4);

    // ── Blob 5: Center-right — Blue-to-cyan accent blob ──
    final paint5 = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.primaryContainer.withValues(alpha: 0.07),
              AppColors.secondary.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.78, size.height * 0.45),
              width: 340,
              height: 340,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.45),
      170,
      paint5,
    );

    // ── Blob 6: Bottom-left — Cyan accent blob ──
    final paint6 = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.secondary.withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.15, size.height * 0.75),
              width: 280,
              height: 280,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      140,
      paint6,
    );

    // ── Blob 7: Top-center — Primary radial glow ──
    final paint7 = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.primaryContainer.withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.50, size.height * 0.12),
              width: 320,
              height: 320,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.12),
      160,
      paint7,
    );

    // ── Blob 8: Bottom-right — Secondary warm glow ──
    final paint8 = Paint()
      ..shader =
          RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.secondaryContainer.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.82, size.height * 0.78),
              width: 260,
              height: 260,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.78),
      130,
      paint8,
    );

    // ── Painted arc accent — mid-right decorative curve ──
    final arcPaint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.88, size.height * 0.58),
        width: 80,
        height: 80,
      ),
      -math.pi / 3,
      math.pi * 0.8,
      false,
      arcPaint,
    );

    // ── Painted diamond — lower-center decorative shape ──
    final diamondPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final diamondPath = Path();
    final cx = size.width * 0.62;
    final cy = size.height * 0.88;
    const dSize = 14.0;
    diamondPath.moveTo(cx, cy - dSize);
    diamondPath.lineTo(cx + dSize, cy);
    diamondPath.lineTo(cx, cy + dSize);
    diamondPath.lineTo(cx - dSize, cy);
    diamondPath.close();
    canvas.drawPath(diamondPath, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating dot cluster accent
class _DotCluster extends StatelessWidget {
  final int count;
  final Color color;

  const _DotCluster({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.only(right: 10),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15 + (index * 0.04)),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Cross/plus accent painter
class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Semi-circle arc accent painter
class _ArcPainter extends CustomPainter {
  final Color color;
  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -math.pi / 4,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
