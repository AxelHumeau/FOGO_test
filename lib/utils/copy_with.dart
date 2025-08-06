import 'package:flutter_blue_plus/flutter_blue_plus.dart';

extension BluetoothCharacteristicCopyWith on BluetoothCharacteristic {
  BluetoothCharacteristic copyWith({
    DeviceIdentifier? remoteId,
    Guid? serviceUuid,
    Guid? characteristicUuid,
    Guid? primaryServiceUuid,
  }) {
    return BluetoothCharacteristic(
      remoteId: remoteId ?? this.remoteId,
      serviceUuid: serviceUuid ?? this.serviceUuid,
      characteristicUuid: characteristicUuid ?? this.characteristicUuid,
      primaryServiceUuid: primaryServiceUuid ?? this.primaryServiceUuid,
    );
  }
}

extension BluetoothDescriptorCopyWith on BluetoothDescriptor {
  BluetoothDescriptor copyWith({
    DeviceIdentifier? remoteId,
    Guid? serviceUuid,
    Guid? characteristicUuid,
    Guid? descriptorUuid,
    Guid? primaryServiceUuid,
  }) {
    return BluetoothDescriptor(
      remoteId: remoteId ?? this.remoteId,
      serviceUuid: serviceUuid ?? this.serviceUuid,
      characteristicUuid: characteristicUuid ?? this.characteristicUuid,
      descriptorUuid: descriptorUuid ?? this.descriptorUuid,
      primaryServiceUuid: primaryServiceUuid ?? this.primaryServiceUuid,
    );
  }
}
