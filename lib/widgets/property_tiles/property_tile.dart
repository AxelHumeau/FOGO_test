import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fogo_technical_test/blocs/bluetooth_property_bloc.dart';

/// Base class for property tiles that display Bluetooth characteristics or descriptors.
/// It provides common functionality for displaying UUIDs, values, and buttons for reading and writing properties.
///
/// This class is generic and can be used for both [BluetoothCharacteristic] and [BluetoothDescriptor] as the generic type [T].
/// It throws an [ArgumentError] if the property type is unsupported.
///
/// The widget rebuilds when the property changes.
///
/// To use this class, extend it and implement the [buildTile] method to define how the tile should be displayed.
abstract class PropertyTile<T> extends StatelessWidget {
  PropertyTile({super.key, required this.property}) {
    if (property is! BluetoothCharacteristic &&
        property is! BluetoothDescriptor) {
      throw ArgumentError('Unsupported type: $T');
    }
    propertyType =
        property is BluetoothCharacteristic ? 'Characteristic' : 'Descriptor';
  }
  final T property;
  late final String propertyType;

  Widget buildUuid(BuildContext context) {
    late final String uuid;
    switch (property) {
      case BluetoothCharacteristic c:
        uuid = '0x${c.uuid.str.toUpperCase()}';
        break;
      case BluetoothDescriptor d:
        uuid = '0x${d.uuid.str.toUpperCase()}';
        break;
      default:
        throw ArgumentError('Unsupported type: $T');
    }
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context, List<int> value) {
    String data = value.toString();
    return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
      child: Text("Read"),
      onPressed: () => context
          .read<BluetoothPropertyBloc<T>>()
          .add(BluetoothPropertyReadPressed()),
    );
  }

  Widget buildWriteButton(BuildContext context) {
    String text = "Write";
    if (property case BluetoothCharacteristic c
        when c.properties.writeWithoutResponse) {
      text = "WriteNoResp";
    }
    return TextButton(
      child: Text(text),
      onPressed: () => context
          .read<BluetoothPropertyBloc<T>>()
          .add(BluetoothPropertyWritePressed()),
    );
  }

  Widget buildButtonRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildReadButton(context),
        buildWriteButton(context),
      ],
    );
  }

  /// Builds the tile for the property.
  Widget buildTile(BuildContext context, T property, List<int> value);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BluetoothPropertyBloc(property),
      child: BlocBuilder<BluetoothPropertyBloc<T>, (T, List<int>)>(
        builder: (context, state) {
          return buildTile(context, state.$1, state.$2);
        },
      ),
    );
  }
}
