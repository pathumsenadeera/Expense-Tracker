import 'dart:math' as math;
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:flutter/material.dart';

// ── Google Multi-Color Logo ──────────────────────────────────────────────────
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;
    final double strokeWidth = w * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2);

    // Red arc (top left to top right: ~190° to ~300°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -math.pi * 0.78, math.pi * 0.56, false, paint);

    // Yellow arc (left side: ~120° to ~190°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 0.62, math.pi * 0.6, false, paint);

    // Green arc (bottom to bottom-right: ~30° to ~120°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.05, math.pi * 0.57, false, paint);

    // Blue arc (right side and crossbar: ~-40° to ~30°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi * 0.22, math.pi * 0.27, false, paint);

    // Blue horizontal bar in middle of 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - strokeWidth * 0.2, cy - strokeWidth / 2, r - strokeWidth * 0.3, strokeWidth),
      Radius.circular(strokeWidth * 0.2),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Facebook Logo ────────────────────────────────────────────────────────────
class FacebookLogo extends StatelessWidget {
  final double size;
  const FacebookLogo({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.72,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

// ── Apple Logo ───────────────────────────────────────────────────────────────
class AppleLogo extends StatelessWidget {
  final double size;
  final Color? color;
  const AppleLogo({super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.apple,
      size: size,
      color: color ?? (isDark ? Colors.white : Colors.black),
    );
  }
}

// ── Finora Illustrated Avatar ────────────────────────────────────────────────
// Beautiful vector illustrated character matching the reference image:
// - Left screen: waving character with blue shirt
// - Right screen: portrait with blue "+" badge at top right
class FinoraAvatar extends StatelessWidget {
  final double size;
  final bool isWaving;
  final bool showAddBadge;
  final VoidCallback? onAddTap;

  const FinoraAvatar({
    super.key,
    this.size = 120,
    this.isWaving = true,
    this.showAddBadge = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Circular container with illustration
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1E2430) : const Color(0xFFEFF3F8),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3344) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: CustomPaint(
                size: Size(size, size),
                painter: _FinoraAvatarPainter(
                  isWaving: isWaving,
                  shirtColor: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),

          // Optional top-right "+" badge (as in the Create Account screen)
          if (showAddBadge)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.black : Colors.white,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: size * 0.17,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinoraAvatarPainter extends CustomPainter {
  final bool isWaving;
  final Color shirtColor;

  _FinoraAvatarPainter({
    required this.isWaving,
    required this.shirtColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    const skinColor = Color(0xFFF7C8A4);
    const skinShadow = Color(0xFFEAB18C);
    const hairColor = Color(0xFF221F2D);
    const blushColor = Color(0x33FF6B6B);

    final skinPaint = Paint()..color = skinColor;
    final hairPaint = Paint()..color = hairColor;
    final shirtPaint = Paint()..color = shirtColor;

    // ── Body / Torso (Blue Shirt) ──────────────────────────────────────────
    final shirtPath = Path();
    shirtPath.moveTo(cx - w * 0.4, h);
    shirtPath.quadraticBezierTo(cx - w * 0.38, h * 0.72, cx - w * 0.15, h * 0.68);
    // Neck cutout
    shirtPath.quadraticBezierTo(cx, h * 0.76, cx + w * 0.15, h * 0.68);
    shirtPath.quadraticBezierTo(cx + w * 0.38, h * 0.72, cx + w * 0.4, h);
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Collar shadow
    final collarShadow = Paint()..color = const Color(0x22000000);
    final collarPath = Path();
    collarPath.moveTo(cx - w * 0.15, h * 0.68);
    collarPath.quadraticBezierTo(cx, h * 0.76, cx + w * 0.15, h * 0.68);
    collarPath.quadraticBezierTo(cx, h * 0.72, cx - w * 0.15, h * 0.68);
    canvas.drawPath(collarPath, collarShadow);

    // ── Waving Arm (if isWaving is true) ─────────────────────────────────────
    if (isWaving) {
      // Left arm raised waving (on left of character's view)
      final armPath = Path();
      armPath.moveTo(cx - w * 0.28, h * 0.73);
      armPath.quadraticBezierTo(cx - w * 0.36, h * 0.58, cx - w * 0.35, h * 0.42);
      armPath.lineTo(cx - w * 0.26, h * 0.43);
      armPath.quadraticBezierTo(cx - w * 0.25, h * 0.58, cx - w * 0.2, h * 0.71);
      armPath.close();
      canvas.drawPath(armPath, skinPaint);

      // Waving hand
      final handRect = Rect.fromCenter(
        center: Offset(cx - w * 0.32, h * 0.37),
        width: w * 0.14,
        height: w * 0.16,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(handRect, Radius.circular(w * 0.07)), skinPaint);

      // Small fingers detail
      final thumbPaint = Paint()..color = skinColor;
      canvas.drawCircle(Offset(cx - w * 0.25, h * 0.38), w * 0.04, thumbPaint);
    }

    // ── Neck ─────────────────────────────────────────────────────────────────
    final neckRect = Rect.fromCenter(
      center: Offset(cx, h * 0.61),
      width: w * 0.18,
      height: h * 0.18,
    );
    canvas.drawRect(neckRect, skinPaint);

    // Neck shadow under chin
    final neckShadowPaint = Paint()..color = skinShadow;
    final neckShadowPath = Path();
    neckShadowPath.moveTo(cx - w * 0.09, h * 0.56);
    neckShadowPath.quadraticBezierTo(cx, h * 0.63, cx + w * 0.09, h * 0.56);
    neckShadowPath.lineTo(cx + w * 0.09, h * 0.59);
    neckShadowPath.quadraticBezierTo(cx, h * 0.66, cx - w * 0.09, h * 0.59);
    neckShadowPath.close();
    canvas.drawPath(neckShadowPath, neckShadowPaint);

    // ── Ears ─────────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx - w * 0.19, h * 0.48), w * 0.05, skinPaint);
    canvas.drawCircle(Offset(cx + w * 0.19, h * 0.48), w * 0.05, skinPaint);

    // ── Head / Face ──────────────────────────────────────────────────────────
    final headRect = Rect.fromCenter(
      center: Offset(cx, h * 0.46),
      width: w * 0.36,
      height: h * 0.42,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.18)), skinPaint);

    // Cheeks / blush
    final blushPaint = Paint()..color = blushColor;
    canvas.drawCircle(Offset(cx - w * 0.11, h * 0.51), w * 0.04, blushPaint);
    canvas.drawCircle(Offset(cx + w * 0.11, h * 0.51), w * 0.04, blushPaint);

    // ── Eyes & Eyebrows (Minimalist modern style) ─────────────────────────────
    final featurePaint = Paint()
      ..color = const Color(0xFF2C2738)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Eyebrows
    canvas.drawLine(Offset(cx - w * 0.12, h * 0.41), Offset(cx - w * 0.04, h * 0.42), featurePaint);
    canvas.drawLine(Offset(cx + w * 0.04, h * 0.42), Offset(cx + w * 0.12, h * 0.41), featurePaint);

    // Eyes (friendly dots or relaxed curves)
    final eyePaint = Paint()..color = const Color(0xFF221F2D);
    canvas.drawCircle(Offset(cx - w * 0.08, h * 0.46), w * 0.025, eyePaint);
    canvas.drawCircle(Offset(cx + w * 0.08, h * 0.46), w * 0.025, eyePaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF332B3E)
      ..strokeWidth = w * 0.022
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smileRect = Rect.fromCenter(
      center: Offset(cx, h * 0.52),
      width: w * 0.11,
      height: h * 0.06,
    );
    canvas.drawArc(smileRect, 0.2, math.pi - 0.4, false, smilePaint);

    // ── Modern Hair Style ────────────────────────────────────────────────────
    final hairPath = Path();
    hairPath.moveTo(cx - w * 0.21, h * 0.45);
    hairPath.quadraticBezierTo(cx - w * 0.22, h * 0.28, cx - w * 0.12, h * 0.22);
    hairPath.quadraticBezierTo(cx, h * 0.18, cx + w * 0.15, h * 0.23);
    hairPath.quadraticBezierTo(cx + w * 0.22, h * 0.3, cx + w * 0.21, h * 0.46);
    // Hair fringe / bangs across forehead
    hairPath.quadraticBezierTo(cx + w * 0.12, h * 0.36, cx + w * 0.02, h * 0.38);
    hairPath.quadraticBezierTo(cx - w * 0.08, h * 0.35, cx - w * 0.17, h * 0.42);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Hair texture strand
    final strandPaint = Paint()
      ..color = const Color(0xFF3D374D)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - w * 0.08, h * 0.24), Offset(cx + w * 0.06, h * 0.25), strandPaint);
  }

  @override
  bool shouldRepaint(covariant _FinoraAvatarPainter oldDelegate) {
    return oldDelegate.isWaving != isWaving || oldDelegate.shirtColor != shirtColor;
  }
}
