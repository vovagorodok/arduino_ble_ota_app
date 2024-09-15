import 'dart:async';

import 'package:universal_ble/universal_ble.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';

class UniversalBleScanner extends BleScanner {
  UniversalBleScanner({required this.serviceIds}) {
    UniversalBle.onScanResult = (device) {
      int index = _devices.indexWhere((d) => d.id == device.deviceId);
      if (index == -1) {
        _devices.add(_createScannedDevice(device));
      } else {
        _devices[index] = _createScannedDevice(device);
      }
      notifyState(state);
    };
  }

  final List<String> serviceIds;
  final _devices = <BleScannedDevice>[];
  bool _scanIsInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        scanIsInProgress: _scanIsInProgress,
      );

  @override
  Future<void> scan() async {
    _devices.clear();
    await UniversalBle.startScan(
        scanFilter: ScanFilter(
      withServices: serviceIds,
    ));
    _scanIsInProgress = true;
    notifyState(state);
  }

  @override
  Future<void> stop() async {
    await UniversalBle.stopScan();
    _scanIsInProgress = false;
    notifyState(state);
  }

  BleScannedDevice _createScannedDevice(BleDevice device) {
    return BleScannedDevice(
      id: device.deviceId,
      name: device.name!,
      rssi: device.rssi!,
    );
  }
}
