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
        final systemDevices = await FlutterBluePlus.systemDevices(withServices);
        emit(state.copyWith(systemDevices: systemDevices));
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
    });

    on<BluetoothDevicesScanCanceled>((event, emit) {
      try {
        FlutterBluePlus.stopScan();
      } catch (e) {
        Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
            success: false);
        print(e);
      }
    });

    on<BluetoothDevicesScanReloaded>((event, emit) {
      if (state.isScanning == false) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      }
    });

    on<_BluetoothDevicesScanResultsUpdated>((event, emit) {
      emit(state.copyWith(scanResults: event.scanResults));
    });

    on<_BluetoothDevicesScanStatusUpdated>((event, emit) {
      emit(state.copyWith(isScanning: event.isScanning));
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
  final List<BluetoothDevice> systemDevices;
  final List<ScanResult> scanResults;
  final bool isScanning;

  BluetoothDevicesScanState({
    this.systemDevices = const [],
    this.scanResults = const [],
    this.isScanning = false,
  });

  BluetoothDevicesScanState copyWith({
    List<BluetoothDevice>? systemDevices,
    List<ScanResult>? scanResults,
    bool? isScanning,
  }) {
    return BluetoothDevicesScanState(
      systemDevices: systemDevices ?? this.systemDevices,
      scanResults: scanResults ?? this.scanResults,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}
