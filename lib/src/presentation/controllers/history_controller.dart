// lib/src/presentation/controllers/history_controller.dart
import 'package:get/get.dart';
import 'package:agri_vision/src/data/models/history_model.dart';

class HistoryController extends GetxController {
  var historyList = <DetectionHistory>[].obs;

  // Add new detection to history
  void addToHistory(DetectionHistory history) {
    historyList.insert(0, history); // Add to beginning for latest first
  }

  // Remove single history item
  void removeHistory(String id) {
    historyList.removeWhere((item) => item.id == id);
  }

  // Clear all history
  void clearAllHistory() {
    historyList.clear();
  }

  // Check if history is empty
  bool get isHistoryEmpty => historyList.isEmpty;
}