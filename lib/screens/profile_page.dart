import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../data/user_profile_repository.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.auth, this.repository, super.key});

  final FirebaseAuth auth;
  final UserProfileRepository? repository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UserProfileRepository _repository =
      widget.repository ?? UserProfileRepository();

  Future<void> _editProfile(UserProfile? profile) async {
    final user = widget.auth.currentUser;
    if (user == null || user.isAnonymous) {
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _EditProfilePage(
          auth: widget.auth,
          repository: _repository,
          profile: profile,
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await widget.auth.signOut();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not sign out (${error.code}). Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: user == null
          ? const Center(child: Text('Sign in to view your profile.'))
          : user.isAnonymous
          ? _GuestProfileContent(onSignIn: _signOut)
          : StreamBuilder<UserProfile?>(
              stream: _repository.watchProfile(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load your profile: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _SavedProfileContent(
                  user: user,
                  profile: snapshot.data,
                  onEdit: () => _editProfile(snapshot.data),
                  onSignOut: _signOut,
                );
              },
            ),
    );
  }
}

class _SavedProfileContent extends StatelessWidget {
  const _SavedProfileContent({
    required this.user,
    required this.profile,
    required this.onEdit,
    required this.onSignOut,
  });

  final User user;
  final UserProfile? profile;
  final VoidCallback onEdit;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authName = user.displayName?.trim() ?? '';
    final accountName = authName.isNotEmpty
        ? authName
        : user.email?.split('@').first ?? '';
    final displayName = profile?.displayName ?? accountName;
    final initials = UserProfile.initialsFor(
      displayName.isEmpty ? 'User' : displayName,
    );
    final photoUrl = user.photoURL;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
                child: photoUrl == null
                    ? Text(
                        initials,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                profile?.displayName ?? 'Complete your profile',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? 'Email address unavailable',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              _ProfileDetail(
                icon: Icons.person_outline,
                label: 'Display name',
                value: profile?.displayName ?? 'Not set',
              ),
              const Divider(height: 1, indent: 64),
              _ProfileDetail(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email ?? 'Not available',
              ),
              const Divider(height: 1, indent: 64),
              _ProfileDetail(
                icon: Icons.location_on_outlined,
                label: 'Neighborhood',
                value: profile?.location ?? 'Optional',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onEdit,
          icon: Icon(profile == null ? Icons.person_add_alt_1 : Icons.edit),
          label: Text(profile == null ? 'Create profile' : 'Edit profile'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _GuestProfileContent extends StatelessWidget {
  const _GuestProfileContent({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Text('G', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 16),
            Text(
              'Guest account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in with an account to create a profile saved to Firebase.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onSignIn,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({
    required this.auth,
    required this.repository,
    required this.profile,
  });

  final FirebaseAuth auth;
  final UserProfileRepository repository;
  final UserProfile? profile;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text:
          widget.profile?.displayName ??
          widget.auth.currentUser?.displayName ??
          '',
    );
    _locationController = TextEditingController(
      text: widget.profile?.location ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) {
      return 'Enter at least 2 characters.';
    }
    if (name.length > 60) {
      return 'Use no more than 60 characters.';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if ((value?.trim().length ?? 0) > 80) {
      return 'Use no more than 80 characters.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = widget.auth.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() => _errorMessage = 'Sign in with an account to save a profile.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await widget.repository.saveProfile(
        userId: user.uid,
        displayName: _nameController.text,
        location: _locationController.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved.')));
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not save your profile: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Create profile' : 'Edit profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Add a few details so buyers know who they are connecting with.',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Display name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Neighborhood (optional)',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: _validateLocation,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save profile'),
            ),
          ],
        ),
      ),
    );
  }
}