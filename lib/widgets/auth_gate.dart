import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({required this.auth, super.key});

  final FirebaseAuth auth;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _accountCreationInProgress = false;
  late Stream<User?> _authStateChanges;

  @override
  void initState() {
    super.initState();
    _authStateChanges = widget.auth.authStateChanges();
  }

  @override
  void didUpdateWidget(covariant AuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.auth != widget.auth) {
      _authStateChanges = widget.auth.authStateChanges();
    }
  }

  void _updateAccountCreationState(bool inProgress) {
    if (_accountCreationInProgress != inProgress) {
      // When account creation starts, freeze the last known user as null
      // so the stream cannot route to HomePage during the process.
      setState(() {
        _accountCreationInProgress = inProgress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to check your sign-in status: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // While account creation is in progress, ignore stream updates
        // so the temporary signed-in state never routes to HomePage.
        final user = _accountCreationInProgress ? null : snapshot.data;

        if (user == null) {
          return LoginPage(
            auth: widget.auth,
            onAccountCreationInProgressChanged: _updateAccountCreationState,
          );
        }

        return HomePage(auth: widget.auth);
      },
    );
  }
}
