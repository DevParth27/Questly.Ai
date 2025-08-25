import 'package:flutter/material.dart';
import 'package:questlyy/models/bucket_list_item.dart';

class ImpactDifficultyMatrix extends StatelessWidget {
  final List<BucketListItem> items;

  const ImpactDifficultyMatrix({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Stack(
        children: [
          // Background grid
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: MatrixPainter(),
          ),
          
          // Items
          ...items.map((item) {
            // Convert 1-5 scale to 0.0-1.0 for positioning
            final x = item.impact / 5;
            final y = 1 - (item.difficulty / 5); // Invert Y so higher is easier
            
            return Positioned(
              left: x * (MediaQuery.of(context).size.width - 80),
              top: y * 250,
              child: Tooltip(
                message: item.title,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(item.priority),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            );
          }).toList(),
          
          // Labels
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Text('Impact', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          
          // Quadrant labels
          const Positioned(
            top: 30,
            right: 30,
            child: Text(
              'Quick Wins',
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ),
          const Positioned(
            top: 30,
            left: 30,
            child: Text(
              'Maybe Later',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
          const Positioned(
            bottom: 30,
            right: 30,
            child: Text(
              'Big Projects',
              style: TextStyle(fontSize: 12, color: Colors.purple),
            ),
          ),
          const Positioned(
            bottom: 30,
            left: 30,
            child: Text(
              'Not Worth It',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }
}

class MatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw horizontal and vertical center lines
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    
    // Draw border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}