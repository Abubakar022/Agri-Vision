// lib/src/presentation/controllers/history_controller.dart
import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_vision/src/data/models/history_model.dart';

class HistoryController extends GetxController {
  var historyList = <DetectionHistory>[].obs;
  final String _storageKey = 'detection_history';
  
  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }
  
  // Load history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_storageKey);
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> historyData = jsonDecode(historyJson);
        final List<DetectionHistory> loadedHistory = [];
        
        for (var item in historyData) {
          try {
            // Check if image file exists before adding to history
            final file = File(item['imagePath']);
            if (await file.exists()) {
              loadedHistory.add(DetectionHistory.fromMap(item));
            }
          } catch (e) {
            // Skip invalid entries
            print('Error loading history item: $e');
          }
        }
        
        historyList.assignAll(loadedHistory);
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }
  
  // Save history to SharedPreferences
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> historyData = 
          historyList.map((history) => history.toMap()).toList();
      final String historyJson = jsonEncode(historyData);
      await prefs.setString(_storageKey, historyJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }
  
  // Add new detection to history
  Future<void> addToHistory(DetectionHistory history) async {
    try {
      // Check if file exists before adding
      if (!await history.imageFile.exists()) {
        print('Image file does not exist: ${history.imageFile.path}');
        return;
      }
      
      // Add to beginning for latest first
      historyList.insert(0, history);
      await _saveHistory();
    } catch (e) {
      print('Error adding history: $e');
    }
  }
  
  // Remove single history item
  Future<void> removeHistory(String id) async {
    try {
      historyList.removeWhere((item) => item.id == id);
      await _saveHistory();
    } catch (e) {
      print('Error removing history: $e');
    }
  }
  
  // Clear all history
  Future<void> clearAllHistory() async {
    try {
      historyList.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
  
  // Check if history is empty
  bool get isHistoryEmpty => historyList.isEmpty;
}