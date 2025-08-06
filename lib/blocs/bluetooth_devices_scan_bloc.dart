import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fogo_technical_test/utils/snackbar.dart';

/// Events for [BluetoothDevicesScanBloc]
/// Usable events types are:
/// - [BluetoothDevicesScanStarted]: Start scanning for Bluetooth devices.
/// - [BluetoothDevicesScanCanceled]: Cancel the ongoing scan.
/// - [BluetoothDevicesScanReloaded]: Reload the scan results.
sealed class BluetoothDevicesScanEvent {}

/// Event to start scanning for Bluetooth devices.
class BluetoothDevicesScanStarted extends BluetoothDevicesScanEvent {}

/// Event to cancel the ongoing scan.
class BluetoothDevicesScanCanceled extends BluetoothDevicesScanEvent {}

/// Event to reload the scan results.
class BluetoothDevicesScanReloaded extends BluetoothDevicesScanEvent {}

/// Internal event to update the scan results.
class _BluetoothDevicesScanResultsUpdated extends BluetoothDevicesScanEvent {
  final List<ScanResult> scanResults;

  _BluetoothDevicesScanResultsUpdated(this.scanResults);
}

/// Internal event to update the scanning status.
class _BluetoothDevicesScanStatusUpdated extends BluetoothDevicesScanEvent {
  final bool isScanning;

  _BluetoothDevicesScanStatusUpdated(this.isScanning);
}

/// [Bloc] to manage Bluetooth device scanning.
/// It provides a [BluetoothDevicesScanState] to the UI to reflect the current state of the scan.
///
/// Events of type [BluetoothDevicesScanEvent] can be used with the bloc.
/// Check [BluetoothDevicesScanEvent] for the list of events.
class BluetoothDevicesScanBloc
    extends Bloc<BluetoothDevicesScanEvent, BluetoothDevicesScanState> {
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  /// Creates a new instance of [BluetoothDevicesScanBloc].
  /// Initializes the subscriptions to the scan results and scanning status.
  ///
  /// See [BluetoothDevicesScanEvent] for the list of events that can be used with this bloc.
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

/// State for [BluetoothDevicesScanBloc]
/// It holds the list of system devices, scan results, and scanning status.
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
