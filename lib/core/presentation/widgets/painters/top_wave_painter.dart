import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(346.58, 7.76904);
    path_0.cubicTo(353.838, 4.46108, 362.58, 6.00918, 369.989, 10.6245);
    path_0.cubicTo(377.181, 15.1045, 383.259, 22.5512, 385.714, 31.6079);
    path_0.lineTo(385.94, 32.4888);
    path_0.lineTo(386.134, 33.3306);
    path_0.cubicTo(389.981, 51.0182, 380.507, 70.0318, 367.94, 78.8052);
    path_0.cubicTo(355.195, 87.7037, 340.153, 88.5622, 326.017, 89.2329);
    path_0.cubicTo(235.865, 93.5109, 145.529, 97.7915, 55.3389, 92.6528);
    path_0.lineTo(51.0439, 92.4009);
    path_0.cubicTo(43.4885, 91.9429, 35.6409, 91.3932, 28.2637, 88.2349);
    path_0.cubicTo(20.8559, 85.0634, 13.8631, 78.9154, 10.4141, 69.8472);
    path_0.lineTo(10.4141, 69.8462);
    path_0.cubicTo(6.76109, 60.2539, 7.55684, 49.4049, 10.7773, 39.6597);
    path_0.cubicTo(13.9975, 29.9157, 19.6799, 21.1545, 25.9658, 15.7124);
    path_0.cubicTo(29.5067, 12.6459, 33.036, 11.6305, 36.5469, 11.9556);
    path_0.cubicTo(39.9982, 12.2752, 43.3303, 13.8827, 46.5352, 15.8403);
    path_0.cubicTo(48.1446, 16.8234, 49.7487, 17.9122, 51.3359, 18.9956);
    path_0.cubicTo(52.9302, 20.0838, 54.5068, 21.1653, 56.0908, 22.1587);
    path_0.cubicTo(59.2694, 24.1521, 62.3775, 25.721, 65.5039, 26.2134);
    path_0.lineTo(65.5029, 26.2134);
    path_0.cubicTo(75.7284, 27.8173, 86.0474, 24.168, 96.0635, 20.2495);
    path_0.cubicTo(106.425, 16.1955, 117.246, 11.5839, 128.399, 12.022);
    path_0.lineTo(128.398, 12.022);
    path_0.cubicTo(134.438, 12.2577, 140.272, 13.9553, 145.962, 16.1567);
    path_0.cubicTo(151.601, 18.3383, 157.297, 21.1006, 162.802, 23.4038);
    path_0.cubicTo(173.967, 28.0752, 185.951, 31.1193, 196.543, 25.9751);
    path_0.cubicTo(200.295, 24.1529, 203.666, 21.5372, 207.214, 18.9185);
    path_0.cubicTo(210.506, 16.4882, 213.936, 14.0679, 217.827, 12.4937);
    path_0.lineTo(218.612, 12.1899);
    path_0.cubicTo(227.67, 8.84936, 237.392, 8.35572, 246.616, 11.0269);
    path_0.cubicTo(256.288, 13.8265, 265.477, 19.9284, 274.442, 24.9077);
    path_0.cubicTo(283.502, 29.9394, 292.377, 33.8654, 301.766, 32.8198);
    path_0.cubicTo(309.9, 31.914, 317.139, 27.5296, 324.375, 22.3677);
    path_0.cubicTo(331.54, 17.2565, 338.747, 11.3391, 346.58, 7.76904);
    path_0.close();

    Paint paint0Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.005063291;
    paint0Stroke.color = Colors.black.withValues(alpha: 1.0);
    canvas.drawPath(path_0, paint0Stroke);

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xff000000).withValues(alpha: 1.0);
    canvas.drawPath(path_0, paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(92.3662, 20.8236);
    path_1.cubicTo(103.27, 16.8441, 114.348, 12.4518, 125.737, 12.8691);
    path_1.cubicTo(138.03, 13.3166, 149.629, 19.3244, 161.328, 23.8901);
    path_1.cubicTo(173.027, 28.4558, 185.939, 31.5884, 197.449, 26.3738);
    path_1.cubicTo(205.506, 22.7233, 211.909, 15.8999, 220.417, 12.9743);
    path_1.cubicTo(229.684, 9.78578, 239.616, 9.31925, 249.031, 11.8622);
    path_1.cubicTo(268.945, 17.239, 286.738, 35.2501, 307.071, 33.1379);
    path_1.cubicTo(324.65, 31.3121, 338.093, 15.4937, 354.222, 8.6368);
    path_1.cubicTo(368.564, 2.5395, 389.261, 14.1848, 393.907, 32.0762);
    path_1.cubicTo(398.328, 49.105, 388.551, 67.7057, 375.514, 76.196);
    path_1.cubicTo(362.477, 84.6864, 347.063, 85.5311, 332.25, 86.1867);
    path_1.cubicTo(236.531, 90.4234, 140.68, 94.6591, 45.0011, 89.2756);
    path_1.cubicTo(37.0866, 88.8281, 29.0626, 88.2944, 21.5432, 85.2916);
    path_1.cubicTo(14.0239, 82.2889, 6.94481, 76.4757, 3.45501, 67.9171);
    path_1.cubicTo(-3.96117, 49.755, 6.60401, 26.5752, 19.4147, 16.2299);
    path_1.cubicTo(33.4273, 4.91018, 45.9571, 24.6464, 59.8869, 26.6926);
    path_1.cubicTo(70.8905, 28.3026, 81.9272, 24.633, 92.3662, 20.8236);
    path_1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawPath(path_1, paint1Fill);

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = Colors.white.withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.002531646,
        size.height * 0.07335554,
        size.width * 0.9974684,
        size.height * 0.9266467,
      ),
      paint2Fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
