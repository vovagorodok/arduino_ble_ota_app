import "package:flutter_web_bluetooth/flutter_web_bluetooth.dart";
import 'package:ble_ota_app/src/ble/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_connector.dart';

class FlutterWebBluetoothPeripheral extends BlePeripheral {
  FlutterWebBluetoothPeripheral({required this.device});

  final BluetoothDevice device;

  @override
  String get id => device.id;
  @override
  String get name => device.name ?? "";
  @override
  int get rssi => 0;

  @override
  BleConnector createConnector() {
    return FlutterWebBluetoothConnector(device: device);
  }
}
