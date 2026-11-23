import 'package:flutter_test/flutter_test.dart';
import 'package:kayra_craft/models/furniture_listing.dart';

void main() {
  test('listing reads its structured fields from Firestore', () {
    final listing = FurnitureListing.fromMap('listing-1', {
      'ownerId': 'seller-1',
      'details': 'Solid wood sofa',
      'imageUrl': 'https://example.com/sofa.jpg',
      'price': 4000,
      'condition': 'Good',
      'area': 'Indiranagar',
      'status': 'sold',
    });

    expect(listing.id, 'listing-1');
    expect(listing.ownerId, 'seller-1');
    expect(listing.details, 'Solid wood sofa');
    expect(listing.price, 4000);
    expect(listing.condition, 'Good');
    expect(listing.area, 'Indiranagar');
    expect(listing.isSold, isTrue);
  });

  test('older listings without new fields remain readable', () {
    final listing = FurnitureListing.fromMap('legacy-listing', {
      'ownerId': 'seller-1',
      'details': 'Sofa - ₹4,000 - good condition',
      'imageUrl': 'https://example.com/sofa.jpg',
    });

    expect(listing.price, isNull);
    expect(listing.condition, isNull);
    expect(listing.area, isNull);
    expect(listing.isSold, isFalse);
  });

  test('contact details are available only after seller opt-in', () {
    final visibleListing = FurnitureListing.fromMap('shared-listing', {
      'ownerId': 'seller-1',
      'details': 'Solid wood sofa',
      'imageUrl': 'https://example.com/sofa.jpg',
      'contactVisible': true,
      'contactPhone': '+91 98765-43210',
    });
    final hiddenListing = FurnitureListing.fromMap('private-listing', {
      'ownerId': 'seller-1',
      'details': 'Solid wood sofa',
      'imageUrl': 'https://example.com/sofa.jpg',
      'contactVisible': false,
      'contactPhone': '+919876543210',
    });

    expect(visibleListing.contactVisible, isTrue);
    expect(visibleListing.contactPhone, '+919876543210');
    expect(hiddenListing.contactVisible, isFalse);
    expect(hiddenListing.contactPhone, isNull);
  });
}
