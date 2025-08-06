import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/blocs/bluetooth_device_info_bloc.dart';
import 'package:flutter_blue_plus_example/widgets/spinner.dart';

import '../widgets/service_tile.dart';
import '../widgets/property_tiles/characteristic_tile.dart';
import '../widgets/property_tiles/descriptor_tile.dart';
import '../utils/snackbar.dart';

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  List<Widget> _buildServiceTiles(
      BuildContext context, BluetoothDeviceInfoState state) {
    return state.services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${device.remoteId}'),
    );
  }

  Widget buildRssiTile(BuildContext context, BluetoothDeviceInfoState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        state.isConnected
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        Text(
            ((state.isConnected && state.rssi != null)
                ? '${state.rssi!} dBm'
                : ''),
            style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  Widget buildGetServices(
      BuildContext context, BluetoothDeviceInfoState state) {
    return IndexedStack(
      index: (state.isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          child: const Text("Get Services"),
          onPressed: () => context
              .read<BluetoothDeviceInfoBloc>()
              .add(BluetoothDeviceInfoDiscoverServicesPressed()),
        ),
        const IconButton(
          icon: SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
          onPressed: null,
        )
      ],
    );
  }

  Widget buildMtuTile(BuildContext context, BluetoothDeviceInfoState state) {
    return ListTile(
        title: const Text('MTU Size'),
        subtitle: Text('${state.mtuSize} bytes'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context
              .read<BluetoothDeviceInfoBloc>()
              .add(BluetoothDeviceInfoRequestMtuPressed()),
        ));
  }

  Widget buildConnectButton(
      BuildContext context, BluetoothDeviceInfoState state) {
    late final VoidCallback buttonCallback;
    late final String buttonText;
    if (state.isConnecting) {
      buttonCallback = () => context
          .read<BluetoothDeviceInfoBloc>()
          .add(BluetoothDeviceInfoCancelPressed());
      buttonText = "CANCEL";
    } else if (state.isConnected) {
      buttonCallback = () => context
          .read<BluetoothDeviceInfoBloc>()
          .add(BluetoothDeviceInfoDisconnectPressed());
      buttonText = "DISCONNECT";
    } else {
      buttonCallback = () => context
          .read<BluetoothDeviceInfoBloc>()
          .add(BluetoothDeviceInfoConnectPressed());
      buttonText = "CONNECT";
    }
    return Row(children: [
      if (state.isConnecting || state.isDisconnecting) Spinner(context: context),
      TextButton(
          onPressed: buttonCallback,
          child: Text(
            buttonText,
            style: Theme.of(context)
                .primaryTextTheme
                .labelLarge
                ?.copyWith(color: Colors.black),
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BluetoothDeviceInfoBloc(device),
      child: ScaffoldMessenger(
        key: Snackbar.snackBarKeyC,
        child: BlocBuilder<BluetoothDeviceInfoBloc, BluetoothDeviceInfoState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(device.platformName),
                actions: [buildConnectButton(context, state)],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    buildRemoteId(context),
                    ListTile(
                      leading: buildRssiTile(context, state),
                      title: Text(
                          'Device is ${state.connectionState.toString().split('.')[1]}.'),
                      trailing: buildGetServices(context, state),
                    ),
                    buildMtuTile(context, state),
                    ..._buildServiceTiles(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
