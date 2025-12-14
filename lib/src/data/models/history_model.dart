// lib/src/data/models/history_model.dart
import 'dart:io';
import 'dart:convert';

class DetectionHistory {
  final String id;
  final File imageFile;
  final String diseaseName;
  final String description;
  final String recommendation;
  final DateTime timestamp;
  final String confidence;
  
  DetectionHistory({
    required this.id,
    required this.imageFile,
    required this.diseaseName,
    required this.description,
    required this.recommendation,
    required this.timestamp,
    required this.confidence,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imageFile.path, // Store only the path, not the File object
      'diseaseName': diseaseName,
      'description': description,
      'recommendation': recommendation,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'confidence': confidence,
    };
  }

  // Create from map
  factory DetectionHistory.fromMap(Map<String, dynamic> map) {
    return DetectionHistory(
      id: map['id'],
      imageFile: File(map['imagePath']), // Recreate File from path
      diseaseName: map['diseaseName'],
      description: map['description'],
      recommendation: map['recommendation'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      confidence: map['confidence'] ?? "N/A",
    );
  }
}