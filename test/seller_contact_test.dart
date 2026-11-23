import 'package:flutter_test/flutter_test.dart';
import 'package:kayra_craft/utils/seller_contact.dart';

void main() {
  test('normalizes and validates international phone numbers', () {
    expect(normalizeContactPhone('+91 (98765) 43210'), '+919876543210');
    expect(isValidContactPhone('+91 (98765) 43210'), isTrue);
    expect(isValidContactPhone('98765 43210'), isFalse);
  });
}
