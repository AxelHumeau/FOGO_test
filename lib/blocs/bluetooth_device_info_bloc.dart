import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/utils/extra.dart';
import 'package:flutter_blue_plus_example/utils/snackbar.dart';

/// Events for [BluetoothDeviceInfoBloc]
/// Usable events types are:
/// - [BluetoothDeviceInfoConnectPressed]: Connect to the device.
/// - [BluetoothDeviceInfoCancelPressed]: Cancel the connection.
/// - [BluetoothDeviceInfoDisconnectPressed]: Disconnect from the device.
/// - [BluetoothDeviceInfoDiscoverServicesPressed]: Discover services of the device.
/// - [BluetoothDeviceInfoRequestMtuPressed]: Request the MTU size of the device
sealed class BluetoothDeviceInfoEvent {}

/// Internal event to update the connection state, services, and RSSI
class _BluetoothDeviceInfoConnectionStateUpdated
    extends BluetoothDeviceInfoEvent {
  final BluetoothConnectionState connectionState;
  final List<BluetoothService>? services;
  final int? rssi;

  _BluetoothDeviceInfoConnectionStateUpdated(
      this.connectionState, this.services, this.rssi);
}

/// Internal event to update the MTU size
class _BluetoothDeviceInfoMtuUpdated extends BluetoothDeviceInfoEvent {
  final int mtuSize;

  _BluetoothDeviceInfoMtuUpdated(this.mtuSize);
}

/// Internal event to update the isConnecting state
class _BluetoothDeviceInfoIsConnectingUpdated extends BluetoothDeviceInfoEvent {
  final bool isConnecting;

  _BluetoothDeviceInfoIsConnectingUpdated(this.isConnecting);
}

/// Internal event to update the isDisconnecting state
class _BluetoothDeviceInfoIsDisconnectingUpdated
    extends BluetoothDeviceInfoEvent {
  final bool isDisconnecting;

  _BluetoothDeviceInfoIsDisconnectingUpdated(this.isDisconnecting);
}

/// Internal event to update the isDiscoveringServices state
class _BluetoothDeviceInfoIsDiscoverServicesUpdated
    extends BluetoothDeviceInfoEvent {
  final bool isDiscoveringServices;
  _BluetoothDeviceInfoIsDiscoverServicesUpdated(this.isDiscoveringServices);
}

/// Internal event to update the services list
class _BluetoothDeviceInfoServicesUpdated extends BluetoothDeviceInfoEvent {
  final List<BluetoothService> services;

  _BluetoothDeviceInfoServicesUpdated(this.services);
}

/// Event to connect to the Bluetooth device
class BluetoothDeviceInfoConnectPressed extends BluetoothDeviceInfoEvent {}

/// Event to cancel the connection to the Bluetooth device
class BluetoothDeviceInfoCancelPressed extends BluetoothDeviceInfoEvent {}

/// Event to disconnect from the Bluetooth device
class BluetoothDeviceInfoDisconnectPressed extends BluetoothDeviceInfoEvent {}

class BluetoothDeviceInfoDiscoverServicesPressed
    extends BluetoothDeviceInfoEvent {}

class BluetoothDeviceInfoRequestMtuPressed extends BluetoothDeviceInfoEvent {}

