import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class UserData with ChangeNotifier {
  String? userId;
  String? email;
  int batteryLevel = 0;
  bool isPluggedIn = false;
  String vin = '';
  int targetBattery = 80;
  int emergencyThreshold = 40;
  int chargingDuration = 4;
  bool solarChargingEnabled = false; // Add this property

  void updateFromFirestore(Map<String, dynamic> data) {
    batteryLevel = data['vehicle']['batteryLevel'] ?? 0;
    isPluggedIn = data['vehicle']['isPluggedIn'] ?? false;
    vin = data['vehicle']['vin'] ?? '';
    targetBattery = data['settings']['targetBattery'] ?? 80;
    emergencyThreshold = data['settings']['emergencyThreshold'] ?? 40;
    chargingDuration = data['settings']['chargingDuration'] ?? 4;
    // Read the value from Firestore, defaulting to false if it doesn't exist
    solarChargingEnabled = data['settings']['solarChargingEnabled'] ?? false;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
