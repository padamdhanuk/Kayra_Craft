import '../utils/seller_contact.dart';

class FurnitureListing {
  const FurnitureListing({
    required this.id,
    required this.ownerId,
    required this.details,
    required this.imageUrl,
    this.price,
    this.condition,
    this.area,
    this.status = 'available',
    this.contactPhone,
    this.contactVisible = false,
  });

  final String id;
  final String ownerId;
  final String details;
  final String imageUrl;
  final int? price;
  final String? condition;
  final String? area;
  final String status;
  final String? contactPhone;
  final bool contactVisible;

  bool get isSold => status == 'sold';

  factory FurnitureListing.fromMap(String id, Map<String, dynamic> data) {
    final price = data['price'];
    final rawContactPhone = data['contactPhone'];
    final normalizedContactPhone = rawContactPhone is String
        ? normalizeContactPhone(rawContactPhone)
        : null;
    final contactVisible =
        data['contactVisible'] == true &&
        normalizedContactPhone != null &&
        isValidContactPhone(normalizedContactPhone);
    return FurnitureListing(
      id: id,
      ownerId: data['ownerId'] as String,
      details: data['details'] as String,
      imageUrl: data['imageUrl'] as String,
      price: price is num ? price.toInt() : null,
      condition: data['condition'] is String
          ? data['condition'] as String
          : null,
      area: data['area'] is String ? data['area'] as String : null,
      status: data['status'] == 'sold' ? 'sold' : 'available',
      contactPhone: contactVisible ? normalizedContactPhone : null,
      contactVisible: contactVisible,
    );
  }
}
