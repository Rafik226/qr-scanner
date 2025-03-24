import 'package:flutter/material.dart';

class QrProvider extends ChangeNotifier {
  String _qrData = '';
  bool _isScanned = false;

  String get qrData => _qrData;
  bool get isScanned => _isScanned;

  void setQrData(String data) {
    _qrData = data;
    _isScanned = true;
    notifyListeners();
  }

  void resetQrData() {
    _qrData = '';
    _isScanned = false;
    notifyListeners();
  }
}