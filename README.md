# FOGO Technical Test

This flutter app is based on the [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) exemple app. Although the state management has been migrated from Stateful widgets to Blocs and Cubits, using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) packages.

Other differences include:
 - the bluetooth off screen no longer being triggered by an navigator observer but now by a cubit
 - the bluetooth off screen being replaced by a undismissable dialog
 - a generic way to handle BluetoothDescriptor and BluetoothCharacteristic as the related widgets had a lot of shared code

