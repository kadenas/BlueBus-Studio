import 'package:flutter/material.dart';

class BlueBusLogo extends StatelessWidget {
  const BlueBusLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color, width: 2),
      ),
      padding: EdgeInsets.all(size * 0.2),
      child: CustomPaint(
        painter: _BlueBusPainter(color: color),
      ),
    );
  }
}

class _BlueBusPainter extends CustomPainter {
  _BlueBusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18;

    final path = Path();
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw vertical spine of the stylized "B"
    path.moveTo(center.dx - radius * 0.45, size.height * 0.1);
    path.lineTo(center.dx - radius * 0.45, size.height * 0.9);

    canvas.drawPath(path, paint);

    // Draw two parallel arcs forming the B shape
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.18;

    final topRect = Rect.fromCenter(
      center: Offset(center.dx + radius * 0.05, size.height * 0.32),
      width: size.width * 0.9,
      height: size.height * 0.42,
    );

    final bottomRect = Rect.fromCenter(
      center: Offset(center.dx + radius * 0.05, size.height * 0.7),
      width: size.width * 0.9,
      height: size.height * 0.42,
    );

    canvas.drawArc(topRect, -1.6, 2.3, false, arcPaint);
    canvas.drawArc(bottomRect, -2.0, 2.7, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
