import 'dart:io';
import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/core/net_info_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:wakelock/wakelock.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({required this.deviceId, required this.deviceName, Key? key})
      : bleConnector = BleConnector(deviceId: deviceId),
        bleInfoReader = BleInfoReader(deviceId: deviceId),
        bleUploader = BleUploader(deviceId: deviceId),
        netInfoReader = NetInfoReader(),
        super(key: key);

  final String deviceId;
  final String deviceName;
  final BleConnector bleConnector;
  final BleInfoReader bleInfoReader;
  final BleUploader bleUploader;
  final NetInfoReader netInfoReader;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  late List<StreamSubscription> _subscriptions;

  void _onConnectionStateChanged(ConnectionStateUpdate state) {
    if (state.connectionState == DeviceConnectionState.disconnected) {
      widget.bleConnector.findAndConnect();
    } else if (state.connectionState == DeviceConnectionState.connected) {
      widget.bleInfoReader.read();
    }
  }

  void _onHwInfoStateChanged(HwInfoState info) {
    setState(() {
      if (info.ready) {
        widget.netInfoReader.read(info.hwInfo);
      }
    });
  }

  void _onUploadStateChanged(UploadState state) {
    setState(() {
      if (state.status == UploadStatus.begin) {
        Wakelock.enable();
      } else if (state.status == UploadStatus.success ||
          state.status == UploadStatus.error) {
        Wakelock.disable();
      }
    });
  }

  void _onSwInfoStateChanged(SwInfoState state) {
    setState(() {});
  }

  @override
  void initState() {
    _subscriptions = [
      widget.netInfoReader.infoStream.listen(_onSwInfoStateChanged),
      widget.bleUploader.stateStream.listen(_onUploadStateChanged),
      widget.bleInfoReader.infoStream.listen(_onHwInfoStateChanged),
      widget.bleConnector.stateStream.listen(_onConnectionStateChanged),
    ];
    widget.bleConnector.connect();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    widget.bleConnector.disconnect();
    Wakelock.disable();
  }

  bool _isUploaderBuisy(UploadStatus status) {
    return status == UploadStatus.begin ||
        status == UploadStatus.upload ||
        status == UploadStatus.end;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      await _uploadFile(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  Future<void> _uploadFile(String path) async {
    File file = File(path);
    var data = await file.readAsBytes();
    widget.bleUploader.upload(data);
  }

  String _determinateStatusText() {
    switch (widget.bleUploader.state.status) {
      case UploadStatus.begin:
        return "Starting..";
      case UploadStatus.upload:
        return "Uploading..";
      case UploadStatus.end:
        return "Ending..";
      case UploadStatus.success:
        return "Success!";
      case UploadStatus.error:
        return "Error: ${widget.bleUploader.state.errorMsg}";
      case UploadStatus.idle:
        return "Ready";
      default:
        return "Unknown status";
    }
  }

  MaterialColor _determinateStatusColor() {
    switch (widget.bleUploader.state.status) {
      case UploadStatus.begin:
        return Colors.blue;
      case UploadStatus.upload:
        return Colors.blue;
      case UploadStatus.end:
        return Colors.blue;
      case UploadStatus.success:
        return Colors.green;
      case UploadStatus.error:
        return Colors.red;
      case UploadStatus.idle:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Widget _buildProgressInside() {
    final state = widget.bleUploader.state;
    if (state.status == UploadStatus.error) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 56,
      );
    } else if (state.status == UploadStatus.success) {
      return const Icon(
        Icons.done,
        color: Colors.green,
        size: 56,
      );
    } else {
      return Text(
        (state.progress * 100).toStringAsFixed(1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: state.status == UploadStatus.idle
              ? Colors.blue.shade200
              : Colors.blue,
          fontSize: 24,
        ),
      );
    }
  }

  Widget _buildProgressWidget() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: widget.bleUploader.state.progress,
            color: _determinateStatusColor(),
            strokeWidth: 10,
            backgroundColor: _determinateStatusColor().shade200,
          ),
          Center(child: _buildProgressInside()),
        ],
      ),
    );
  }

  Widget _buildSoftwareList() => ListView.builder(
        itemCount: widget.netInfoReader.infoState.swInfoList.length,
        itemBuilder: (context, index) {
          final sw = widget.netInfoReader.infoState.swInfoList[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                backgroundImage:
                    sw.icon != null ? NetworkImage(sw.icon!) : null,
              ),
              title: Text("$sw"),
              subtitle: const Text(""),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.deviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                Text(
                    "Hardware: ${widget.bleInfoReader.infoState.toHwString()}"),
                Text(
                    "Software: ${widget.bleInfoReader.infoState.toSwString()}"),
                Text("Status: ${_determinateStatusText()}"),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildProgressWidget()]),
                const SizedBox(height: 20),
                Flexible(
                  child: _buildSoftwareList(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text('Upload file'),
                  onPressed: _isUploaderBuisy(widget.bleUploader.state.status)
                      ? null
                      : _pickFile,
                )
              ],
            ),
          ),
        ),
      );
}
