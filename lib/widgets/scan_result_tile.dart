import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_example/cubits/bluetooth_device_connection_cubit.dart';

/// Tile to display a Bluetooth scan result.
class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback? onTap;

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  String getNiceManufacturerData(List<List<int>> data) {
    return data
        .map((val) => '${getNiceHexArray(val)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries
        .map((v) => '${v.key}: ${getNiceHexArray(v.value)}')
        .join(', ')
        .toUpperCase();
  }

  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  Widget _buildTitle(BuildContext context) {
    if (result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.platformName,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(result.device.remoteId.str);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return BlocSelector<BluetoothDeviceConnectionCubit,
        BluetoothConnectionState, bool>(
      selector: (state) => state == BluetoothConnectionState.connected,
      builder: (context, isConnected) {
        return ElevatedButton(
          child: isConnected ? const Text('OPEN') : const Text('CONNECT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: (result.advertisementData.connectable)
              ? onTap
              : null,
        );
      },
    );
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var adv = result.advertisementData;
    return BlocProvider(
      create: (context) => BluetoothDeviceConnectionCubit(result.device),
      child: ExpansionTile(
        title: _buildTitle(context),
        leading: Text(result.rssi.toString()),
        trailing: _buildConnectButton(context),
        children: <Widget>[
          if (adv.advName.isNotEmpty)
            _buildAdvRow(context, 'Name', adv.advName),
          if (adv.txPowerLevel != null)
            _buildAdvRow(context, 'Tx Power Level', '${adv.txPowerLevel}'),
          if ((adv.appearance ?? 0) > 0)
            _buildAdvRow(context, 'Appearance',
                '0x${adv.appearance!.toRadixString(16)}'),
          if (adv.msd.isNotEmpty)
            _buildAdvRow(
                context, 'Manufacturer Data', getNiceManufacturerData(adv.msd)),
          if (adv.serviceUuids.isNotEmpty)
            _buildAdvRow(context, 'Service UUIDs',
                getNiceServiceUuids(adv.serviceUuids)),
          if (adv.serviceData.isNotEmpty)
            _buildAdvRow(
                context, 'Service Data', getNiceServiceData(adv.serviceData)),
        ],
      ),
    );
  }
}
