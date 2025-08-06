import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// [Cubit] to manage the Bluetooth adapter state.
/// It listens to the adapter state changes and emits the current state.
class BluetoothAdapterCubit extends Cubit<BluetoothAdapterState> {
  late final StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  BluetoothAdapterCubit() : super(BluetoothAdapterState.unknown) {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      emit(state);
    });
  }

  @override
  Future<void> close() {
    _adapterStateSubscription.cancel();
    return super.close();
  }
}
