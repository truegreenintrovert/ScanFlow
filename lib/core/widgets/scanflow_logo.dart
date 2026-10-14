import 'package:flutter/material.dart';

/// ScanFlow's shared page-and-scan mark.
class ScanFlowLogo extends StatelessWidget {
  const ScanFlowLogo({super.key, this.size = 42, this.onDark = false});
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final useLightMark =
        onDark || Theme.of(context).brightness == Brightness.dark;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ScanFlowMarkPainter(useLightMark)),
    );
  }
}

class _ScanFlowMarkPainter extends CustomPainter {
  const _ScanFlowMarkPainter(this.onDark);

  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 36 * .84;
    canvas.translate(size.width * .08, size.height * .08);
    canvas.scale(scale);
    final page = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff119a88), Color(0xff08756f)],
      ).createShader(const Rect.fromLTWH(8, 3, 22, 31));
    final fold = Paint()
      ..color = onDark ? const Color(0xffc8fff0) : const Color(0xff8af0d7);
    final ink = Paint()
      ..color = const Color(0xfff1fffb)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final scanLine = Paint()
      ..color = const Color(0xff8af0d7)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = onDark ? const Color(0xff75f2d7) : const Color(0xff075b58)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final document = Path()
      ..moveTo(13, 4)
      ..lineTo(22, 4)
      ..lineTo(29, 11)
      ..lineTo(29, 29)
      ..quadraticBezierTo(29, 32, 26, 32)
      ..lineTo(12, 32)
      ..quadraticBezierTo(9, 32, 9, 29)
      ..lineTo(9, 7)
      ..quadraticBezierTo(9, 4, 12, 4)
      ..close();
    canvas.drawPath(document, page);
    final foldedCorner = Path()
      ..moveTo(22, 4)
      ..lineTo(22, 10)
      ..quadraticBezierTo(22, 11, 23, 11)
      ..lineTo(29, 11)
      ..close();
    canvas.drawPath(foldedCorner, fold);
    // A bright scan pass and four focus corners give the mark its identity.
    canvas.drawLine(const Offset(13, 16), const Offset(25, 16), scanLine);
    canvas.drawLine(const Offset(13, 21), const Offset(25, 21), ink);
    canvas.drawLine(const Offset(13, 26), const Offset(20, 26), ink);
    canvas.drawLine(const Offset(4, 11), const Offset(4, 8), accent);
    canvas.drawLine(const Offset(4, 8), const Offset(8, 8), accent);
    canvas.drawLine(const Offset(28, 8), const Offset(32, 8), accent);
    canvas.drawLine(const Offset(32, 8), const Offset(32, 11), accent);
    canvas.drawLine(const Offset(4, 25), const Offset(4, 28), accent);
    canvas.drawLine(const Offset(4, 28), const Offset(8, 28), accent);
    canvas.drawLine(const Offset(28, 28), const Offset(32, 28), accent);
    canvas.drawLine(const Offset(32, 25), const Offset(32, 28), accent);
  }

  @override
  bool shouldRepaint(covariant _ScanFlowMarkPainter oldDelegate) =>
      oldDelegate.onDark != onDark;
}
