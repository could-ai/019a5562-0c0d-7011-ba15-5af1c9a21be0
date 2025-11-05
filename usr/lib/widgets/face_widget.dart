import 'package:flutter/material.dart';
import 'dart:math' as math;

enum FaceExpression {
  neutral,
  happy,
  sad,
  listening,
  thinking,
  confused,
}

class FaceWidget extends StatelessWidget {
  final FaceExpression expression;
  final AnimationController blinkAnimation;

  const FaceWidget({
    super.key,
    required this.expression,
    required this.blinkAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: FacePainter(
          expression: expression,
          blinkValue: blinkAnimation.value,
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final FaceExpression expression;
  final double blinkValue;

  FacePainter({
    required this.expression,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final center = Offset(size.width / 2, size.height / 2);
    final faceRadius = size.width / 2 - 20;

    // Desenhar contorno do rosto
    canvas.drawCircle(center, faceRadius, paint);

    // Desenhar olhos
    _drawEyes(canvas, center, faceRadius, fillPaint, paint);

    // Desenhar boca baseado na expressão
    _drawMouth(canvas, center, faceRadius, paint);

    // Desenhar elementos extras baseado na expressão
    _drawExpressionDetails(canvas, center, faceRadius, paint);
  }

  void _drawEyes(Canvas canvas, Offset center, double faceRadius, Paint fillPaint, Paint strokePaint) {
    final eyeY = center.dy - faceRadius * 0.2;
    final eyeDistance = faceRadius * 0.4;

    final leftEyeCenter = Offset(center.dx - eyeDistance, eyeY);
    final rightEyeCenter = Offset(center.dx + eyeDistance, eyeY);

    if (expression == FaceExpression.thinking) {
      // Olhos pensativos (meio fechados)
      _drawThinkingEye(canvas, leftEyeCenter, 15, strokePaint);
      _drawThinkingEye(canvas, rightEyeCenter, 15, strokePaint);
    } else if (blinkValue > 0.5) {
      // Piscando - linhas horizontais
      canvas.drawLine(
        Offset(leftEyeCenter.dx - 15, leftEyeCenter.dy),
        Offset(leftEyeCenter.dx + 15, leftEyeCenter.dy),
        strokePaint,
      );
      canvas.drawLine(
        Offset(rightEyeCenter.dx - 15, rightEyeCenter.dy),
        Offset(rightEyeCenter.dx + 15, rightEyeCenter.dy),
        strokePaint,
      );
    } else {
      // Olhos normais
      final eyeRadius = expression == FaceExpression.happy ? 8.0 : 10.0;
      canvas.drawCircle(leftEyeCenter, eyeRadius, fillPaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, fillPaint);

      // Adicionar brilho nos olhos
      final shinePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.grey.shade800;
      canvas.drawCircle(
        Offset(leftEyeCenter.dx - 3, leftEyeCenter.dy - 3),
        3,
        shinePaint,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx - 3, rightEyeCenter.dy - 3),
        3,
        shinePaint,
      );
    }
  }

  void _drawThinkingEye(Canvas canvas, Offset center, double width, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - width, center.dy - 5);
    path.quadraticBezierTo(
      center.dx,
      center.dy + 5,
      center.dx + width,
      center.dy - 5,
    );
    canvas.drawPath(path, paint);
  }

  void _drawMouth(Canvas canvas, Offset center, double faceRadius, Paint paint) {
    final mouthY = center.dy + faceRadius * 0.3;
    final mouthWidth = faceRadius * 0.6;

    final path = Path();

    switch (expression) {
      case FaceExpression.happy:
        // Sorriso
        path.moveTo(center.dx - mouthWidth / 2, mouthY);
        path.quadraticBezierTo(
          center.dx,
          mouthY + 30,
          center.dx + mouthWidth / 2,
          mouthY,
        );
        break;

      case FaceExpression.sad:
        // Triste
        path.moveTo(center.dx - mouthWidth / 2, mouthY + 20);
        path.quadraticBezierTo(
          center.dx,
          mouthY - 10,
          center.dx + mouthWidth / 2,
          mouthY + 20,
        );
        break;

      case FaceExpression.listening:
        // Boca em O
        canvas.drawCircle(
          Offset(center.dx, mouthY + 10),
          15,
          paint,
        );
        return;

      case FaceExpression.thinking:
        // Boca lateral pensativa
        path.moveTo(center.dx - mouthWidth / 3, mouthY);
        path.lineTo(center.dx + mouthWidth / 3, mouthY);
        break;

      case FaceExpression.confused:
        // Boca ondulada confusa
        path.moveTo(center.dx - mouthWidth / 2, mouthY);
        path.quadraticBezierTo(
          center.dx - mouthWidth / 4,
          mouthY + 10,
          center.dx,
          mouthY,
        );
        path.quadraticBezierTo(
          center.dx + mouthWidth / 4,
          mouthY - 10,
          center.dx + mouthWidth / 2,
          mouthY,
        );
        break;

      case FaceExpression.neutral:
      default:
        // Neutra
        path.moveTo(center.dx - mouthWidth / 2, mouthY);
        path.lineTo(center.dx + mouthWidth / 2, mouthY);
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _drawExpressionDetails(Canvas canvas, Offset center, double faceRadius, Paint paint) {
    switch (expression) {
      case FaceExpression.listening:
        // Ondas de som
        for (int i = 1; i <= 3; i++) {
          final waveRadius = faceRadius + (i * 15);
          final wavePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.blue.withOpacity(0.5 - (i * 0.1));
          canvas.drawCircle(center, waveRadius, wavePaint);
        }
        break;

      case FaceExpression.thinking:
        // Pontos de pensamento
        final thoughtPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white;
        
        canvas.drawCircle(
          Offset(center.dx + faceRadius * 0.8, center.dy - faceRadius * 0.5),
          5,
          thoughtPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + faceRadius * 1.0, center.dy - faceRadius * 0.7),
          8,
          thoughtPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + faceRadius * 1.1, center.dy - faceRadius * 0.95),
          12,
          thoughtPaint,
        );
        break;

      case FaceExpression.confused:
        // Ponto de interrogação
        final confusedPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.yellow;
        
        final questionPath = Path();
        final qX = center.dx + faceRadius * 0.8;
        final qY = center.dy - faceRadius * 0.6;
        
        questionPath.moveTo(qX - 8, qY - 10);
        questionPath.quadraticBezierTo(qX, qY - 20, qX + 8, qY - 10);
        questionPath.quadraticBezierTo(qX + 5, qY, qX, qY + 5);
        canvas.drawPath(questionPath, confusedPaint);
        
        canvas.drawCircle(
          Offset(qX, qY + 12),
          2,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.yellow,
        );
        break;

      default:
        break;
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.expression != expression ||
        oldDelegate.blinkValue != blinkValue;
  }
}
