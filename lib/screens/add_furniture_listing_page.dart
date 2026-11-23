import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../data/furniture_listing_repository.dart';
import '../models/furniture_listing.dart';
import '../utils/seller_contact.dart';

class AddFurnitureListingPage extends StatefulWidget {
  const AddFurnitureListingPage({
    required this.auth,
    required this.repository,
    this.listing,
    super.key,
  });

  final FirebaseAuth auth;
  final FurnitureListingRepository repository;
  final FurnitureListing? listing;

  @override
  State<AddFurnitureListingPage> createState() =>
      _AddFurnitureListingPageState();
}

class _AddFurnitureListingPageState extends State<AddFurnitureListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _imagePicker = ImagePicker();
  static const _conditions = ['New', 'Like new', 'Good', 'Fair'];
  late String _condition;
  late bool _contactVisible;
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _imageContentType;
  bool _isPickingImage = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _detailsController.text = listing?.details ?? '';
    _priceController.text = listing?.price?.toString() ?? '';
    _areaController.text = listing?.area ?? '';
    _contactPhoneController.text = listing?.contactPhone ?? '';
    _condition = _conditions.contains(listing?.condition)
        ? listing!.condition!
        : 'Good';
    _contactVisible = listing?.contactVisible ?? false;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _errorMessage = null;
    });
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        throw const FormatException('The selected image is empty.');
      }
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _imageFileName = image.name;
          _imageContentType = image.mimeType ?? _contentTypeFor(image.name);
        });
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not open your photos: $error');
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Could not read the selected photo: $error',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  String? _contentTypeFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      _ => null,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final listing = widget.listing;
    if (listing == null && _imageBytes == null) {
      setState(() => _errorMessage = 'Choose a furniture photo to continue.');
      return;
    }
    final user = widget.auth.currentUser;
    if (user == null ||
        user.isAnonymous ||
        (listing != null && listing.ownerId != user.uid)) {
      setState(
        () => _errorMessage = 'Sign in as the listing owner to continue.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final price = int.parse(_priceController.text.trim());
      if (listing == null) {
        await widget.repository.createListing(
          ownerId: user.uid,
          details: _detailsController.text,
          price: price,
          condition: _condition,
          area: _areaController.text,
          contactVisible: _contactVisible,
          contactPhone: _contactVisible ? _contactPhoneController.text : null,
          imageBytes: _imageBytes!,
          fileName: _imageFileName ?? 'furniture-image.jpg',
          contentType: _imageContentType,
        );
      } else {
        await widget.repository.updateListing(
          listing: listing,
          details: _detailsController.text,
          price: price,
          condition: _condition,
          area: _areaController.text,
          contactVisible: _contactVisible,
          contactPhone: _contactVisible ? _contactPhoneController.text : null,
          imageBytes: _imageBytes,
          fileName: _imageFileName,
          contentType: _imageContentType,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not save listing: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = widget.listing;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing == null ? 'Post furniture' : 'Edit listing'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Add a photo, description, price, condition, and area.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _isPickingImage || _isSaving ? null : _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : listing != null
                    ? Image.network(
                        listing.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      )
                    : Center(
                        child: _isPickingImage
                            ? const CircularProgressIndicator()
                            : const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 36),
                                  SizedBox(height: 8),
                                  Text('Choose furniture photo'),
                                ],
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _detailsController,
                    maxLines: 3,
                    maxLength: 160,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Item description',
                      hintText: 'e.g. Wooden 4-seater dining table',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final details = value?.trim() ?? '';
                      if (details.length < 5) {
                        return 'Enter at least 5 characters.';
                      }
                      if (details.length > 160) {
                        return 'Use no more than 160 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price = int.tryParse(value?.trim() ?? '');
                      if (price == null || price <= 0) {
                        return 'Enter a price greater than 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _condition,
                    decoration: const InputDecoration(
                      labelText: 'Condition',
                      border: OutlineInputBorder(),
                    ),
                    items: _conditions
                        .map(
                          (condition) => DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          ),
                        )
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _condition = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _areaController,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Area or neighborhood',
                      hintText: 'e.g. Indiranagar, Bengaluru',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final area = value?.trim() ?? '';
                      if (area.length < 2) {
                        return 'Enter an area or neighborhood.';
                      }
                      if (area.length > 80) {
                        return 'Use no more than 80 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+91 98765 43210',
                      helperText:
                          'Use an international number with country code.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_contactVisible) {
                        return null;
                      }
                      final phone = value?.trim() ?? '';
                      if (!isValidContactPhone(phone)) {
                        return 'Enter a valid number such as +91 98765 43210.';
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _contactVisible,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() => _contactVisible = value ?? false);
                          },
                    title: const Text('Share my number with buyers'),
                    subtitle: const Text(
                      'Your number will be public on this listing for calls '
                      'and WhatsApp. Uncheck to hide and remove it.',
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSaving || _isPickingImage ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(listing == null ? 'Post listing' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
