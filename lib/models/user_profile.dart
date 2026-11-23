class UserProfile {
  const UserProfile({required this.displayName, this.location});

  final String displayName;
  final String? location;

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    final displayName = data['displayName'];
    if (displayName is! String || displayName.trim().isEmpty) {
      throw const FormatException('Profile display name is missing.');
    }

    final location = data['location'];
    if (location != null && location is! String) {
      throw const FormatException('Profile location must be text.');
    }

    final normalizedLocation = location is String ? location.trim() : null;
    return UserProfile(
      displayName: displayName.trim(),
      location: normalizedLocation == null || normalizedLocation.isEmpty
          ? null
          : normalizedLocation,
    );
  }

  static String initialsFor(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '';
    }

    final firstInitial = parts.first.substring(0, 1);
    if (parts.length == 1) {
      return firstInitial.toUpperCase();
    }
    return '$firstInitial${parts.last.substring(0, 1)}'.toUpperCase();
  }
}
