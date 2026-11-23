import 'package:material_ui/material_ui.dart';

class FirebaseSetupPage extends StatelessWidget {
  const FirebaseSetupPage({this.errorMessage, super.key});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase setup required')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.cloud_off_outlined, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Connect a Firebase project to use sign-in.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            SelectableText('Firebase initialization failed: $errorMessage'),
          ],
          const SizedBox(height: 24),
          const Text(
            'From the project root:\n'
            '1. Create or select a project in Firebase Console.\n'
            '2. Install and sign in to the Firebase CLI and FlutterFire CLI.\n'
            '3. Run `flutterfire configure` and select this app.\n'
            '4. In Firebase Console, enable Email/Password and Anonymous '
            'sign-in providers.\n'
            '5. Restart the app.',
          ),
        ],
      ),
    );
  }
}
