// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fogo_technical_test/cubits/bluetooth_adapter_cubit.dart';
import 'package:fogo_technical_test/blocs/bluetooth_devices_scan_bloc.dart';

import 'widgets/bluetooth_off_dialog.dart';
import 'screens/scan_screen.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BluetoothAdapterCubit(),
        ),
        BlocProvider(
          create: (context) => BluetoothDevicesScanBloc(),
        ),
      ],
      child: MaterialApp(
        color: Colors.lightBlue,
        home: BlocListener<BluetoothAdapterCubit, BluetoothAdapterState>(
          listener: (context, state) {
            if (state == BluetoothAdapterState.on) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              return;
            }
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return BluetoothOffDialog(adapterState: state);
              },
            );
          },
          child: ScanScreen(),
        ),
      ),
    );
  }
}
