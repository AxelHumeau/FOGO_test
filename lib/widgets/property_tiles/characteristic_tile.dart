import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/blocs/bluetooth_property_bloc.dart';
import 'package:flutter_blue_plus_example/widgets/property_tiles/descriptor_tile.dart';
import 'package:flutter_blue_plus_example/widgets/property_tiles/property_tile.dart';

class CharacteristicTile extends PropertyTile<BluetoothCharacteristic> {
  final List<DescriptorTile> descriptorTiles;

  CharacteristicTile(
      {Key? key,
      required BluetoothCharacteristic characteristic,
      required this.descriptorTiles})
      : super(key: key, property: characteristic);

  Widget buildButtonRow(BuildContext context) {
    bool read = property.properties.read;
    bool write = property.properties.write;
    bool notify = property.properties.notify;
    bool indicate = property.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  Widget buildSubscribeButton(BuildContext context) {
    return TextButton(
        child: Text(property.isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () => context
            .read<BluetoothPropertyBloc<BluetoothCharacteristic>>()
            .add(BluetoothPropertySubscribePressed()));
  }

  @override
  Widget buildTile(
      BuildContext context, BluetoothCharacteristic _, List<int> value) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'),
            buildUuid(context),
            buildValue(context, value),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: descriptorTiles,
    );
  }
}
