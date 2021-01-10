import 'package:flutter_test/flutter_test.dart';
import 'package:folly_fields/validators/mac_address_validator.dart';

///
///
///
void main() {
  Map<String, bool> isValidTests = <String, bool>{
    null: false,
    '': false,
    '1': false,
    'aa:bb:cc:dd:ee:ff': false,
    'AABBCCDDEEFF': false,
    'AA:BB:CC:DD:EE:FF': true,
    'AA:BB:CC:DD:EE:FZ': false,
    'ZA:BB:CC:DD:EE:FF': false,
    'GH:IJ:KL:MN:OP:QR': false,
    '01:23:45:67:89:AB': true,
  };

  final MacAddressValidator validator = MacAddressValidator();

  for (int i = 0; i < 100; i++) {
    isValidTests[MacAddressValidator.generate()] = true;
  }

  group('MacAddressValidator isValid', () {
    for (MapEntry<String, bool> input in isValidTests.entries) {
      test(
        'Testing: ${input.key}',
        () => expect(validator.isValid(input.key), input.value),
      );
    }
  });

  Map<String, String> formatTests = <String, String>{
    null: '',
    '': '',
    ' ': '',
    '1': '1',
    '12': '12',
    '12:3': '123',
    '12:34': '1234',
    '12:34:5': '12345',
    '12:34:56': '123456',
    '12:34:56:7': '1234567',
    'aa:bb:cc:dd:ee:ff': '',
    'AABBCCDDEEFF': 'AA:BB:CC:DD:EE:FF',
    'AA:BB:CC:DD:EE:FF': 'AA:BB:CC:DD:EE:FF',
    // 'AA:BB:CC:DD:EE:FZ': false,
    // 'ZA:BB:CC:DD:EE:FF': false,
    // 'GH:IJ:KL:MN:OP:QR': false,
    // '01:23:45:67:89:AB': true,
  };

  group('MacAddressValidator format', () {
    for (MapEntry<String, String> input in formatTests.entries) {
      test(
        'Testing: ${input.key}',
        () => expect(validator.format(input.key), input.value),
      );
    }
  });
}
