import 'package:flutter/material.dart';

import '../core/brand.dart';

/// Original Orvex mark: a rounded square holding an abstract "O" ring with an
/// offset node. Drawn in code, so it needs no image asset.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _MarkPainter()),
  );
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & s,
      Radius.circular(s.width * 0.28),
    );
    canvas.drawRRect(r, Paint()..color = Brand.primary);

    final c = Offset(s.width / 2, s.height / 2);
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: s.width * 0.26),
      0.55,
      5.2,
      false,
      ring,
    );
    canvas.drawCircle(
      Offset(c.dx + s.width * 0.21, c.dy - s.width * 0.21),
      s.width * 0.065,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.size = 40, this.showName = true});
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: size),
        if (showName) ...[
          SizedBox(width: size * 0.3),
          Flexible(
            child: Text(
              'Orvex Ai',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
