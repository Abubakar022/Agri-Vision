// lib/src/presentation/screens/History_Module/history_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agri_vision/src/presentation/controllers/history_controller.dart';
import 'package:agri_vision/src/data/models/history_model.dart';
import 'package:agri_vision/src/presentation/screens/Detection_Module/resultScreen.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final HistoryController historyController = Get.find<HistoryController>();

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showClearAllDialog() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            "کل ہسٹری صاف کریں",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF02A96C),
            ),
          ),
          content: const Text("کیا آپ واقعی اپنی پوری ہسٹری صاف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہو سکتا۔"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "منسوخ کریں",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                historyController.clearAllHistory();
                Get.snackbar(
                  'کامیابی',
                  'تمام ہسٹری صاف ہو گئی',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  titleText: Directionality(
                    textDirection: TextDirection.rtl,
                    child: const Text(
                      'کامیابی',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  messageText: Directionality(
                    textDirection: TextDirection.rtl,
                    child: const Text(
                      'تمام ہسٹری صاف ہو گئی',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                "صاف کریں",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(DetectionHistory history) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            "نتیجہ حذف کریں",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF02A96C),
            ),
          ),
          content: const Text("کیا آپ واقعی اس نتیجہ کو حذف کرنا چاہتے ہیں؟"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "منسوخ کریں",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                historyController.removeHistory(history.id);
                Get.snackbar(
                  'حذف ہو گیا',
                  'نتیجہ کامیابی سے حذف ہو گیا',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  titleText: Directionality(
                    textDirection: TextDirection.rtl,
                    child: const Text(
                      'حذف ہو گیا',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  messageText: Directionality(
                    textDirection: TextDirection.rtl,
                    child: const Text(
                      'نتیجہ کامیابی سے حذف ہو گیا',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                "حذف کریں",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8E3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDF8E3),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF02A96C),
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "سکین ہسٹری",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF02A96C),
            ),
          ),
          centerTitle: true,
          actions: [
            Obx(() => historyController.historyList.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Colors.red,
                    ),
                    onPressed: _showClearAllDialog,
                    tooltip: 'کل ہسٹری صاف کریں',
                  )
                : const SizedBox.shrink()),
          ],
        ),
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF02A96C).withAlpha(26),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withAlpha(26),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Obx(() {
              if (historyController.historyList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF02A96C).withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF02A96C),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "کوئی ہسٹری نہیں",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF02A96C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "آپ کی سکین ہسٹری یہاں ظاہر ہوگی۔ پہلی سکین کریں اور اپنی ہسٹری دیکھیں۔",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF02A96C).withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF02A96C).withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.history,
                            color: Color(0xFF02A96C),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "کل سکین: ${historyController.historyList.length}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF02A96C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // History List
                    Expanded(
                      child: ListView.builder(
                        itemCount: historyController.historyList.length,
                        itemBuilder: (context, index) {
                          final history = historyController.historyList[index];
                          return _HistoryCard(
                            history: history,
                            onTap: () {
                              Get.to(
                                () => DetectionResultScreen(
                                  imageFile: history.imageFile,
                                  diseaseName: history.diseaseName,
                                  description: history.description,
                                  recommendation: history.recommendation,
                                ),
                              );
                            },
                            onDelete: () => _showDeleteDialog(history),
                            dateTime: _formatDate(history.timestamp),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Custom History Card Widget
class _HistoryCard extends StatelessWidget {
  final DetectionHistory history;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String dateTime;

  const _HistoryCard({
    required this.history,
    required this.onTap,
    required this.onDelete,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delete Button - Moved to left side
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                
                const SizedBox(width: 12),

                // Text Content - Moved to middle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Disease Name
                      Text(
                        history.diseaseName,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF02A96C),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Date and Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            dateTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Shortened Description
                      Text(
                        history.description.length > 80
                            ? '${history.description.substring(0, 80)}...'
                            : history.description,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Image with rounded corners - Moved to right side
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF02A96C).withAlpha(50),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      history.imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}