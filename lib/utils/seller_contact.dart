final _phoneSeparators = RegExp(r'[\s()-]');
final _internationalPhoneNumber = RegExp(r'^\+[1-9][0-9]{7,14}$');

String normalizeContactPhone(String value) =>
    value.replaceAll(_phoneSeparators, '');

bool isValidContactPhone(String value) =>
    _internationalPhoneNumber.hasMatch(normalizeContactPhone(value));
