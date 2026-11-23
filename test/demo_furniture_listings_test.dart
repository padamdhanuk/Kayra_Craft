import 'package:flutter_test/flutter_test.dart';
import 'package:kayra_craft/data/demo_furniture_listings.dart';

void main() {
  test('provides five demo listings with HTTPS image links', () {
    expect(demoFurnitureListings, hasLength(5));
    expect(
      demoFurnitureListings.map((listing) => listing.imageUrl),
      everyElement(startsWith('https://')),
    );
  });
}
