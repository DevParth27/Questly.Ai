import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:questlyy/models/bucket_list_item.dart';

class LifeMapPainter extends CustomPainter {
  final List<BucketListItem> items;

  LifeMapPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    // Draw radar background
    final categories = <String>{};
    for (var item in items) {
      categories.add(item.category);
    }
    
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw concentric circles
    for (var i = 1; i <= 5; i++) {
      final circleRadius = radius * i / 5;
      canvas.drawCircle(center, circleRadius, paint);
    }
    
    // Draw category axes
    final categoryList = categories.toList();
    final angleStep = 2 * math.pi / categoryList.length;
    
    for (var i = 0; i < categoryList.length; i++) {
      final angle = i * angleStep;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(dx, dy), paint);
      
      // Draw category label
      final textPainter = TextPainter(
        text: TextSpan(
          text: categoryList[i],
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final labelDx = center.dx + (radius + 15) * math.cos(angle) - textPainter.width / 2;
      final labelDy = center.dy + (radius + 15) * math.sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(labelDx, labelDy));
    }
    
    // Draw data points
    final dataPoints = <Offset>[];
    
    for (var i = 0; i < categoryList.length; i++) {
      final category = categoryList[i];
      final categoryItems = items.where((item) => item.category == category).toList();
      
      if (categoryItems.isNotEmpty) {
        // Calculate average impact for this category
        final avgImpact = categoryItems.map((e) => e.impact).reduce((a, b) => a + b) / 
            categoryItems.length;
        
        // Normalize to 0-1 range (assuming impact is 1-5)
        final normalizedValue = avgImpact / 5;
        
        final angle = i * angleStep;
        final pointRadius = radius * normalizedValue;
        final dx = center.dx + pointRadius * math.cos(angle);
        final dy = center.dy + pointRadius * math.sin(angle);
        
        dataPoints.add(Offset(dx, dy));
        
        // Draw point
        final pointPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(dx, dy), 5, pointPaint);
      }
    }
    
    // Connect data points
    if (dataPoints.length > 1) {
      final pathPaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      final path = Path();
      path.moveTo(dataPoints[0].dx, dataPoints[0].dy);
      
      for (var i = 1; i < dataPoints.length; i++) {
        path.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
      
      path.close();
      canvas.drawPath(path, pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}