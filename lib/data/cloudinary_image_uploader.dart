import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/cloudinary_config.dart';

class CloudinaryImageUploader {
  CloudinaryImageUploader({
    String? cloudName,
    String? uploadPreset,
    http.Client? client,
  }) : _cloudName = (cloudName ?? CloudinaryConfig.cloudName).trim(),
       _uploadPreset = (uploadPreset ?? CloudinaryConfig.uploadPreset).trim(),
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  final String _cloudName;
  final String _uploadPreset;
  final http.Client _client;
  final bool _ownsClient;

  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String? contentType,
  }) async {
    if (imageBytes.isEmpty) {
      throw ArgumentError.value(imageBytes, 'imageBytes', 'Choose an image.');
    }
    if (contentType != null && !contentType.startsWith('image/')) {
      throw ArgumentError.value(contentType, 'contentType', 'Choose an image.');
    }
    if (!_isConfigured) {
      throw const CloudinaryUploadException(
        'Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET in config/cloudinary.local.json, then fully '
        'stop and rerun the app with the "Kayra Craft (local Cloudinary)" '
        'VS Code launch profile or use '
        '--dart-define-from-file=config/cloudinary.local.json.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.https('api.cloudinary.com', '/v1_1/$_cloudName/image/upload'),
    )
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'furniture_listings';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: _safeFileName(fileName),
      ),
    );

    final response = await _client.send(request);
    final body = await response.stream.bytesToString();
    final decoded = _decodeResponse(body, response.statusCode);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CloudinaryUploadException(
        _errorMessage(decoded) ??
            'Cloudinary upload failed with HTTP ${response.statusCode}.',
      );
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['secure_url'] is! String ||
        !(decoded['secure_url'] as String).startsWith(
          'https://res.cloudinary.com/',
        )) {
      throw const CloudinaryUploadException(
        'Cloudinary did not return a secure image URL.',
      );
    }

    return decoded['secure_url'] as String;
  }

  bool get _isConfigured =>
      RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(_cloudName) &&
      _uploadPreset.trim().isNotEmpty;

  Object? _decodeResponse(String body, int statusCode) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw CloudinaryUploadException(
        'Cloudinary returned an invalid response (HTTP $statusCode).',
      );
    }
  }

  String? _errorMessage(Object? response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }
    final error = response['error'];
    if (error is Map<String, dynamic> && error['message'] is String) {
      final message = error['message'] as String;
      if (message.toLowerCase().contains('unknown api key')) {
        return '$message Verify CLOUDINARY_CLOUD_NAME matches your Cloudinary '
            'account, and CLOUDINARY_UPLOAD_PRESET names an existing unsigned '
            'upload preset. Rebuild the app after updating the local config.';
      }
      return message;
    }
    return null;
  }

  String _safeFileName(String fileName) {
    final name = fileName.split(RegExp(r'[/\\]')).last.trim();
    return name.isEmpty ? 'furniture-image.jpg' : name;
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
