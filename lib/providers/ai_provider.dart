import 'package:flutter/material.dart';

class AIProvider with ChangeNotifier {
  bool _isGeneratingIdeas = false;
  String _aiPrompt = '';
  final List<String> _aiSuggestions = [];

  bool get isGeneratingIdeas => _isGeneratingIdeas;
  String get aiPrompt => _aiPrompt;
  List<String> get aiSuggestions => [..._aiSuggestions];

  void setPrompt(String prompt) {
    _aiPrompt = prompt;
    notifyListeners();
  }

  Future<void> generateIdeas() async {
    _isGeneratingIdeas = true;
    notifyListeners();

    // Simulate AI generation
    await Future.delayed(const Duration(seconds: 2));
    
    _aiSuggestions.clear();
    if (_aiPrompt.toLowerCase().contains('asia')) {
      _aiSuggestions.addAll([
        'Hike the Great Wall of China',
        'Explore ancient temples in Kyoto',
        'Island hopping in Thailand',
        'Trek to Mount Everest Base Camp',
        'Experience street food tour in Vietnam',
      ]);
    } else if (_aiPrompt.toLowerCase().contains('adventure')) {
      _aiSuggestions.addAll([
        'Skydiving over the Grand Canyon',
        'White water rafting in Costa Rica',
        'Scuba diving in the Great Barrier Reef',
        'Hike to Machu Picchu',
        'Paragliding in the Swiss Alps',
      ]);
    } else {
      _aiSuggestions.addAll([
        'Learn a new language',
        'Write a book',
        'Start a podcast',
        'Run a marathon',
        'Learn to cook international cuisine',
      ]);
    }

    _isGeneratingIdeas = false;
    notifyListeners();
  }
}