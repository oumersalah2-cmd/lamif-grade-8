import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/performance_trend_point.dart';

/// D3 / Recharts-inspired interactive line & gradient-area chart
/// with smooth cubic bezier curves, grid lines, and interactive touch scrubbing.
class PerformanceTrendChart extends StatefulWidget {
  final List<PerformanceTrendPoint> points;
  final String? activeSubjectTitle;
  final double height;

  const PerformanceTrendChart({
    Key? key,
    required this.points,
    this.activeSubjectTitle,
    this.height = 240,
  }) : super(key: key);

  @override
  State<PerformanceTrendChart> createState() => _PerformanceTrendChartState();
}

class _PerformanceTrendChartState extends State<PerformanceTrendChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.Center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainContent.center,
          children: const [
            Icon(Icons.show_chart_rounded, size: 44, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              'Ragaan qormaataa hin jiru',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Qormaata fudhadhuutii adeemsa kee asitti hordofi.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    final hoveredPoint = _hoveredIndex != null && _hoveredIndex! < widget.points.length
        ? widget.points[_hoveredIndex!]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chart Header with Active Indicator / Tooltip Preview
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainContent.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activeSubjectTitle ?? 'Adeemsa Qabxii Hunda (Overall Trend)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hoveredPoint != null
                          ? 'Qormaata: ${hoveredPoint.formattedDate} • ${hoveredPoint.subjectNameOm}'
                          : 'Tuqaa ykn sarara tuquun ragaa ilaali',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hoveredPoint != null ? const Color(0xFF15803D) : const Color(0xFF64748B),
                        fontWeight: hoveredPoint != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (hoveredPoint != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: hoveredPoint.isPassed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hoveredPoint.isPassed ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Text(
                      '${hoveredPoint.scorePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hoveredPoint.isPassed ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF15803D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Qabxii %',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 14,
                        height: 1.5,
                        color: const Color(0xFFDC2626).withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Darbi (50%)',
                        style: TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Canvas Container with Gesture Detector
          SizedBox(
            height: widget.height,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) => _handleTouch(details.localPosition),
              onHorizontalDragStart: (details) => _handleTouch(details.localPosition),
              onTapDown: (details) => _handleTouch(details.localPosition),
              onTapUp: (_) => setState(() => _hoveredIndex = null),
              onHorizontalDragEnd: (_) => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                painter: _D3RechartsLineChartPainter(
                  points: widget.points,
                  hoveredIndex: _hoveredIndex,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _handleTouch(Offset localPosition) {
    if (widget.points.isEmpty) return;
    const paddingLeft = 44.0;
    const paddingRight = 20.0;
    final width = context.size?.width ?? 300.0;
    final chartWidth = width - paddingLeft - paddingRight;

    if (chartWidth <= 0) return;

    final touchX = (localPosition.dx - paddingLeft).clamp(0.0, chartWidth);
    final count = widget.points.length;
    if (count == 1) {
      setState(() => _hoveredIndex = 0);
      return;
    }

    final index = ((touchX / chartWidth) * (count - 1)).round().clamp(0, count - 1);
    setState(() => _hoveredIndex = index);
  }
}

/// CustomPainter rendering smooth cubic bezier curves, gradient fills, and Recharts dots
class _D3RechartsLineChartPainter extends CustomPainter {
  final List<PerformanceTrendPoint> points;
  final int? hoveredIndex;

  _D3RechartsLineChartPainter({
    required this.points,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const paddingLeft = 44.0;
    const paddingRight = 20.0;
    const paddingTop = 16.0;
    const paddingBottom = 28.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 1. Draw Y-Axis Grid Lines & Labels (0%, 25%, 50%, 75%, 100%)
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final thresholdPaint = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int percentage = 0; percentage <= 100; percentage += 25) {
      final y = paddingTop + chartHeight - (percentage / 100.0 * chartHeight);

      // Grid line
      if (percentage == 50) {
        // 50% passing threshold dashed/highlighted line
        _drawDashedLine(canvas, Offset(paddingLeft, y), Offset(size.width - paddingRight, y), thresholdPaint);
      } else {
        canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);
      }

      // Y-axis label
      textPainter.text = TextSpan(
        text: '$percentage%',
        style: TextStyle(
          fontSize: 10,
          color: percentage == 50 ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
          fontWeight: percentage == 50 ? FontWeight.bold : FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, y - textPainter.height / 2));
    }

    if (points.isEmpty) return;

    // Calculate canvas coordinates for each point
    final List<Offset> offsets = [];
    final count = points.length;

    for (int i = 0; i < count; i++) {
      final x = count == 1
          ? paddingLeft + chartWidth / 2
          : paddingLeft + (i / (count - 1)) * chartWidth;
      final clampedPercent = points[i].scorePercentage.clamp(0.0, 100.0);
      final y = paddingTop + chartHeight - (clampedPercent / 100.0 * chartHeight);
      offsets.add(Offset(x, y));
    }

    // 2. Build Smooth Cubic Bezier Curves (like D3 curveMonotoneX / Recharts type="monotone")
    final linePath = Path();
    final areaPath = Path();

    linePath.moveTo(offsets[0].dx, offsets[0].dy);
    areaPath.moveTo(offsets[0].dx, paddingTop + chartHeight);
    areaPath.lineTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];

      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      linePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );

      areaPath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    areaPath.lineTo(offsets.last.dx, paddingTop + chartHeight);
    areaPath.close();

    // 3. Draw Gradient Area Fill
    final primaryColor = points.first.subjectColor;
    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withOpacity(0.24),
        primaryColor.withOpacity(0.01),
      ],
    );

    final areaPaint = Paint()
      ..shader = areaGradient.createShader(
        Rect.fromLTRB(paddingLeft, paddingTop, size.width - paddingRight, paddingTop + chartHeight),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(areaPath, areaPaint);

    // 4. Draw Smooth Line Path
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // 5. Draw Recharts Data Dots
    final dotFillPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final isHovered = hoveredIndex == i;
      final radius = isHovered ? 6.5 : 4.0;

      canvas.drawCircle(offset, radius, dotFillPaint);
      canvas.drawCircle(offset, radius, dotBorderPaint);
    }

    // 6. Draw Interactive Scrubber Tooltip Line if active
    if (hoveredIndex != null && hoveredIndex! < offsets.length) {
      final target = offsets[hoveredIndex!];

      // Vertical guide line
      final scrubberPaint = Paint()
        ..color = const Color(0xFF0F172A).withOpacity(0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      _drawDashedLine(
        canvas,
        Offset(target.dx, paddingTop),
        Offset(target.dx, paddingTop + chartHeight),
        scrubberPaint,
      );

      // Active glow circle
      final glowPaint = Paint()..color = primaryColor.withOpacity(0.25);
      canvas.drawCircle(target, 12, glowPaint);
    }

    // 7. X-Axis Date Labels
    if (offsets.length > 1) {
      // First date label
      final firstDate = points.first.formattedDate;
      textPainter.text = TextSpan(
        text: firstDate,
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft, paddingTop + chartHeight + 8));

      // Last date label
      final lastDate = points.last.formattedDate;
      textPainter.text = TextSpan(
        text: lastDate,
        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - paddingRight - textPainter.width, paddingTop + chartHeight + 8));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final count = (distance / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < count; i++) {
      final startFraction = (i * (dashWidth + dashSpace)) / distance;
      final endFraction = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset(p1.dx + dx * startFraction, p1.dy + dy * startFraction),
        Offset(p1.dx + dx * endFraction, p1.dy + dy * endFraction),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _D3RechartsLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.hoveredIndex != hoveredIndex;
  }
}
