import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fogo_technical_test/utils/snackbar.dart';

/// Events for [BluetoothPropertyBloc]
/// Usable events types are:
/// - [BluetoothPropertyReadPressed]: Read the property value.
/// - [BluetoothPropertyWritePressed]: Write a value to the property.
/// - [BluetoothPropertySubscribePressed]: Subscribe to notifications for the property.
sealed class BluetoothPropertyEvent {}

/// Internal event to update the property value.
class _BluetoothPropertyValueUpdated extends BluetoothPropertyEvent {
  final List<int> value;

  _BluetoothPropertyValueUpdated(this.value);
}

/// Internal event to update the characteristic property.
class _BluetoothPropertyCharacteristicUpdated extends BluetoothPropertyEvent {}

/// Event to read the property value.
class BluetoothPropertyReadPressed extends BluetoothPropertyEvent {}

/// Event to write a value to the property.
class BluetoothPropertyWritePressed extends BluetoothPropertyEvent {}

/// Event to subscribe to notifications for the characteristic.
/// This event is only applicable for [BluetoothCharacteristic].
///
/// An assertion error will be thrown if this event is used for a [BluetoothPropertyBloc] with [T] as [BluetoothDescriptor].
class BluetoothPropertySubscribePressed extends BluetoothPropertyEvent {}

/// [Bloc] to manage Bluetooth property operations.
/// It provides a tuple of the property and its last value to the UI.
///
/// The property of type [T] can be either a [BluetoothCharacteristic] or a [BluetoothDescriptor].
/// This bloc is intended as a generic handler for both types of properties.
///
/// Events of type [BluetoothPropertyEvent] can be used with the bloc.
/// Check [BluetoothPropertyEvent] for the list of events.
class BluetoothPropertyBloc<T>
    extends Bloc<BluetoothPropertyEvent, (T, List<int>)> {
  late StreamSubscription<List<int>> _lastValueSubscription;
  final T property;
  late final String propertyType;

  /// Creates a new instance of [BluetoothPropertyBloc].
  /// Initializes the last value subscription based on the type of property.
  /// Throws an [ArgumentError] if the property type is unsupported.
  /// The property must be either a [BluetoothCharacteristic] or a [BluetoothDescriptor].
  ///
  /// See [BluetoothPropertyEvent] for the list of events that can be used with this bloc.
  BluetoothPropertyBloc(this.property) : super((property, [])) {
    switch (property) {
      case BluetoothCharacteristic c:
        _lastValueSubscription = c.lastValueStream.listen(_updateValue);
        propertyType = 'Characteristic';
        break;
      case BluetoothDescriptor d:
        _lastValueSubscription = d.lastValueStream.listen(_updateValue);
        propertyType = 'Descriptor';
        break;
      default:
        throw ArgumentError('Unsupported type: $T');
    }

    on<_BluetoothPropertyValueUpdated>((event, emit) {
      emit((state.$1, event.value));
    });

    on<_BluetoothPropertyCharacteristicUpdated>((event, emit) {
      assert(state.$1 is BluetoothCharacteristic,
          'This event can only be used with a BluetoothCharacteristic');
      emit((state.$1, state.$2));
    });

    on<BluetoothPropertyReadPressed>((event, emit) async {
      try {
        switch (state.$1) {
          case BluetoothCharacteristic c:
            await c.read();
            add(_BluetoothPropertyCharacteristicUpdated());
            break;
          case BluetoothDescriptor d:
            await d.read();
            break;
          default:
            throw ArgumentError('Unsupported type: ${state.$1.runtimeType}');
        }
        Snackbar.show(ABC.c, "${state.$1.runtimeType} Read: Success",
            success: true);
      } catch (e) {
        Snackbar.show(
            ABC.c, prettyException("${state.$1.runtimeType} Read Error:", e),
            success: false);
        print(e);
      }
    });

    on<BluetoothPropertyWritePressed>((event, emit) async {
      try {
        switch (state.$1) {
          case BluetoothCharacteristic c:
            await c.write(_getRandomBytes(),
                withoutResponse: c.properties.writeWithoutResponse);
            break;
          case BluetoothDescriptor d:
            await d.write(_getRandomBytes());
            break;
          default:
            throw ArgumentError('Unsupported type: ${state.$1.runtimeType}');
        }
        Snackbar.show(ABC.c, "${state.$1.runtimeType} Write: Success",
            success: true);
        if (state.$1 case BluetoothCharacteristic c) {
          if (c.properties.read) await c.read();
          add(_BluetoothPropertyCharacteristicUpdated());
        }
      } catch (e) {
        Snackbar.show(
            ABC.c, prettyException("${state.$1.runtimeType} Write Error:", e),
            success: false);
        print(e);
      }
    });

    on<BluetoothPropertySubscribePressed>((event, emit) async {
      assert(state.$1 is BluetoothCharacteristic,
          'This event can only be used with a BluetoothCharacteristic');
      final c = state.$1 as BluetoothCharacteristic;
      try {
        final op = c.isNotifying ? "Unsubscribe" : "Subscribe";
        await c.setNotifyValue(!c.isNotifying);
        Snackbar.show(ABC.c, "$op : Success", success: true);
        if (c.properties.read) {
          await c.read();
        }
        add(_BluetoothPropertyCharacteristicUpdated());
      } catch (e) {
        Snackbar.show(ABC.c, prettyException("Subscribe Error:", e),
            success: false);
        print(e);
      }
    });
  }

  void _updateValue(List<int> newValue) {
    add(_BluetoothPropertyValueUpdated(newValue));
  }

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  @override
  Future<void> close() {
    _lastValueSubscription.cancel();
    return super.close();
  }
}
