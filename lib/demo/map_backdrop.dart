import 'package:flutter/material.dart';

/// A lightweight painted map used as the demo backdrop.
///
/// It deliberately uses no network, tiles, permissions or map SDK: the sheet
/// is the focus of this project.
class MapBackdrop extends StatelessWidget {
  const MapBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MapPainter(),
        isComplex: true,
        willChange: false,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  static const Color _base = Color(0xFFF0EEE8);
  static const Color _block = Color(0xFFE6E2D8);
  static const Color _blockAlt = Color(0xFFEAE6DD);
  static const Color _park = Color(0xFFD9E5CF);
  static const Color _water = Color(0xFFC7DDE8);
  static const Color _roadEdge = Color(0xFFDCD8CE);
  static const Color _road = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = _base);

    _paintWater(canvas, w, h);
    _paintParks(canvas, w, h);
    _paintBlocks(canvas, w, h);
    _paintRoads(canvas, w, h);
    _paintDetails(canvas, w, h);
  }

  void _paintWater(Canvas canvas, double w, double h) {
    final Path river = Path()
      ..moveTo(w * 0.58, -h * 0.05)
      ..cubicTo(w * 0.76, h * 0.08, w * 0.60, h * 0.24, w * 0.72, h * 0.39)
      ..cubicTo(w * 0.84, h * 0.53, w * 1.02, h * 0.60, w * 1.08, h * 0.72)
      ..lineTo(w * 1.08, h * 0.86)
      ..cubicTo(w * 0.90, h * 0.76, w * 0.70, h * 0.66, w * 0.58, h * 0.49)
      ..cubicTo(w * 0.48, h * 0.32, w * 0.70, h * 0.14, w * 0.48, -h * 0.05)
      ..close();
    canvas.drawPath(river, Paint()..color = _water);

    final Path bank = Path()
      ..moveTo(w * 0.58, -h * 0.05)
      ..cubicTo(w * 0.76, h * 0.08, w * 0.60, h * 0.24, w * 0.72, h * 0.39)
      ..cubicTo(w * 0.84, h * 0.53, w * 1.02, h * 0.60, w * 1.08, h * 0.72);
    canvas.drawPath(
      bank,
      Paint()
        ..color = const Color(0xFFB8D2DF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _paintParks(Canvas canvas, double w, double h) {
    final Paint parkPaint = Paint()..color = _park;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.13, w * 0.28, h * 0.19),
        const Radius.circular(18),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.75, h * 0.46, w * 0.22, h * 0.14),
        const Radius.circular(18),
      ),
      parkPaint,
    );

    final Paint pathPaint = Paint()
      ..color = const Color(0xFFF8F6EF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final Path walkingPath = Path()
      ..moveTo(w * 0.08, h * 0.26)
      ..cubicTo(w * 0.16, h * 0.18, w * 0.24, h * 0.30, w * 0.30, h * 0.20);
    canvas.drawPath(walkingPath, pathPaint);
  }

  void _paintBlocks(Canvas canvas, double w, double h) {
    const List<Rect> blocks = <Rect>[
      Rect.fromLTWH(0.055, 0.38, 0.14, 0.10),
      Rect.fromLTWH(0.22, 0.41, 0.12, 0.11),
      Rect.fromLTWH(0.39, 0.08, 0.14, 0.13),
      Rect.fromLTWH(0.39, 0.26, 0.10, 0.09),
      Rect.fromLTWH(0.54, 0.10, 0.12, 0.10),
      Rect.fromLTWH(0.55, 0.27, 0.13, 0.09),
      Rect.fromLTWH(0.07, 0.58, 0.13, 0.12),
      Rect.fromLTWH(0.24, 0.60, 0.16, 0.09),
      Rect.fromLTWH(0.43, 0.58, 0.10, 0.13),
      Rect.fromLTWH(0.58, 0.62, 0.14, 0.10),
      Rect.fromLTWH(0.78, 0.22, 0.12, 0.10),
      Rect.fromLTWH(0.06, 0.77, 0.18, 0.10),
      Rect.fromLTWH(0.29, 0.76, 0.12, 0.11),
      Rect.fromLTWH(0.48, 0.77, 0.15, 0.10),
      Rect.fromLTWH(0.70, 0.78, 0.13, 0.09),
    ];
    for (int i = 0; i < blocks.length; i++) {
      final Rect r = blocks[i];
      final Rect rect = Rect.fromLTWH(
        w * r.left,
        h * r.top,
        w * r.width,
        h * r.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        Paint()..color = i.isEven ? _block : _blockAlt,
      );
    }
  }

  void _paintRoads(Canvas canvas, double w, double h) {
    void road(Offset from, Offset to, double width) {
      canvas.drawLine(
        Offset(w * from.dx, h * from.dy),
        Offset(w * to.dx, h * to.dy),
        Paint()
          ..color = _roadEdge
          ..strokeWidth = width + 3
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(w * from.dx, h * from.dy),
        Offset(w * to.dx, h * to.dy),
        Paint()
          ..color = _road
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    // Main avenues.
    road(const Offset(-0.05, 0.33), const Offset(1.05, 0.28), 15);
    road(const Offset(0.33, -0.05), const Offset(0.36, 1.05), 14);
    road(const Offset(-0.05, 0.56), const Offset(1.05, 0.63), 12);
    road(const Offset(0.70, -0.05), const Offset(0.66, 1.05), 11);

    // Smaller streets.
    road(const Offset(-0.05, 0.17), const Offset(1.05, 0.13), 6);
    road(const Offset(-0.05, 0.47), const Offset(1.05, 0.50), 5);
    road(const Offset(-0.05, 0.72), const Offset(1.05, 0.76), 6);
    road(const Offset(-0.05, 0.88), const Offset(1.05, 0.90), 5);
    road(const Offset(0.14, -0.05), const Offset(0.17, 1.05), 5);
    road(const Offset(0.50, -0.05), const Offset(0.47, 1.05), 5);
    road(const Offset(0.83, -0.05), const Offset(0.86, 1.05), 5);

    // Diagonal boulevard.
    road(const Offset(-0.05, 0.66), const Offset(0.62, -0.05), 7);
  }

  void _paintDetails(Canvas canvas, double w, double h) {
    final Paint tree = Paint()..color = const Color(0xFFB9CFA9);
    for (final Offset p in const <Offset>[
      Offset(0.08, 0.17),
      Offset(0.12, 0.22),
      Offset(0.24, 0.19),
      Offset(0.27, 0.27),
      Offset(0.09, 0.28),
    ]) {
      canvas.drawCircle(Offset(w * p.dx, h * p.dy), 3.2, tree);
    }

    final Paint sand = Paint()..color = const Color(0xFFEADBB9);
    canvas.drawCircle(Offset(w * 0.88, h * 0.53), w * 0.035, sand);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
