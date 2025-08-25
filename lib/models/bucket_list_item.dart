import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class Milestone {
  final String title;
  bool isCompleted;

  Milestone({required this.title, this.isCompleted = false});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }
}

class BucketListItem {
  final String id;
  final String title;
  final String description;
  final String category;
  bool isCompleted;
  final DateTime dueDate;
  final Priority priority;
  final int difficulty;
  final int impact;
  final List<String> collaborators;
  final List<Milestone> milestones;

  BucketListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
    required this.dueDate,
    required this.priority,
    required this.difficulty,
    required this.impact,
    required this.collaborators,
    required this.milestones,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'priority': priority.index,
      'difficulty': difficulty,
      'impact': impact,
      'collaborators': collaborators,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    };
  }

  // Create from JSON
  factory BucketListItem.fromJson(Map<String, dynamic> json) {
    return BucketListItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      isCompleted: json['isCompleted'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate']),
      priority: Priority.values[json['priority']],
      difficulty: json['difficulty'],
      impact: json['impact'],
      collaborators: List<String>.from(json['collaborators']),
      milestones: (json['milestones'] as List)
          .map((m) => Milestone.fromJson(m))
          .toList(),
    );
  }
}
