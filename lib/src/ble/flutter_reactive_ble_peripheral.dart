import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/flutter_reactive_ble_connector.dart';

class FlutterReactiveBlePeripheral extends BlePeripheral {
  FlutterReactiveBlePeripheral(
      {required this.backend,
      required this.serviceIds,
      required this.discoveredDevice});

  final FlutterReactiveBle backend;
  final List<Uuid> serviceIds;
  DiscoveredDevice discoveredDevice;

  @override
  String get id => discoveredDevice.id;
  @override
  String get name => discoveredDevice.name;
  @override
  int get rssi => discoveredDevice.rssi;

  @override
  Future<BleConnector> createConnector() async {
    return FlutterReactiveBleConnector(
        backend: backend, deviceId: id, serviceIds: serviceIds);
  }
}
