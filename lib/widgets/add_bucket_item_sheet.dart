import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questlyy/models/bucket_list_item.dart';
import 'package:questlyy/providers/bucket_list_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddBucketItemSheet extends StatefulWidget {
  final bool isEditing;
  final BucketListItem? itemToEdit;

  const AddBucketItemSheet({
    Key? key,
    this.isEditing = false,
    this.itemToEdit,
  }) : super(key: key);

  @override
  State<AddBucketItemSheet> createState() => _AddBucketItemSheetState();
}

class _AddBucketItemSheetState extends State<AddBucketItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Travel';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  Priority _priority = Priority.medium;
  int _difficulty = 3;
  int _impact = 3;
  final List<TextEditingController> _milestoneControllers = [];

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditing && widget.itemToEdit != null) {
      // Populate form with existing item data
      final item = widget.itemToEdit!;
      _titleController.text = item.title;
      _descriptionController.text = item.description;
      _selectedCategory = item.category;
      _dueDate = item.dueDate;
      _priority = item.priority;
      _difficulty = item.difficulty;
      _impact = item.impact;
      
      // Add milestone controllers
      for (var milestone in item.milestones) {
        final controller = TextEditingController(text: milestone.title);
        _milestoneControllers.add(controller);
      }
    } else {
      // Add one empty milestone controller by default
      _milestoneControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _milestoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMilestone() {
    setState(() {
      _milestoneControllers.add(TextEditingController());
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestoneControllers[index].dispose();
      _milestoneControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<BucketListProvider>(context, listen: false);
      
      // Create milestones list
      final milestones = _milestoneControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) {
            // If editing, try to preserve completion status
            if (widget.isEditing && widget.itemToEdit != null) {
              final existingMilestone = widget.itemToEdit!.milestones.firstWhere(
                (m) => m.title == controller.text,
                orElse: () => Milestone(title: controller.text),
              );
              return Milestone(
                title: controller.text,
                isCompleted: existingMilestone.isCompleted,
              );
            }
            return Milestone(title: controller.text);
          })
          .toList();

      final item = BucketListItem(
        id: widget.isEditing ? widget.itemToEdit!.id : const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        isCompleted: widget.isEditing ? widget.itemToEdit!.isCompleted : false,
        dueDate: _dueDate,
        priority: _priority,
        difficulty: _difficulty,
        impact: _impact,
        collaborators: widget.isEditing ? widget.itemToEdit!.collaborators : [],
        milestones: milestones,
      );

      if (widget.isEditing) {
        provider.updateItem(item.id, item);
      } else {
        provider.addBucketListItem(item);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BucketListProvider>(context);
    final categories = provider.categories.where((c) => c != 'All').toList();
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEditing ? 'Edit Bucket List Item' : 'Add New Bucket List Item',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_dueDate),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Priority:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<Priority>(
                      title: const Text('Low'),
                      value: Priority.low,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Priority>(
                      title: const Text('Medium'),
                      value: Priority.medium,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Priority>(
                      title: const Text('High'),
                      value: Priority.high,
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Difficulty (1-5):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _difficulty.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _difficulty.toString(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Impact (1-5):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _impact.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _impact.toString(),
                onChanged: (value) {
                  setState(() {
                    _impact = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Milestones:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addMilestone,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              ..._milestoneControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Milestone ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeMilestone(index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? 'Update Item' : 'Add Item',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}