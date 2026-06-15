import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, 20);

    path.quadraticBezierTo(
      size.width * .20,
      0,
      size.width * .35,
      0,
    );

    path.cubicTo(
      size.width * .42,
      0,
      size.width * .42,
      45,
      size.width * .50,
      45,
    );

    path.cubicTo(
      size.width * .58,
      45,
      size.width * .58,
      0,
      size.width * .65,
      0,
    );

    path.quadraticBezierTo(
      size.width * .80,
      0,
      size.width,
      20,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: .12),
      12,
      true,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: selected ? colors.primary : Colors.grey,
          ),
          4.verticalSpace,
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: selected ? colors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onCartPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onCartPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(
              MediaQuery.sizeOf(context).width,
              80.h,
            ),
            painter: BottomNavPainter(),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 80.h,
              child: Row(
                children: [
                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.person_outline,
                      title: 'الحساب',
                      selected: currentIndex == 0,
                      onTap: () => onChanged(0),
                    ),
                  ),

                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'الطلبات',
                      selected: currentIndex == 1,
                      onTap: () => onChanged(1),
                    ),
                  ),

                  SizedBox(width: 80.w),

                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.favorite_border,
                      title: 'المفضلة',
                      selected: currentIndex == 2,
                      onTap: () => onChanged(2),
                    ),
                  ),

                  Expanded(
                    child: BottomNavItem(
                      icon: Icons.home_outlined,
                      title: 'الرئيسية',
                      selected: currentIndex == 3,
                      onTap: () => onChanged(3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: -10.h,
            child: GestureDetector(
              onTap: onCartPressed,
              child: Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF58C34D),
                  border: Border.all(
                    color: Colors.white,
                    width: 5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}