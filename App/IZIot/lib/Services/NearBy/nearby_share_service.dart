import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:universal_ble/universal_ble.dart';

class NearbyShareService {

  // FROM
  // https://www.uuidgenerator.net/#google_vignette

  static const String _serviceUuid = 'b44f54d7-d1f8-4e0a-94a8-8883a6648ca8';
  static const String _usernameCharUuid = 'b44f54d7-d1f8-4e0a-94a8-8883a6648ca8';

  static const int _rssiThreshold = -55;

  static bool _advertising = false;
  static bool _scanning = false;
  static bool _completed = false;

  static Future<void> start({
    required String myUsername,
    required void Function(String username) onReceived,
    required void Function(Object error) onError,
  }) async {
    _completed = false;

    try {
      await _startAdvertisingMyProfile(myUsername);
    } catch (e) {
    }

    await _startScanningForOthers(onReceived, onError);
  }

  static Future<void> stop() async {
    if (_scanning) {
      try {
        await UniversalBle.stopScan();
      } catch (_) {}
      _scanning = false;
    }
    if (_advertising) {
      try {
        await UniversalBlePeripheral.stopAdvertising();
        await UniversalBlePeripheral.clearServices();
      } catch (_) {}
      _advertising = false;
    }
  }

  static Future<void> _startAdvertisingMyProfile(String username) async {
    final caps = await UniversalBlePeripheral.getCapabilities();
    if (!caps.supportsPeripheralMode) return;

    final readiness = await UniversalBlePeripheral.getAvailabilityState();
    if (readiness != PeripheralReadinessState.ready) return;

    await UniversalBlePeripheral.clearServices();
    await UniversalBlePeripheral.addService(
      BlePeripheralService(
        uuid: _serviceUuid,
        primary: true,
        characteristics: [
          BlePeripheralCharacteristic(
            uuid: _usernameCharUuid,
            properties: [CharacteristicProperty.read],
            permissions: [PeripheralAttributePermission.readable],
          ),
        ],
      ),
    );

    UniversalBlePeripheral.setReadRequestHandlers((deviceId, characteristicId, offset, value) {
      return PeripheralReadRequestResult(
        value: Uint8List.fromList(utf8.encode(username)),
      );
    });

    await UniversalBlePeripheral.startAdvertising(
      services: [_serviceUuid],
      localName: 'BzHub',
    );

    _advertising = true;
  }

  static Future<void> _startScanningForOthers(
      void Function(String username) onReceived,
      void Function(Object error) onError,
      ) async {
    UniversalBle.onScanResult = (BleDevice device) async {
      if (_completed) return;

      final rssi = device.rssi ?? -100;
      if (rssi < _rssiThreshold) return;

      _completed = true;

      try {
        await UniversalBle.stopScan();
        await device.connect();

        final service = await device.getService(_serviceUuid);
        final char = await service.getCharacteristic(_usernameCharUuid);
        final value = await char.read();
        final username = utf8.decode(value);

        await device.disconnect();
        onReceived(username);
      } catch (e) {
        onError(e);
        _completed = false;
        await UniversalBle.startScan(
          scanFilter: ScanFilter(withServices: [_serviceUuid]),
        );
      }
    };

    await UniversalBle.startScan(
      scanFilter: ScanFilter(withServices: [_serviceUuid]),
    );
    _scanning = true;
  }
}