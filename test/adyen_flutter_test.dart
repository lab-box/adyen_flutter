import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:adyen_flutter/adyen_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('adyen_flutter');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await AdyenFlutter.platformVersion, '42');
  });
}
