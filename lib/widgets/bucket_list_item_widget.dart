import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questlyy/models/bucket_list_item.dart';
import 'package:questlyy/providers/bucket_list_provider.dart';
import 'package:questlyy/widgets/add_bucket_item_sheet.dart';
import 'package:share_plus/share_plus.dart';

class BucketListItemWidget extends StatelessWidget {
  final BucketListItem item;
  final bool isGridView;

  const BucketListItemWidget({
    Key? key,
    required this.item,
    this.isGridView = false,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (item.priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  void _showEditItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddBucketItemSheet(
        isEditing: true,
        itemToEdit: item,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final provider = Provider.of<BucketListProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _shareItem() {
    final String milestones = item.milestones.isEmpty
        ? ''
        : '\n\nMilestones:\n' +
            item.milestones
                .map((m) => '- ${m.isCompleted ? '✓' : '○'} ${m.title}')
                .join('\n');

    final String shareText = '''
🎯 BUCKET LIST ITEM: ${item.title}
📝 ${item.description}
🏷️ Category: ${item.category}
📅 Due: ${item.dueDate.day}/${item.dueDate.month}/${item.dueDate.year}
⭐ Priority: ${item.priority.toString().split('.').last}
${milestones}

#BucketList #Goals #Questlyy
''';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridItem(context);
    } else {
      return _buildListItem(context);
    }
  }

  Widget _buildListItem(BuildContext context) {
    final provider = Provider.of<BucketListProvider>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditItemSheet(context);
                        break;
                      case 'delete':
                        _confirmDelete(context);
                        break;
                      case 'share':
                        _shareItem();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                Checkbox(
                  value: item.isCompleted,
                  onChanged: (_) {
                    provider.toggleItemCompletion(item.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(item.category),
                  backgroundColor: Colors.blue.shade100,
                ),
                const Spacer(),
                Text(
                  'Due: ${item.dueDate.day}/${item.dueDate.month}/${item.dueDate.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (item.milestones.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Milestones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...item.milestones.asMap().entries.map((entry) {
                final index = entry.key;
                final milestone = entry.value;
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    milestone.title,
                    style: TextStyle(
                      decoration: milestone.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  value: milestone.isCompleted,
                  onChanged: (_) {
                    provider.toggleMilestoneCompletion(item.id, index);
                  },
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    final provider = Provider.of<BucketListProvider>(context, listen: false);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        item.category,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.blue.shade100,
                      padding: EdgeInsets.zero,
                    ),
                    Checkbox(
                      value: item.isCompleted,
                      onChanged: (_) {
                        provider.toggleItemCompletion(item.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditItemSheet(context);
                    break;
                  case 'delete':
                    _confirmDelete(context);
                    break;
                  case 'share':
                    _shareItem();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18),
                      SizedBox(width: 8),
                      Text('Share', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}