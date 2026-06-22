import 'package:flutter/material.dart';

class BottomNavBarClipper extends CustomClipper<Path> {
  final double topBumpHeight;

  BottomNavBarClipper({
    required this.topBumpHeight,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // ===== اضبط هذه القيم لو أردت مطابقة أدق =====
    const double bottomCornerRadius = 22;
    const double topCornerRadius = 18;

    // عرض البروز العلوي
    const double bumpWidth = 86;

    // نصف عرض المنطقة الدائرية في المنتصف
    final double centerX = size.width / 2;
    final double bumpStartX = centerX - (bumpWidth / 2);
    final double bumpEndX = centerX + (bumpWidth / 2);

    // بداية المسار من أعلى اليسار
    path.moveTo(topCornerRadius, 0);

    // الركن العلوي الأيسر
    path.quadraticBezierTo(0, 0, 0, topCornerRadius);

    // النزول إلى أسفل اليسار
    path.lineTo(0, size.height - bottomCornerRadius);

    // الركن السفلي الأيسر
    path.quadraticBezierTo(
      0,
      size.height,
      bottomCornerRadius,
      size.height,
    );

    // الخط السفلي
    path.lineTo(size.width - bottomCornerRadius, size.height);

    // الركن السفلي الأيمن
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - bottomCornerRadius,
    );

    // الصعود إلى أعلى اليمين
    path.lineTo(size.width, topCornerRadius);

    // الركن العلوي الأيمن
    path.quadraticBezierTo(
      size.width,
      0,
      size.width - topCornerRadius,
      0,
    );

    // نتحرك على الحافة العلوية حتى بداية البروز
    path.lineTo(bumpEndX, 0);

    // ===== البروز العلوي الحقيقي (لأعلى) =====
    // من اليمين إلى قمة البروز
    path.quadraticBezierTo(
      centerX + 28,
      0,
      centerX + 24,
      -topBumpHeight * 0.55,
    );

    path.quadraticBezierTo(
      centerX + 18,
      -topBumpHeight,
      centerX,
      -topBumpHeight,
    );

    // من القمة إلى اليسار
    path.quadraticBezierTo(
      centerX - 18,
      -topBumpHeight,
      centerX - 24,
      -topBumpHeight * 0.55,
    );

    path.quadraticBezierTo(
      centerX - 28,
      0,
      bumpStartX,
      0,
    );

    // نكمل إلى أعلى اليسار
    path.lineTo(topCornerRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant BottomNavBarClipper oldClipper) {
    return oldClipper.topBumpHeight != topBumpHeight;
  }
}