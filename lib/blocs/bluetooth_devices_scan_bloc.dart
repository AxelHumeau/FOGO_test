import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/utils/snackbar.dart';

sealed class BluetoothDevicesScanEvent {}

class BluetoothDevicesScanStarted extends BluetoothDevicesScanEvent {}

class BluetoothDevicesScanCanceled extends BluetoothDevicesScanEvent {}

class BluetoothDevicesScanReloaded extends BluetoothDevicesScanEvent {}

class _BluetoothDevicesScanResultsUpdated extends BluetoothDevicesScanEvent {
  final List<ScanResult> scanResults;

  _BluetoothDevicesScanResultsUpdated(this.scanResults);
}

class _BluetoothDevicesScanStatusUpdated extends BluetoothDevicesScanEvent {
  final bool isScanning;

  _BluetoothDevicesScanStatusUpdated(this.isScanning);
}

class BluetoothDevicesScanBloc
    extends Bloc<BluetoothDevicesScanEvent, BluetoothDevicesScanState> {
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  BluetoothDevicesScanBloc() : super(BluetoothDevicesScanState()) {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      add(_BluetoothDevicesScanResultsUpdated(results));
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scaningState) {
      add(_BluetoothDevicesScanStatusUpdated(scaningState));
    });

    on<BluetoothDevicesScanStarted>((event, emit) async {
      try {
        // `withServices` is required on iOS for privacy purposes, ignored on android.
        var withServices = [Guid("180f")]; // Battery Level Service
        state.systemDevices = await FlutterBluePlus.systemDevices(withServices);
      } catch (e) {
        Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
            success: false);
        print(e);
      }
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      } catch (e) {
        Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
            success: false);
        print(e);
      }
      emit(BluetoothDevicesScanState.copyFrom(state));
    });

    on<BluetoothDevicesScanCanceled>((event, emit) {
      try {
        FlutterBluePlus.stopScan();
      } catch (e) {
        Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
            success: false);
        print(e);
      }
      emit(BluetoothDevicesScanState.copyFrom(state));
    });

    on<BluetoothDevicesScanReloaded>((event, emit) {
      if (state.isScanning == false) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      }
      emit(BluetoothDevicesScanState.copyFrom(state));
    });

    on<_BluetoothDevicesScanResultsUpdated>((event, emit) {
      state.scanResults = event.scanResults;
      emit(BluetoothDevicesScanState.copyFrom(state));
    });

    on<_BluetoothDevicesScanStatusUpdated>((event, emit) {
      state.isScanning = event.isScanning;
      emit(BluetoothDevicesScanState.copyFrom(state));
    });
  }

  @override
  Future<void> close() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    return super.close();
  }
}

class BluetoothDevicesScanState {
  BluetoothDevicesScanState();

  BluetoothDevicesScanState.copyFrom(BluetoothDevicesScanState state) {
    systemDevices = List.from(state.systemDevices);
    scanResults = List.from(state.scanResults);
    isScanning = state.isScanning;
  }

  List<BluetoothDevice> systemDevices = [];
  List<ScanResult> scanResults = [];
  bool isScanning = false;
}
