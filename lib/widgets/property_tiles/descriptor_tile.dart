import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/widgets/property_tiles/property_tile.dart';

/// Tile to display a Bluetooth descriptor.
/// It extends [PropertyTile] to provide a specific implementation for Bluetooth descriptors.
class DescriptorTile extends PropertyTile<BluetoothDescriptor> {
  DescriptorTile({Key? key, required BluetoothDescriptor descriptor}) : super(key: key, property: descriptor);

  @override
  Widget buildTile(BuildContext context, BluetoothDescriptor _, List<int> value) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          buildUuid(context),
          buildValue(context, value),
        ],
      ),
      subtitle: buildButtonRow(context),
    );
  }
}
