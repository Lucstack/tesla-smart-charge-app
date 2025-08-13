import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class UserData with ChangeNotifier {
  String? userId;
  String? email;
  int batteryLevel = 0;
  bool isPluggedIn = false;
  String vin = '';
  int targetBattery = 80;
  int emergencyThreshold = 40; // Add this
  int chargingDuration = 4; // Add this

  void updateFromFirestore(Map<String, dynamic> data) {
    batteryLevel = data['vehicle']['batteryLevel'] ?? 0;
    isPluggedIn = data['vehicle']['isPluggedIn'] ?? false;
    vin = data['vehicle']['vin'] ?? '';
    targetBattery = data['settings']['targetBattery'] ?? 80;
    emergencyThreshold =
        data['settings']['emergencyThreshold'] ?? 40; // Add this
    chargingDuration = data['settings']['chargingDuration'] ?? 4; // Add this

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
