import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloudinary_image_uploader.dart';
import '../models/furniture_listing.dart';
import '../utils/seller_contact.dart';

class FurnitureListingRepository {
  FurnitureListingRepository({
    FirebaseFirestore? firestore,
    CloudinaryImageUploader? imageUploader,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _imageUploader = imageUploader ?? CloudinaryImageUploader();

  final FirebaseFirestore _firestore;
  final CloudinaryImageUploader _imageUploader;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('furniture_listings');

  Stream<List<FurnitureListing>> watchListings() {
    return _listings.snapshots().map((snapshot) {
      final documents = snapshot.docs.toList()..sort(_compareByCreatedAt);
      return documents
          .map(
            (document) =>
                FurnitureListing.fromMap(document.id, document.data()),
          )
          .toList();
    });
  }

  int _compareByCreatedAt(
    QueryDocumentSnapshot<Map<String, dynamic>> left,
    QueryDocumentSnapshot<Map<String, dynamic>> right,
  ) {
    final leftCreatedAt = left.data()['createdAt'];
    final rightCreatedAt = right.data()['createdAt'];
    if (leftCreatedAt is Timestamp && rightCreatedAt is Timestamp) {
      return rightCreatedAt.compareTo(leftCreatedAt);
    }
    if (leftCreatedAt is Timestamp) {
      return -1;
    }
    if (rightCreatedAt is Timestamp) {
      return 1;
    }
    return 0;
  }

  Future<void> createListing({
    required String ownerId,
    required String details,
    required int price,
    required String condition,
    required String area,
    required bool contactVisible,
    String? contactPhone,
    required Uint8List imageBytes,
    required String fileName,
    required String? contentType,
  }) async {
    _validateListing(
      details: details,
      price: price,
      condition: condition,
      area: area,
      imageBytes: imageBytes,
      contentType: contentType,
    );
    final normalizedContactPhone = _contactPhoneForWrite(
      contactVisible: contactVisible,
      contactPhone: contactPhone,
    );

    final imageUrl = await _imageUploader.uploadImage(
      imageBytes: imageBytes,
      fileName: fileName,
      contentType: contentType,
    );

    await _listings.add({
      'ownerId': ownerId,
      'details': details.trim(),
      'price': price,
      'condition': condition.trim(),
      'area': area.trim(),
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'available',
      'contactVisible': contactVisible,
      'contactPhone': ?normalizedContactPhone,
    });
  }

  Future<void> updateListing({
    required FurnitureListing listing,
    required String details,
    required int price,
    required String condition,
    required String area,
    required bool contactVisible,
    String? contactPhone,
    Uint8List? imageBytes,
    String? fileName,
    String? contentType,
  }) async {
    _validateListing(
      details: details,
      price: price,
      condition: condition,
      area: area,
      imageBytes: imageBytes,
      contentType: contentType,
    );
    final normalizedContactPhone = _contactPhoneForWrite(
      contactVisible: contactVisible,
      contactPhone: contactPhone,
    );

    final imageUrl = imageBytes == null
        ? listing.imageUrl
        : await _imageUploader.uploadImage(
            imageBytes: imageBytes,
            fileName: fileName ?? 'furniture-image.jpg',
            contentType: contentType,
          );
    await _listings.doc(listing.id).update({
      'details': details.trim(),
      'price': price,
      'condition': condition.trim(),
      'area': area.trim(),
      'imageUrl': imageUrl,
      'status': listing.status,
      'contactVisible': contactVisible,
      'contactPhone': normalizedContactPhone ?? FieldValue.delete(),
    });
  }

  Future<void> markListingSold(String listingId) =>
      _listings.doc(listingId).update({'status': 'sold'});

  Future<void> deleteListing(String listingId) =>
      _listings.doc(listingId).delete();

  void _validateListing({
    required String details,
    required int price,
    required String condition,
    required String area,
    required Uint8List? imageBytes,
    required String? contentType,
  }) {
    final normalizedDetails = details.trim();
    if (normalizedDetails.length < 5 || normalizedDetails.length > 160) {
      throw ArgumentError.value(details, 'details', 'Use 5 to 160 characters.');
    }
    if (price <= 0) {
      throw ArgumentError.value(
        price,
        'price',
        'Enter a price greater than 0.',
      );
    }
    final normalizedCondition = condition.trim();
    if (normalizedCondition.isEmpty || normalizedCondition.length > 32) {
      throw ArgumentError.value(condition, 'condition', 'Choose a condition.');
    }
    final normalizedArea = area.trim();
    if (normalizedArea.length < 2 || normalizedArea.length > 80) {
      throw ArgumentError.value(area, 'area', 'Use 2 to 80 characters.');
    }
    if (imageBytes != null && imageBytes.isEmpty) {
      throw ArgumentError.value(imageBytes, 'imageBytes', 'Choose an image.');
    }
    if (contentType != null && !contentType.startsWith('image/')) {
      throw ArgumentError.value(contentType, 'contentType', 'Choose an image.');
    }
  }

  String? _contactPhoneForWrite({
    required bool contactVisible,
    required String? contactPhone,
  }) {
    if (!contactVisible) {
      return null;
    }
    if (contactPhone == null || !isValidContactPhone(contactPhone)) {
      throw ArgumentError.value(
        contactPhone,
        'contactPhone',
        'Enter a valid international phone number to share it.',
      );
    }
    return normalizeContactPhone(contactPhone);
  }

  void dispose() => _imageUploader.dispose();
}
