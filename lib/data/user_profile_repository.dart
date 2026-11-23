import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<UserProfile?> watchProfile(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserProfile.fromMap(data);
    });
  }

  Future<void> saveProfile({
    required String userId,
    required String displayName,
    String? location,
  }) async {
    final normalizedName = displayName.trim();
    if (userId.isEmpty) {
      throw ArgumentError.value(
        userId,
        'userId',
        'A signed-in user is required.',
      );
    }
    if (normalizedName.length < 2 || normalizedName.length > 60) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'Use 2 to 60 characters.',
      );
    }

    final normalizedLocation = location?.trim();
    if (normalizedLocation != null && normalizedLocation.length > 80) {
      throw ArgumentError.value(
        location,
        'location',
        'Use no more than 80 characters.',
      );
    }
    final optionalLocation =
        normalizedLocation == null || normalizedLocation.isEmpty
        ? null
        : normalizedLocation;

    await _users.doc(userId).set({
      'displayName': normalizedName,
      'location': ?optionalLocation,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
