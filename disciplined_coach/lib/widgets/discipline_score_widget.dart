import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class DisciplineScoreWidget extends StatelessWidget {
  final int score;
  const DisciplineScoreWidget({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: DisciplineScorePainter(score: score),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Disiplin Puanı',
                style: GoogleFonts.robotoMono(
                  textStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GradientText(
                score.toString(),
                style: GoogleFonts.robotoMono(
                  textStyle: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                colors: const [
                  Color(0xFFF92B7B),
                  Color(0xFFF58529),
                ],
              ),
               Text(
                'Robott Mono', // As per the image
                 style: GoogleFonts.robotoMono(
                  textStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisciplineScorePainter extends CustomPainter {
  final int score;
  DisciplineScorePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20;
    const strokeWidth = 8.0;

    // Background circle paint
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Foreground (score) arc paint
    final foregroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF92B7B), Color(0xFFF58529)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Neon glow paint
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF92B7B), Color(0xFFF58529)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4 // a bit wider for the glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);


    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the glow first, so it's behind the main arc
    final double scoreAngle = 2 * pi * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      scoreAngle,
      false,
      glowPaint,
    );

    // Draw the foreground arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      scoreAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever score changes
  }
}
