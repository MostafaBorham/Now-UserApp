import 'package:flutter/material.dart';

class BottomNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String? label;

  const BottomNavItemData({
    required this.icon,
    required this.activeIcon,
    this.label,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavItemData> items;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onCenterTap;

  final double barHeight;
  final double bumpHeight;
  final double centerButtonSize;
  final double horizontalMargin;
  final double horizontalPadding;
  final double bottomPadding;
  final double centerGap;
  final double centerButtonTopSpacing;

  final Color backgroundColor;
  final Color borderColor;
  final Color selectedColor;
  final Color unselectedColor;

  final Color centerButtonColor;
  final Color centerIconColor;
  final Widget? centerButtonChild;

  final bool showLabels;
  final BoxShadow? shadow;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
    this.onCenterTap,
    this.barHeight = 82,
    this.bumpHeight = 26,
    this.centerButtonSize = 58,
    this.horizontalMargin = 16,
    this.horizontalPadding = 18,
    this.bottomPadding = 10,
    this.centerGap = 18,
    this.centerButtonTopSpacing = 8,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0x14000000),
    this.selectedColor = Colors.black,
    this.unselectedColor = const Color(0xFF8E8E93),
    this.centerButtonColor = Colors.black,
    this.centerIconColor = Colors.white,
    this.centerButtonChild,
    this.showLabels = true,
    this.shadow,
  }) : assert(
  items.length == 4,
  'CustomBottomNavBar currently expects exactly 4 items.',
  );

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = shadow ??
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 14,
          offset: const Offset(0, 8),
        );

    return SafeArea(
      top: false,
      child: SizedBox(
        height: barHeight + bumpHeight + centerButtonTopSpacing + 20,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: horizontalMargin,
              right: horizontalMargin,
              bottom: 0,
              child: SizedBox(
                height: barHeight + bumpHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    CustomPaint(
                      painter: BottomNavPainter(
                        color: backgroundColor,
                        borderColor: borderColor,
                        bumpHeight: bumpHeight,
                        shadow: effectiveShadow,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: barHeight + bumpHeight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: bumpHeight + 8,
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: bottomPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    _NavBarItem(
                                      data: items[0],
                                      isSelected: selectedIndex == 0,
                                      selectedColor: selectedColor,
                                      unselectedColor: unselectedColor,
                                      showLabel: showLabels,
                                      onTap: () => onItemSelected(0),
                                    ),
                                    _NavBarItem(
                                      data: items[1],
                                      isSelected: selectedIndex == 1,
                                      selectedColor: selectedColor,
                                      unselectedColor: unselectedColor,
                                      showLabel: showLabels,
                                      onTap: () => onItemSelected(1),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: centerButtonSize + centerGap),

                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    _NavBarItem(
                                      data: items[2],
                                      isSelected: selectedIndex == 2,
                                      selectedColor: selectedColor,
                                      unselectedColor: unselectedColor,
                                      showLabel: showLabels,
                                      onTap: () => onItemSelected(2),
                                    ),
                                    _NavBarItem(
                                      data: items[3],
                                      isSelected: selectedIndex == 3,
                                      selectedColor: selectedColor,
                                      unselectedColor: unselectedColor,
                                      showLabel: showLabels,
                                      onTap: () => onItemSelected(3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /*Positioned(
                      top: -centerButtonTopSpacing,
                      child: GestureDetector(
                        onTap: onCenterTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: centerButtonSize,
                          height: centerButtonSize,
                          decoration: BoxDecoration(
                            color: centerButtonColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: centerButtonChild ??
                              Icon(
                                Icons.add,
                                color: centerIconColor,
                                size: 28,
                              ),
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final BottomNavItemData data;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;

  const _NavBarItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? data.activeIcon : data.icon,
              color: color,
              size: 24,
            ),
            if (showLabel && (data.label?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 4),
              Text(
                data.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double bumpHeight;
  final BoxShadow shadow;

  BottomNavPainter({
    required this.color,
    required this.borderColor,
    required this.bumpHeight,
    required this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    canvas.drawShadow(
      path,
      shadow.color,
      shadow.blurRadius * 0.6,
      false,
    );

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, strokePaint);
  }

  Path _buildPath(Size size) {
    final path = Path();

    final double w = size.width;
    final double h = size.height;

    final double topY = bumpHeight;
    final double bottomY = h;

    // =========================
    // outer corners
    // =========================
    const double topCornerRadius = 10;
    const double bottomCornerRadius = 34;

    // =========================================================
    // center bump
    // =========================================================

    /// قطر نصف الدائرة الحقيقي في المنتصف
    const double domeDiameter = 58;

    /// عرض منطقة الدمج بين الخط ونصف الدائرة
    const double blendWidth = 16;

    /// مقدار النزول للداخل عند بداية الدمج
    /// هذا هو الذي سيجعل الوصلة inward بدل outward
    const double inwardDepth = 7;

    final double centerX = w / 2;
    final double radius = domeDiameter / 2;

    final double domeStartX = centerX - radius;
    final double domeEndX = centerX + radius;

    /// أعلى نقطة في نصف الدائرة
    final double domeTopY = topY - radius;

    /// بداية ونهاية مناطق الدمج
    final double rightBlendStartX = domeEndX + blendWidth;
    final double leftBlendEndX = domeStartX - blendWidth;

    path.moveTo(topCornerRadius, topY);

    // top-left corner
    path.quadraticBezierTo(0, topY, 0, topY + topCornerRadius);

    // left side
    path.lineTo(0, bottomY - bottomCornerRadius);

    // bottom-left
    path.quadraticBezierTo(
      0,
      bottomY,
      bottomCornerRadius,
      bottomY,
    );

    // bottom edge
    path.lineTo(w - bottomCornerRadius, bottomY);

    // bottom-right
    path.quadraticBezierTo(
      w,
      bottomY,
      w,
      bottomY - bottomCornerRadius,
    );

    // right side
    path.lineTo(w, topY + topCornerRadius);

    // top-right corner
    path.quadraticBezierTo(
      w,
      topY,
      w - topCornerRadius,
      topY,
    );

    // =========================================================
    // top line until right blend
    // =========================================================
    path.lineTo(rightBlendStartX, topY);
    // =========================
    // right inward blend
    // من الخط المستقيم إلى بداية القبة
    // =========================
// right inward blend - inward
    path.cubicTo(
      rightBlendStartX - blendWidth * 0.20, topY - inwardDepth * 0.9,
      domeEndX + blendWidth * 0.45, topY - inwardDepth,
      domeEndX, topY - inwardDepth,
    );

    // =========================
    // main dome (right -> center -> left)
    // قوس علوي قريب من الشكل في الصورة
    // =========================
    path.cubicTo(
      domeEndX - radius * 0.30, topY - inwardDepth,
      centerX + radius * 0.55, domeTopY,
      centerX, domeTopY,
    );

    path.cubicTo(
      centerX - radius * 0.55, domeTopY,
      domeStartX + radius * 0.30, topY - inwardDepth,
      domeStartX, topY - inwardDepth,
    );

    // =========================
    // left inward blend
    // من نهاية القبة إلى الخط المستقيم
    // =========================
    path.cubicTo(
      domeStartX - blendWidth * 0.35, topY - inwardDepth,
      leftBlendEndX + blendWidth * 0.25, topY,
      leftBlendEndX, topY,
    );
    path.lineTo(topCornerRadius, topY);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant BottomNavPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.bumpHeight != bumpHeight ||
        oldDelegate.shadow != shadow;
  }
}