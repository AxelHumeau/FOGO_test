import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// [Cubit] to manage the Bluetooth device connection state.
/// It listens to the device connection state changes and emits the current state.
class BluetoothDeviceConnectionCubit extends Cubit<BluetoothConnectionState> {
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  final BluetoothDevice device;
  BluetoothDeviceConnectionCubit(this.device) : super(BluetoothConnectionState.disconnected) {
    _connectionStateSubscription = device.connectionState.listen((state) {
      emit(state);
    });
  }

  @override
  Future<void> close() {
    _connectionStateSubscription.cancel();
    return super.close();
  }
}
