import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_backend/bluetooth_low_energy_peripheral.dart';

class BluetoothLowEnergyScanner extends BleScanner {
  BluetoothLowEnergyScanner({required this.backend, required this.serviceIds}) {
    backend.discovered.listen(_addPeripheral);
  }

  final CentralManager backend;
  final List<UUID> serviceIds;
  final List<BlePeripheral> _devices = [];
  bool _isScanInProgress = false;

  @override
  BleScannerState get state => BleScannerState(
        devices: _devices,
        isScanInProgress: _isScanInProgress,
      );

  @override
  Future<void> scan() async {
    _devices.clear();
    _isScanInProgress = true;
    await backend.startDiscovery(serviceUUIDs: serviceIds);
    notifyState(state);
  }

  @override
  Future<void> stop() async {
    if (!_isScanInProgress) return;
    _isScanInProgress = false;
    await backend.stopDiscovery();
    notifyState(state);
  }

  void _addPeripheral(DiscoveredEventArgs device) {
    final scannedDevice = _createPeripheral(device);
    final knownDeviceIndex =
        _devices.indexWhere((d) => d.id == scannedDevice.id);
    if (knownDeviceIndex >= 0) {
      _devices[knownDeviceIndex] = scannedDevice;
    } else {
      _devices.add(scannedDevice);
    }
    notifyState(state);
  }

  BlePeripheral _createPeripheral(DiscoveredEventArgs device) {
    return BluetoothLowEnergyPeripheral(
      backend: backend,
      serviceIds: serviceIds,
      device: device,
    );
  }
}
