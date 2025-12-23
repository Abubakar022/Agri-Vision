import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool _isConnected = true.obs;
  bool _snackbarShown = false;

  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _setupListener();
  }

  Future<void> _initConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _handleConnectivity(connectivityResult);
    } catch (e) {
      debugPrint('Connectivity initialization error: $e');
    }
  }

  void _setupListener() {
    _connectivity.onConnectivityChanged.listen((event) {
      _handleConnectivity(event);
    });
  }

  void _handleConnectivity(dynamic connectivityData) {
    ConnectivityResult result;
    
    // Handle both old and new versions of connectivity_plus
    if (connectivityData is List<ConnectivityResult>) {
      // New version returns List<ConnectivityResult>
      result = connectivityData.isNotEmpty ? connectivityData.first : ConnectivityResult.none;
    } else if (connectivityData is ConnectivityResult) {
      // Old version returns ConnectivityResult directly
      result = connectivityData;
    } else {
      result = ConnectivityResult.none;
    }
    
    final connected = result != ConnectivityResult.none;
    
    if (connected != _isConnected.value) {
      _isConnected.value = connected;
      
      if (!connected) {
        _showNoInternetSnackbar();
      } else {
        _hideSnackbar();
        _showConnectedSnackbar();
      }
    }
  }

  void _showNoInternetSnackbar() {
    if (!_snackbarShown) {
      _snackbarShown = true;
      Get.rawSnackbar(
        title: 'انٹرنیٹ کنکشن نہیں ہے',
        message: 'براہ کرم اپنا انٹرنیٹ کنکشن چیک کریں',
        backgroundColor: Colors.red,
        duration: const Duration(days: 365),
        isDismissible: false,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.zero,
        borderRadius: 0,
        titleText: Directionality(
          textDirection: TextDirection.rtl,
          child: const Text(
            'انٹرنیٹ کنکشن نہیں ہے',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        messageText: Directionality(
          textDirection: TextDirection.rtl,
          child: const Text(
            'براہ کرم اپنا انٹرنیٹ کنکشن چیک کریں',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    }
  }

  void _hideSnackbar() {
    if (_snackbarShown) {
      Get.closeAllSnackbars();
      _snackbarShown = false;
    }
  }

  void _showConnectedSnackbar() {
    Get.rawSnackbar(
      title: 'کنکٹ ہو گیا',
      message: 'آپ دوبارہ آن لائن ہیں',
      backgroundColor: const Color(0xFF02A96C),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      titleText: Directionality(
        textDirection: TextDirection.rtl,
        child: const Text(
          'کنکٹ ہو گیا',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      messageText: Directionality(
        textDirection: TextDirection.rtl,
        child: const Text(
          'آپ دوبارہ آن لائن ہیں',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      icon: const Icon(Icons.wifi, color: Colors.white),
    );
  }

  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // Handle both return types
      if (result is List<ConnectivityResult>) {
        return result.isNotEmpty && result.first != ConnectivityResult.none;
      } else if (result is ConnectivityResult) {
        return result != ConnectivityResult.none;
      }
      return false;
    } catch (e) {
      debugPrint('Connection check error: $e');
      return false;
    }
  }
}