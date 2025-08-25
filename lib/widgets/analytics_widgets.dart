import 'package:flutter/material.dart';
import 'package:questlyy/models/bucket_list_item.dart';

class CategoryDistributionChart extends StatelessWidget {
  final List<BucketListItem> items;

  const CategoryDistributionChart({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate category distribution
    final Map<String, int> categoryCount = {};
    for (var item in items) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: categoryCount.length,
                itemBuilder: (context, index) {
                  final category = categoryCount.keys.elementAt(index);
                  final count = categoryCount[category]!;
                  final percentage = (count / items.length) * 100;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$category (${percentage.toStringAsFixed(0)}%)'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: count / items.length,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(category),
                          ),
                          minHeight: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'travel':
        return Colors.blue;
      case 'adventure':
        return Colors.orange;
      case 'skills':
        return Colors.green;
      case 'career':
        return Colors.purple;
      case 'personal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class CompletionStatsWidget extends StatelessWidget {
  final List<BucketListItem> items;

  const CompletionStatsWidget({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedCount = items.where((item) => item.isCompleted).length;
    final totalCount = items.length;
    final completionPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: completedCount / (totalCount > 0 ? totalCount : 1),
                      strokeWidth: 15,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${completionPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount of $totalCount',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}