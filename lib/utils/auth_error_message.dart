import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Enter a valid email address.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'The email or password is incorrect.';
    case 'email-already-in-use':
      return 'An account already exists for this email.';
    case 'weak-password':
      return 'Choose a stronger password.';
    case 'operation-not-allowed':
      return 'This sign-in method is disabled in Firebase Console.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait and try again.';
    case 'network-request-failed':
      return 'Could not connect. Check your internet connection.';
    default:
      return 'Authentication failed (${error.code}). Please try again.';
  }
}