/// [Bloc] to manage Bluetooth device information and connection state.
/// It provide a [BluetoothDeviceInfoState] to the UI to reflect the current state.
///
/// Events of type [BluetoothDeviceInfoEvent] can be used with the bloc.
/// Check [BluetoothDeviceInfoEvent] for the list of events.
class BluetoothDeviceInfoBloc
    extends Bloc<BluetoothDeviceInfoEvent, BluetoothDeviceInfoState> {
  late final StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late final StreamSubscription<bool> _isConnectingSubscription;
  late final StreamSubscription<bool> _isDisconnectingSubscription;
  late final StreamSubscription<int> _mtuSubscription;
  final BluetoothDevice device;

  /// Creates a new instance of [BluetoothDeviceInfoBloc] with the given [device].
  /// Initializes the subscriptions to the device's connection state, MTU, and other properties.
  ///
  /// See [BluetoothDeviceInfoEvent] for the list of events that can be used with this bloc.
  BluetoothDeviceInfoBloc(this.device) : super(BluetoothDeviceInfoState()) {
    _initSubscriptions();

    on<_BluetoothDeviceInfoConnectionStateUpdated>((event, emit) {
      emit(state.copyWith(
        connectionState: event.connectionState,
        services: event.services ?? state.services,
        rssi: event.rssi ?? state.rssi,
      ));
    });

    on<_BluetoothDeviceInfoMtuUpdated>((event, emit) {
      emit(state.copyWith(mtuSize: event.mtuSize));
    });

    on<_BluetoothDeviceInfoIsConnectingUpdated>((event, emit) {
      emit(state.copyWith(isConnecting: event.isConnecting));
    });

    on<_BluetoothDeviceInfoIsDisconnectingUpdated>((event, emit) {
      emit(state.copyWith(isDisconnecting: event.isDisconnecting));
    });

    on<_BluetoothDeviceInfoIsDiscoverServicesUpdated>((event, emit) {
      emit(state.copyWith(isDiscoveringServices: event.isDiscoveringServices));
    });

    on<_BluetoothDeviceInfoServicesUpdated>((event, emit) {
      emit(state.copyWith(services: event.services));
    });

    on<BluetoothDeviceInfoConnectPressed>((event, emit) async {
      try {
        await device.connectAndUpdateStream();
        Snackbar.show(ABC.c, "Connect: Success", success: true);
      } catch (e) {
        if (e is! FlutterBluePlusException ||
            e.code != FbpErrorCode.connectionCanceled.index) {
          Snackbar.show(ABC.c, prettyException("Connect Error:", e),
              success: false);
          print(e);
        }
      }
    });

    on<BluetoothDeviceInfoCancelPressed>((event, emit) async {
      try {
        await device.disconnectAndUpdateStream(queue: false);
        Snackbar.show(ABC.c, "Cancel: Success", success: true);
      } catch (e) {
        Snackbar.show(ABC.c, prettyException("Cancel Error:", e),
            success: false);
        print(e);
      }
    });

    on<BluetoothDeviceInfoDisconnectPressed>((event, emit) async {
      try {
        await device.disconnectAndUpdateStream();
        Snackbar.show(ABC.c, "Disconnect: Success", success: true);
      } catch (e) {
        Snackbar.show(ABC.c, prettyException("Disconnect Error:", e),
            success: false);
        print(e);
      }
    });

    on<BluetoothDeviceInfoDiscoverServicesPressed>((event, emit) async {
      add(_BluetoothDeviceInfoIsDiscoverServicesUpdated(true));
      try {
        add(_BluetoothDeviceInfoServicesUpdated(
            await device.discoverServices()));
        Snackbar.show(ABC.c, "Discover Services: Success", success: true);
      } catch (e) {
        Snackbar.show(ABC.c, prettyException("Discover Services Error:", e),
            success: false);
        print(e);
      }
      add(_BluetoothDeviceInfoIsDiscoverServicesUpdated(false));
    });

    on<BluetoothDeviceInfoRequestMtuPressed>((event, emit) async {
      try {
        await device.requestMtu(223, predelay: 0);
        Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
      } catch (e) {
        Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e),
            success: false);
        print(e);
      }
    });
  }

  void _initSubscriptions() {
    _connectionStateSubscription =
        device.connectionState.listen((connectionState) async {
      List<BluetoothService>? services;
      int? rssi;
      if (state == BluetoothConnectionState.connected) {
        services = <BluetoothService>[];
      }
      if (state == BluetoothConnectionState.connected && state.rssi == null) {
        rssi = await device.readRssi();
      }
      add(_BluetoothDeviceInfoConnectionStateUpdated(
        connectionState,
        services,
        rssi,
      ));
    });

    _mtuSubscription = device.mtu.listen((value) {
      add(_BluetoothDeviceInfoMtuUpdated(value));
    });

    _isConnectingSubscription = device.isConnecting.listen((value) {
      add(_BluetoothDeviceInfoIsConnectingUpdated(value));
    });

    _isDisconnectingSubscription = device.isDisconnecting.listen((value) {
      add(_BluetoothDeviceInfoIsDisconnectingUpdated(value));
    });
  }

  @override
  Future<void> close() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    return super.close();
  }
}

/// State for [BluetoothDeviceInfoBloc]
/// It holds the current connection state, services, RSSI, MTU size, and flags for discovering services, connecting, and disconnecting.
class BluetoothDeviceInfoState {
  final int? rssi;
  final int? mtuSize;
  final BluetoothConnectionState connectionState;
  final List<BluetoothService> services;
  final bool isDiscoveringServices;
  final bool isConnecting;
  final bool isDisconnecting;

  const BluetoothDeviceInfoState({
    this.rssi,
    this.mtuSize,
    this.connectionState = BluetoothConnectionState.disconnected,
    this.services = const [],
    this.isDiscoveringServices = false,
    this.isConnecting = false,
    this.isDisconnecting = false,
  });

  BluetoothDeviceInfoState copyWith({
    int? rssi,
    int? mtuSize,
    BluetoothConnectionState? connectionState,
    List<BluetoothService>? services,
    bool? isDiscoveringServices,
    bool? isConnecting,
    bool? isDisconnecting,
  }) {
    return BluetoothDeviceInfoState(
      rssi: rssi ?? this.rssi,
      mtuSize: mtuSize ?? this.mtuSize,
      connectionState: connectionState ?? this.connectionState,
      services: services ?? this.services,
      isDiscoveringServices:
          isDiscoveringServices ?? this.isDiscoveringServices,
      isConnecting: isConnecting ?? this.isConnecting,
      isDisconnecting: isDisconnecting ?? this.isDisconnecting,
    );
  }

  bool get isConnected {
    return connectionState == BluetoothConnectionState.connected;
  }
}
