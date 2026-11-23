import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kayra_craft/data/cloudinary_image_uploader.dart';

void main() {
  test('uploads the photo and returns Cloudinary secure URL', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://api.cloudinary.com/v1_1/test-cloud/image/upload',
      );
      final upload = request;
      expect(upload.headers['content-type'], startsWith('multipart/form-data'));
      final body = utf8.decode(upload.bodyBytes, allowMalformed: true);
      expect(body, contains('name="upload_preset"'));
      expect(body, contains('test-preset'));
      expect(body, contains('name="folder"'));
      expect(body, contains('furniture_listings'));
      expect(body, contains('filename="sofa.jpg"'));
      return http.Response(
        jsonEncode({
          'secure_url':
              'https://res.cloudinary.com/test-cloud/image/upload/sofa.jpg',
        }),
        200,
      );
    });
    final uploader = CloudinaryImageUploader(
      cloudName: 'test-cloud',
      uploadPreset: 'test-preset',
      client: client,
    );
    addTearDown(client.close);

    final url = await uploader.uploadImage(
      imageBytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'sofa.jpg',
      contentType: 'image/jpeg',
    );

    expect(url, 'https://res.cloudinary.com/test-cloud/image/upload/sofa.jpg');
  });

  test('requires Cloudinary configuration before uploading', () async {
    final client = MockClient((_) async => http.Response('', 200));
    final uploader = CloudinaryImageUploader(
      cloudName: '',
      uploadPreset: '',
      client: client,
    );
    addTearDown(client.close);

    await expectLater(
      uploader.uploadImage(
        imageBytes: Uint8List.fromList([1]),
        fileName: 'photo.jpg',
        contentType: 'image/jpeg',
      ),
      throwsA(
        isA<CloudinaryUploadException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('CLOUDINARY_CLOUD_NAME'),
            contains('CLOUDINARY_UPLOAD_PRESET'),
            contains('fully stop and rerun'),
          ),
        ),
      ),
    );
  });

  test('explains how to resolve an unknown Cloudinary API key', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': {'message': 'Unknown API key'},
        }),
        401,
      ),
    );
    final uploader = CloudinaryImageUploader(
      cloudName: 'test-cloud',
      uploadPreset: 'test-preset',
      client: client,
    );
    addTearDown(client.close);

    await expectLater(
      uploader.uploadImage(
        imageBytes: Uint8List.fromList([1]),
        fileName: 'photo.jpg',
        contentType: 'image/jpeg',
      ),
      throwsA(
        isA<CloudinaryUploadException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('Unknown API key'),
            contains('CLOUDINARY_CLOUD_NAME'),
            contains('unsigned'),
          ),
        ),
      ),
    );
  });
}
