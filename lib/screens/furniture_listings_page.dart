import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/demo_furniture_listings.dart';
import '../data/furniture_listing_repository.dart';
import '../models/furniture_listing.dart';
import '../utils/seller_contact.dart';
import 'add_furniture_listing_page.dart';

class FurnitureListingsPage extends StatefulWidget {
  const FurnitureListingsPage({required this.auth, super.key});

  final FirebaseAuth auth;

  @override
  State<FurnitureListingsPage> createState() => _FurnitureListingsPageState();
}

class _FurnitureListingsPageState extends State<FurnitureListingsPage> {
  final _repository = FurnitureListingRepository();
  late Stream<List<FurnitureListing>> _listings;

  @override
  void initState() {
    super.initState();
    _listings = _repository.watchListings();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() => _listings = _repository.watchListings());
  }

  Future<void> _openPostForm() async {
    final posted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddFurnitureListingPage(auth: widget.auth, repository: _repository),
      ),
    );
    if (posted == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Furniture posted.')));
    }
  }

  Future<void> _openEditForm(FurnitureListing listing) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddFurnitureListingPage(
          auth: widget.auth,
          repository: _repository,
          listing: listing,
        ),
      ),
    );
    if (updated == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing updated.')));
    }
  }

  Future<void> _markAsSold(FurnitureListing listing) async {
    try {
      await _repository.markListingSold(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing marked as sold.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not mark listing as sold: $error')),
        );
      }
    }
  }

  Future<void> _confirmDelete(FurnitureListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove listing?'),
        content: const Text('This listing will no longer appear to buyers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await _repository.deleteListing(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Listing removed.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove listing: $error')),
        );
      }
    }
  }

  Future<void> _contactSeller(
    FurnitureListing listing, {
    required bool useWhatsApp,
  }) async {
    final phone = listing.contactPhone;
    if (!listing.contactVisible || phone == null) {
      return;
    }

    final normalizedPhone = normalizeContactPhone(phone);
    final uri = useWhatsApp
        ? Uri.https('wa.me', '/${normalizedPhone.substring(1)}', {
            'text': 'Hi, I am interested in ${listing.details}.',
          })
        : Uri(scheme: 'tel', path: normalizedPhone);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No app is available for this action.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the contact app: $error')),
        );
      }
    }
  }

  Future<void> _signInToPost() async {
    try {
      await widget.auth.signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not sign out (${error.code}).')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser;
    final canPost = user != null && !user.isAnonymous;

    return Scaffold(
      appBar: AppBar(title: const Text('Furniture')),
      floatingActionButton: canPost
          ? FloatingActionButton.extended(
              onPressed: _openPostForm,
              icon: const Icon(Icons.add),
              label: const Text('Post furniture'),
            )
          : null,
      body: Column(
        children: [
          if (!canPost)
            MaterialBanner(
              content: const Text('Sign in with email to post furniture.'),
              actions: [
                TextButton(
                  onPressed: _signInToPost,
                  child: const Text('SIGN IN'),
                ),
              ],
            ),
          Expanded(
            child: StreamBuilder<List<FurnitureListing>>(
              stream: _listings,
              builder: (context, snapshot) {
                final remoteListings = snapshot.data ?? const [];
                final listings = remoteListings.isEmpty
                    ? demoFurnitureListings
                    : remoteListings;
                if (listings.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No furniture listed yet. Be the first to post!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: listings.length + (snapshot.hasError ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (snapshot.hasError && index == 0) {
                      return _ListingsError(
                        error: snapshot.error!,
                        onRetry: _reload,
                      );
                    }
                    final listingIndex = snapshot.hasError ? index - 1 : index;
                    final listing = listings[listingIndex];
                    final isOwner = canPost && listing.ownerId == user.uid;
                    return _FurnitureListingCard(
                      listing: listing,
                      canManage: isOwner,
                      onEdit: () => _openEditForm(listing),
                      onMarkSold: () => _markAsSold(listing),
                      onDelete: () => _confirmDelete(listing),
                      onCallSeller: () =>
                          _contactSeller(listing, useWhatsApp: false),
                      onWhatsAppSeller: () =>
                          _contactSeller(listing, useWhatsApp: true),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FurnitureListingCard extends StatelessWidget {
  const _FurnitureListingCard({
    required this.listing,
    required this.canManage,
    required this.onEdit,
    required this.onMarkSold,
    required this.onDelete,
    required this.onCallSeller,
    required this.onWhatsAppSeller,
  });

  final FurnitureListing listing;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onMarkSold;
  final VoidCallback onDelete;
  final VoidCallback onCallSeller;
  final VoidCallback onWhatsAppSeller;

  @override
  Widget build(BuildContext context) {
    final metadata = [
      if (listing.condition != null && listing.condition!.isNotEmpty)
        listing.condition!,
      if (listing.area != null && listing.area!.isNotEmpty) listing.area!,
    ].join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  listing.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(
                        color: Color(0xFFF2ECE5),
                        child: Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                ),
                if (listing.isSold)
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Chip(label: Text('SOLD')),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.details,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (canManage)
                      PopupMenuButton<_ListingAction>(
                        onSelected: (action) {
                          switch (action) {
                            case _ListingAction.edit:
                              onEdit();
                            case _ListingAction.markSold:
                              onMarkSold();
                            case _ListingAction.delete:
                              onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: _ListingAction.edit,
                            child: Text('Edit'),
                          ),
                          if (!listing.isSold)
                            const PopupMenuItem(
                              value: _ListingAction.markSold,
                              child: Text('Mark as sold'),
                            ),
                          const PopupMenuItem(
                            value: _ListingAction.delete,
                            child: Text('Remove'),
                          ),
                        ],
                      ),
                  ],
                ),
                if (listing.price != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '₹${listing.price}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(metadata, style: Theme.of(context).textTheme.bodySmall),
                ],
                if (listing.contactVisible && listing.contactPhone != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onCallSeller,
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Call seller'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onWhatsAppSeller,
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('WhatsApp'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ListingAction { edit, markSold, delete }

class _ListingsError extends StatelessWidget {
  const _ListingsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Could not load live listings. Showing demo furniture instead.',
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry live listings'),
            ),
          ],
        ),
      ),
    );
  }
}
