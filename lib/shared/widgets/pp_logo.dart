import 'package:flutter/material.dart';

/// Power Pulse lightning-bolt logo mark.
/// Renders at [size]×[size] using a CustomPainter — no external assets needed.
class PPLogo extends StatelessWidget {
  const PPLogo({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;

    const accent = Color(0xFFA8E063);

    // Outer glow ring
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = accent.withOpacity(0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy), r - 1,
      Paint()
        ..color = accent.withOpacity(0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Lightning bolt — sharp, centred
    final w = size.width;
    final h = size.height;
    final bolt = Path()
      ..moveTo(w * 0.58, h * 0.14)
      ..lineTo(w * 0.31, h * 0.53)
      ..lineTo(w * 0.50, h * 0.53)
      ..lineTo(w * 0.42, h * 0.86)
      ..lineTo(w * 0.69, h * 0.47)
      ..lineTo(w * 0.50, h * 0.47)
      ..close();

    // Soft glow behind bolt
    canvas.drawPath(bolt,
      Paint()
        ..color = accent.withOpacity(0.20)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Solid bolt
    canvas.drawPath(bolt,
      Paint()..color = accent..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
