import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Extension methods to provide copy functionality for Bluetooth characteristics and descriptors.
extension BluetoothCharacteristicCopyWith on BluetoothCharacteristic {
  /// Creates a copy of the Bluetooth characteristic with optional overrides for its properties.
  /// If a property is not provided, the original value is used.
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

/// Extension methods to provide copy functionality for Bluetooth descriptors.
extension BluetoothDescriptorCopyWith on BluetoothDescriptor {
  /// Creates a copy of the Bluetooth descriptor with optional overrides for its properties.
  /// If a property is not provided, the original value is used.
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
