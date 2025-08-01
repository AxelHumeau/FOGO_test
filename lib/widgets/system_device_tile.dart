import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/blocs/bluetooth_device_connection_cubit.dart';

class SystemDeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BluetoothDeviceConnectionCubit(device),
      child: ListTile(
        title: Text(device.platformName),
        subtitle: Text(device.remoteId.str),
        trailing: BlocSelector<BluetoothDeviceConnectionCubit, BluetoothConnectionState, bool>(
          selector: (state) => state == BluetoothConnectionState.connected,
          builder: (context, isConnected) {
            return ElevatedButton(
              child: isConnected ? const Text('OPEN') : const Text('CONNECT'),
              onPressed: isConnected ? onOpen : onConnect,
            );
          },
        ),
      ),
    );
  }
}
