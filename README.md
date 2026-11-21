# Kayra Craft

Kayra Craft is a Flutter mobile app prototype for a furniture and home-interior
business.

## Business idea

The concept is a digital showroom for home furniture, with a future interior
design service. The sample catalog models furniture such as sofas, beds, and
dining tables, including each item's price, description, category, and material.
The app's “Furniture” and “Interior Design” sections are intended to help
customers discover products and, eventually, design services.

## Current project status

This is an early-stage UI prototype, not a complete e-commerce application.

| Area | Current behavior |
| --- | --- |
| Login | Firebase email/password sign-in with form validation and visible errors. Requires Firebase project configuration. |
| Guest access | Uses Firebase anonymous authentication. Requires the Anonymous provider to be enabled. |
| Account creation | Creates a Firebase Authentication account, signs it out, and returns to the login form after validating email and matching passwords. |
| Password recovery | Sends a Firebase password-reset email and displays a privacy-preserving confirmation. |
| Sign out | Available from the Profile tab; returning to the signed-out state is handled by the auth-state listener. |
| Home and navigation | Shows a furniture hero, local sample illustrations, featured products, and tabs for Home, Furniture, Interior, Cart, and Profile. |
| Furniture data | Three sample products are defined in Dart code. The current Furniture tab is a placeholder and does not display this catalog. |
| Interior design | Displays a “Coming Soon” message. |
| Cart and profile | Cart is a placeholder. Profile shows the signed-in email or guest status and supports sign-out; no editable profile data is stored. |
| Checkout and payments | Not implemented. |

## Database and data storage

**No application database is currently used.** The project has no configured
remote database or local persistence layer. The three sample products are a Dart `const` list in
[`lib/data/products.dart`](lib/data/products.dart), described by the
[`Product`](lib/models/product.dart) model. Product data, cart contents, and
shopping data are not read from or saved to a database. Firebase Authentication
stores account credentials and identity, but it is not a product or orders
database.

## Authentication

Firebase Authentication is integrated for email/password sign-in, account
creation, password-reset emails, and anonymous guest sign-in. The app listens to
Firebase's auth state to switch between the sign-in screen and the home screen.
Credentials are submitted to Firebase Authentication; the app does not store
passwords itself.

Firebase project options and Android configuration have been generated for
this project. Confirm that Email/Password and Anonymous sign-in are enabled for
the project in Firebase Console before using those flows.

## Technology

- Flutter and Dart, with a Material 3 interface.
- The Dart SDK constraint is `^3.11.4` in [`pubspec.yaml`](pubspec.yaml).
- Android build configuration uses Gradle 9.5.0, Android Gradle Plugin 9.3.1,
  Kotlin 2.4.20, and Java 17.
- Firebase packages: `firebase_core` and `firebase_auth`.
- Local SVG illustration support: `flutter_svg`.
- No application database or product API is configured.

## Source layout

| Path | Purpose |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | Initializes Firebase and configures the app theme. |
| [`lib/screens/login_page.dart`](lib/screens/login_page.dart) | Sign-in, account creation, guest access, and password reset. |
| [`lib/widgets/auth_gate.dart`](lib/widgets/auth_gate.dart) | Routes according to Firebase's current authentication state. |
| [`lib/widgets/firebase_setup_page.dart`](lib/widgets/firebase_setup_page.dart) | Explains how to configure Firebase when setup is missing or fails. |
| [`lib/firebase_options.dart`](lib/firebase_options.dart) | FlutterFire-generated platform options. |
| [`lib/screens/home_page.dart`](lib/screens/home_page.dart) | Main navigation and sign-out control. |
| [`lib/screens/interior_design_page.dart`](lib/screens/interior_design_page.dart) | “Coming Soon” interior-design screen. |
| [`lib/models/product.dart`](lib/models/product.dart) | Product data model. |
| [`lib/data/products.dart`](lib/data/products.dart) | Hard-coded sample furniture products. |
| [`lib/widgets/`](lib/widgets/) | Reusable UI widget files. |
| [`test/widget_test.dart`](test/widget_test.dart) | Smoke test for the login screen. |

## Run the app

### One-time Firebase setup

1. Create a Firebase project in the Firebase Console and register the Android
   app with application ID `com.example.kayra_craft`.
2. Install and sign in to the Firebase CLI:

   ```shell
   npm install -g firebase-tools
   firebase login
   ```

3. Install FlutterFire CLI and generate platform options from the project root:

   ```shell
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Select the Firebase project and the platforms you intend to run. This
   generates or updates `lib/firebase_options.dart`.

4. In Firebase Console, open **Authentication → Sign-in method** and enable
   **Email/Password** and **Anonymous**.

### Start the app

Install Flutter and configure the required platform SDK/emulator. Then run:

```shell
flutter pub get
flutter emulators
flutter emulators --launch <emulator-id>
flutter run
```

Replace `<emulator-id>` with an ID listed by `flutter emulators`. To build a
debug APK without launching it:

```shell
flutter build apk --debug
```

## Product images

The home screen uses bundled SVG placeholder illustrations for the sofa, bed,
and dining table in [`assets/images/`](assets/images/). They are sample artwork,
not product photography; replace them with suitable licensed product images
when real catalog photography is available.

## Possible next steps

1. Add email verification and account-management features if needed.
2. Choose a database and define storage for products, user profiles, and orders.
3. Connect the Furniture screen to product data and implement product details.
4. Add cart persistence, checkout, and payment integration.
5. Implement the interior-design inquiry flow and replace placeholder tabs.
