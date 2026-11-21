// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kayra_craft/main.dart';
import 'package:kayra_craft/screens/home_page.dart';
import 'package:kayra_craft/screens/login_page.dart';
import 'package:kayra_craft/widgets/auth_gate.dart';

void main() {
  testWidgets('Kayra Craft app loads login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KayraCraftApp());

    expect(find.text('KAYRA CRAFT'), findsOneWidget);
    expect(find.text('Furniture for beautiful homes'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('login requires a valid email and password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets(
    'account creation rejects invalid email and mismatched passwords',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'different123');
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Passwords do not match.'), findsOneWidget);
    },
  );

  testWidgets('successful account creation returns to login', (
    WidgetTester tester,
  ) async {
    final auth = _FakeFirebaseAuth();
    addTearDown(auth.dispose);
    await tester.pumpWidget(MaterialApp(home: AuthGate(auth: auth)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('CREATE ACCOUNT'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Account created. Please log in.'), findsOneWidget);
  });

  testWidgets('home shows the bundled furniture illustrations', (
    WidgetTester tester,
  ) async {
    final auth = _FakeFirebaseAuth();
    addTearDown(auth.dispose);
    await tester.pumpWidget(MaterialApp(home: HomePage(auth: auth)));
    await tester.pumpAndSettle();

    expect(find.text('Find pieces that feel like home.'), findsOneWidget);
    expect(find.text('Modern Comfort Sofa'), findsOneWidget);
    expect(find.text('Elegant King Bed'), findsOneWidget);
    expect(find.text('Wooden Dining Table'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(4));
  });

  testWidgets('password reset requires an email address', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address.'), findsOneWidget);
  });
}

class _FakeFirebaseAuth implements FirebaseAuth {
  final _authState = StreamController<User?>.broadcast(sync: true);
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _authState.stream;
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _currentUser = _FakeUser();
    _authState.add(_currentUser);
    return _FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authState.add(null);
  }

  Future<void> dispose() => _authState.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCredential implements UserCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
