import 'package:flutter_test/flutter_test.dart';
import 'package:kayra_craft/models/user_profile.dart';

void main() {
  test('reads profile name and optional neighborhood', () {
    final profile = UserProfile.fromMap({
      'displayName': '  Asha Rao ',
      'location': '  Indiranagar ',
    });

    expect(profile.displayName, 'Asha Rao');
    expect(profile.location, 'Indiranagar');
  });

  test('treats a blank optional neighborhood as absent', () {
    final profile = UserProfile.fromMap({
      'displayName': 'Asha Rao',
      'location': '  ',
    });

    expect(profile.location, isNull);
  });

  test('creates initials from one- and two-part names', () {
    expect(UserProfile.initialsFor('asha'), 'A');
    expect(UserProfile.initialsFor('Asha Rao'), 'AR');
    expect(UserProfile.initialsFor(''), isEmpty);
  });
}
