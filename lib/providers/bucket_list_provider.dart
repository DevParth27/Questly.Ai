import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:questlyy/models/bucket_list_item.dart';

class BucketListProvider with ChangeNotifier {
  List<BucketListItem> _bucketListItems = [];
  final String _storageKey = 'bucket_list_items';
  bool _isLoading = true;

  BucketListProvider() {
    _loadItems();
  }

  bool get isLoading => _isLoading;
  List<BucketListItem> get bucketListItems => [..._bucketListItems];

  final List<String> _categories = [
    'All',
    'Travel',
    'Adventure',
    'Skills',
    'Career',
    'Personal',
  ];

  List<String> get categories => [..._categories];

  // Load items from SharedPreferences
  Future<void> _loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_storageKey);

      if (itemsJson != null) {
        final List<dynamic> decodedItems = jsonDecode(itemsJson);
        _bucketListItems = decodedItems
            .map((item) => BucketListItem.fromJson(item))
            .toList();
      } else {
        // Initialize with default items if no saved data
        _bucketListItems = [
          BucketListItem(
            id: '1',
            title: 'Visit Paris',
            description: 'See the Eiffel Tower and visit Louvre Museum',
            category: 'Travel',
            isCompleted: false,
            dueDate: DateTime.now().add(const Duration(days: 365)),
            priority: Priority.medium,
            difficulty: 3,
            impact: 4,
            collaborators: ['John', 'Emma'],
            milestones: [
              Milestone(title: 'Book flights', isCompleted: true),
              Milestone(title: 'Reserve accommodation', isCompleted: false),
              Milestone(title: 'Create itinerary', isCompleted: false),
            ],
          ),
          BucketListItem(
            id: '2',
            title: 'Learn to play guitar',
            description: 'Take lessons and practice regularly',
            category: 'Skills',
            isCompleted: false,
            dueDate: DateTime.now().add(const Duration(days: 180)),
            priority: Priority.high,
            difficulty: 4,
            impact: 3,
            collaborators: [],
            milestones: [
              Milestone(title: 'Purchase guitar', isCompleted: true),
              Milestone(title: 'Learn basic chords', isCompleted: false),
              Milestone(title: 'Play first song', isCompleted: false),
            ],
          ),
        ];
        // Save initial items
        await _saveItems();
      }
    } catch (e) {
      debugPrint('Error loading bucket list items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save items to SharedPreferences
  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = jsonEncode(
        _bucketListItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_storageKey, itemsJson);
    } catch (e) {
      debugPrint('Error saving bucket list items: $e');
    }
  }

  // Add a new item
  Future<void> addBucketListItem(BucketListItem item) async {
    _bucketListItems.add(item);
    notifyListeners();
    await _saveItems();
  }

  // Toggle item completion
  Future<void> toggleItemCompletion(String id) async {
    final itemIndex = _bucketListItems.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _bucketListItems[itemIndex].isCompleted = !_bucketListItems[itemIndex].isCompleted;
      notifyListeners();
      await _saveItems();
    }
  }

  // Toggle milestone completion
  Future<void> toggleMilestoneCompletion(String itemId, int milestoneIndex) async {
    final itemIndex = _bucketListItems.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0 && milestoneIndex < _bucketListItems[itemIndex].milestones.length) {
      _bucketListItems[itemIndex].milestones[milestoneIndex].isCompleted = 
          !_bucketListItems[itemIndex].milestones[milestoneIndex].isCompleted;
      notifyListeners();
      await _saveItems();
    }
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    _bucketListItems.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveItems();
  }

  // Update an item
  Future<void> updateItem(String id, BucketListItem updatedItem) async {
    final itemIndex = _bucketListItems.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _bucketListItems[itemIndex] = updatedItem;
      notifyListeners();
      await _saveItems();
    }
  }
}