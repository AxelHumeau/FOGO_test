import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/blocs/bluetooth_devices_scan_bloc.dart';

import 'device_screen.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  void onConnectPressed(BuildContext context, BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e),
          success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device),
        settings: RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: () => context
            .read<BluetoothDevicesScanBloc>()
            .add(BluetoothDevicesScanCanceled()),
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
        child: const Text("SCAN"),
        onPressed: () => context
            .read<BluetoothDevicesScanBloc>()
            .add(BluetoothDevicesScanStarted()),
      );
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context, List<BluetoothDevice> systemDevices) {
    return systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeviceScreen(device: d),
                settings: RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(context, d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context, List<ScanResult> scanResults) {
    return scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(context, r.device),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<BluetoothDevicesScanBloc>().add(
                  BluetoothDevicesScanReloaded(),
                );
            Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<BluetoothDevicesScanBloc, BluetoothDevicesScanState>(
            builder: (context, state) {
              return ListView(
                children: <Widget>[
                  ..._buildSystemDeviceTiles(context, state.systemDevices),
                  ..._buildScanResultTiles(context, state.scanResults),
                ],
              );
            },
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
