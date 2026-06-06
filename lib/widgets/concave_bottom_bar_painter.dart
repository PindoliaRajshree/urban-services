import 'package:flutter/material.dart';

class ConcaveBottomBarPainter extends CustomPainter {
  final LinearGradient gradient;

  ConcaveBottomBarPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    Path path = Path();
    double radius = 14.0;
    double notchWidth = 80.0;
    double center = size.width / 2;

    // Start bottom left
    path.moveTo(0, size.height);

    // Line to top left before radius
    path.lineTo(0, radius);

    // Top left radius
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Line to notch start (sharp corner)
    path.lineTo(center - notchWidth / 2, 0);

    // Semi-circular Notch (dip down)
    // We use arcToPoint with clockwise: false for a concave semi-circle
    path.arcToPoint(
      Offset(center + notchWidth / 2, 0),
      radius: Radius.circular(notchWidth / 2),
      clockwise: false,
    );

    // Line to top right before radius
    path.lineTo(size.width - radius, 0);

    // Top right radius
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    // Line to bottom right
    path.lineTo(size.width, size.height);

    // Close path
    path.close();

    // Draw Shadow
    Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.52 / 2);

    canvas.save();
    canvas.translate(0, 4.94);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
