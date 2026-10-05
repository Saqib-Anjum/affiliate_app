import "package:flutter/material.dart";

/// Renders the official AiDx company logo (Robot Mascot + stylized AiDx text with yellow accents).
/// Adapts gracefully to both dark and light headers/themes.
class AiDxLogo extends StatelessWidget {
  const AiDxLogo({
    super.key,
    this.height = 36,
    this.showText = true,
    this.darkBackground,
  });

  final double height;
  final bool showText;
  final bool? darkBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = darkBackground ?? (Theme.of(context).brightness == Brightness.dark);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Robot Mascot Icon
        SizedBox(
          width: height * 1.1,
          height: height,
          child: CustomPaint(
            painter: _RobotMascotPainter(isDark: isDark),
          ),
        ),
        if (showText) ...[
          SizedBox(width: height * 0.2),
          // Stylized "AiDx" Brand Text
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "A",
                style: TextStyle(
                  fontSize: height * 0.72,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                  fontFamily: "Roboto",
                ),
              ),
              // 'i' with custom yellow dot above
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Text(
                    "i",
                    style: TextStyle(
                      fontSize: height * 0.72,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      fontFamily: "Roboto",
                    ),
                  ),
                  Positioned(
                    top: -height * 0.08,
                    child: Container(
                      width: height * 0.22,
                      height: height * 0.22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE600), // AiDx signature yellow
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66FFE600),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                "D",
                style: TextStyle(
                  fontSize: height * 0.72,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                  fontFamily: "Roboto",
                ),
              ),
              Text(
                "X",
                style: TextStyle(
                  fontSize: height * 0.72,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: -0.5,
                  fontFamily: "Roboto",
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the AiDx robot mascot head & collar.
class _RobotMascotPainter extends CustomPainter {
  _RobotMascotPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Antenna stem & yellow dot
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFE600)
      ..style = PaintingStyle.fill;

    final stemPaint = Paint()
      ..color = isDark ? Colors.white70 : const Color(0xFF475569)
      ..strokeWidth = w * 0.06
      ..style = PaintingStyle.stroke;

    // Antenna line
    canvas.drawLine(Offset(w * 0.5, h * 0.25), Offset(w * 0.5, h * 0.1), stemPaint);
    // Yellow antenna dot
    canvas.drawCircle(Offset(w * 0.5, h * 0.08), w * 0.08, yellowPaint);

    // Robot Head Outline / Shell
    final headPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final headPath = Path();
    headPath.moveTo(w * 0.25, h * 0.25);
    headPath.quadraticBezierTo(w * 0.5, h * 0.18, w * 0.75, h * 0.25);
    headPath.quadraticBezierTo(w * 0.92, h * 0.45, w * 0.85, h * 0.62);
    headPath.quadraticBezierTo(w * 0.5, h * 0.78, w * 0.15, h * 0.62);
    headPath.quadraticBezierTo(w * 0.08, h * 0.45, w * 0.25, h * 0.25);
    headPath.close();
    canvas.drawPath(headPath, headPaint);

    // Eye visor cutout (black)
    final visorPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final visorPath = Path();
    visorPath.moveTo(w * 0.28, h * 0.35);
    visorPath.lineTo(w * 0.72, h * 0.35);
    visorPath.quadraticBezierTo(w * 0.75, h * 0.52, w * 0.68, h * 0.56);
    visorPath.lineTo(w * 0.32, h * 0.56);
    visorPath.quadraticBezierTo(w * 0.25, h * 0.52, w * 0.28, h * 0.35);
    visorPath.close();
    canvas.drawPath(visorPath, visorPaint);

    // Glowing Yellow Robot Eyes
    canvas.drawCircle(Offset(w * 0.38, h * 0.44), w * 0.07, yellowPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.44), w * 0.07, yellowPaint);

    // Body / Collar & Yellow Tie
    final bodyPaint = Paint()
      ..color = isDark ? Colors.white70 : const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.25, h * 0.72);
    bodyPath.lineTo(w * 0.75, h * 0.72);
    bodyPath.lineTo(w * 0.65, h * 0.95);
    bodyPath.lineTo(w * 0.35, h * 0.95);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Yellow Tie
    final tiePath = Path();
    tiePath.moveTo(w * 0.45, h * 0.74);
    tiePath.lineTo(w * 0.55, h * 0.74);
    tiePath.lineTo(w * 0.53, h * 0.88);
    tiePath.lineTo(w * 0.5, h * 0.95);
    tiePath.lineTo(w * 0.47, h * 0.88);
    tiePath.close();
    canvas.drawPath(tiePath, yellowPaint);
  }

  @override
  bool shouldRepaint(covariant _RobotMascotPainter oldDelegate) => oldDelegate.isDark != isDark;
}
