import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/widgets/property_tiles/property_tile.dart';

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
