import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questlyy/providers/ai_provider.dart';
import 'package:questlyy/providers/bucket_list_provider.dart';
import 'package:questlyy/models/bucket_list_item.dart';

class AIGeneratorDialog extends StatelessWidget {
  const AIGeneratorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final aiProvider = Provider.of<AIProvider>(context);
    final bucketListProvider = Provider.of<BucketListProvider>(context, listen: false);

    return AlertDialog(
      title: const Text('AI Bucket List Generator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'What are you interested in?',
              hintText: 'E.g., "outdoor adventures in Asia"',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              aiProvider.setPrompt(value);
            },
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          if (aiProvider.isGeneratingIdeas)
            const Center(child: CircularProgressIndicator())
          else if (aiProvider.aiSuggestions.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: aiProvider.aiSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(aiProvider.aiSuggestions[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        // Add to bucket list
                        final newItem = BucketListItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: aiProvider.aiSuggestions[index],
                          description: 'AI generated bucket list item',
                          category: 'AI Generated',
                          isCompleted: false,
                          dueDate: DateTime.now().add(const Duration(days: 365)),
                          priority: Priority.medium,
                          difficulty: 3,
                          impact: 3,
                          collaborators: [],
                          milestones: [],
                        );
                        bucketListProvider.addBucketListItem(newItem);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            aiProvider.generateIdeas();
          },
          child: const Text('Generate Ideas'),
        ),
      ],
    );
  }
}