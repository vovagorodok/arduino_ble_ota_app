import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/core/remote_info.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/http/http_info_reader.dart';

class InfoReader extends StatefulStream<InfoState> {
  InfoReader({required BleCentral bleCentral, required String deviceId})
      : _bleInfoReader =
            BleInfoReader(bleCentral: bleCentral, deviceId: deviceId),
        _httpInfoReader = HttpInfoReader() {
    _bleInfoReader.stateStream.listen(_onDeviceInfoStateChanged);
    _httpInfoReader.stateStream.listen(_onRemoteInfoStateChanged);
  }

  final BleInfoReader _bleInfoReader;
  final HttpInfoReader _httpInfoReader;
  late String _manufacturesDictUrl;
  InfoState _state = InfoState(remoteInfo: RemoteInfo());

  @override
  InfoState get state => _state;

  void read(String manufacturesDictUrl) {
    _manufacturesDictUrl = manufacturesDictUrl;
    _state = InfoState(
      status: WorkStatus.working,
      remoteInfo: RemoteInfo(),
    );
    notifyStateUpdate(state);

    _bleInfoReader.read();
  }

  void _raiseError(InfoError error, int errorCode) {
    state.status = WorkStatus.error;
    state.error = error;
    state.errorCode = errorCode;
    notifyStateUpdate(state);
  }

  void _onDeviceInfoStateChanged(DeviceInfoState deviceInfoState) {
    if (deviceInfoState.status == WorkStatus.success) {
      state.deviceInfo = deviceInfoState.info;
      _httpInfoReader.read(state.deviceInfo, _manufacturesDictUrl);
    } else if (deviceInfoState.status == WorkStatus.error) {
      _raiseError(deviceInfoState.error, deviceInfoState.errorCode);
    }
  }

  void _onRemoteInfoStateChanged(RemoteInfoState remoteInfoState) {
    if (remoteInfoState.status == WorkStatus.success) {
      state.remoteInfo = remoteInfoState.info;
      state.status = WorkStatus.success;
      notifyStateUpdate(state);
    } else if (remoteInfoState.status == WorkStatus.error) {
      _raiseError(remoteInfoState.error, remoteInfoState.errorCode);
    }
  }
}

class InfoState extends WorkState<WorkStatus, InfoError> {
  InfoState({
    super.status = WorkStatus.idle,
    super.error = InfoError.unknown,
    this.deviceInfo = const DeviceInfo(),
    required this.remoteInfo,
  });

  DeviceInfo deviceInfo;
  RemoteInfo remoteInfo;
}
