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
| Furniture data | Bundled sample products remain on Home. The Furniture tab shows five demo listings when Firestore is empty. Signed-in email/password users can create, edit, remove, and mark their listings as sold, with structured description, price, condition, area, photo, and opt-in contact fields. |
| Interior design | Displays a “Coming Soon” message. |
| Cart and profile | Cart is a placeholder. Signed-in users can create and edit a profile with initials, display name, account email, and optional neighborhood. The display name and neighborhood are saved to the user's private Firestore document; guest accounts cannot save profiles. |
| Checkout and payments | Not implemented. |

## Database and data storage

Cloud Firestore stores documents in the `furniture_listings` collection. Each
listing contains the owner's Firebase UID, description, price, condition, area,
status, an image download URL from Cloudinary, and a creation timestamp.
Seller phone numbers are only stored on a public listing when the seller opts
in to sharing them. If opted in, buyers can launch a call or WhatsApp message.
Cloudinary stores the image files. If the collection is empty or unavailable,
the Furniture tab shows five demo listings with Unsplash image URLs. The
`users/{uid}` collection stores each authenticated user's display name and
optional neighborhood; profile reads and writes are restricted to that user.
The bundled sample products remain in [`lib/data/products.dart`](lib/data/products.dart);
carts and orders are not stored yet.

## Authentication

Firebase Authentication is integrated for email/password sign-in, account
creation, password-reset emails, and anonymous guest sign-in. The app listens
to Firebase's auth state to switch between the sign-in screen and the home
screen. Email/password accounts can post listings; anonymous guest accounts
can view listings but cannot upload. Credentials are submitted to Firebase
Authentication; the app does not store passwords itself.

Firebase project options and Android configuration have been generated for
this project. Confirm that Email/Password and Anonymous sign-in are enabled,
create a Firestore database, configure Cloudinary as described below, and
deploy the included [`firestore.rules`](firestore.rules).

## Technology

- Flutter and Dart, with a Material 3 interface.
- The Dart SDK constraint is `^3.11.4` in [`pubspec.yaml`](pubspec.yaml).
- Android build configuration uses Gradle 9.5.0, Android Gradle Plugin 9.3.1,
  Kotlin 2.4.20, and Java 17.
- Firebase packages: `firebase_core`, `firebase_auth`, and `cloud_firestore`.
- `http` uploads photos to Cloudinary.
- `image_picker` selects listing photos from the device.
- `url_launcher` opens the seller's phone or WhatsApp action.
- Bundled sofa, bed, and dining images in `assets/images/`.

## Source layout

| Path | Purpose |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | Initializes Firebase and configures the app theme. |
| [`lib/screens/login_page.dart`](lib/screens/login_page.dart) | Sign-in, account creation, guest access, and password reset. |
| [`lib/widgets/auth_gate.dart`](lib/widgets/auth_gate.dart) | Routes according to Firebase's current authentication state. |
| [`lib/widgets/firebase_setup_page.dart`](lib/widgets/firebase_setup_page.dart) | Explains how to configure Firebase when setup is missing or fails. |
| [`lib/firebase_options.dart`](lib/firebase_options.dart) | FlutterFire-generated platform options. |
| [`lib/screens/home_page.dart`](lib/screens/home_page.dart) | Main navigation and sign-out control. |
| [`lib/screens/profile_page.dart`](lib/screens/profile_page.dart) | Profile creation and editing for signed-in users. |
| [`lib/data/user_profile_repository.dart`](lib/data/user_profile_repository.dart) | Saves and watches per-user profile documents in Firestore. |
| [`lib/models/user_profile.dart`](lib/models/user_profile.dart) | Profile data and avatar-initial helpers. |
| [`lib/screens/furniture_listings_page.dart`](lib/screens/furniture_listings_page.dart) | Firestore-backed furniture feed. |
| [`lib/screens/add_furniture_listing_page.dart`](lib/screens/add_furniture_listing_page.dart) | Photo, details, price, condition, area, and seller contact form. |
| [`lib/data/furniture_listing_repository.dart`](lib/data/furniture_listing_repository.dart) | Firestore listing and Cloudinary image URL operations. |
| [`lib/utils/seller_contact.dart`](lib/utils/seller_contact.dart) | Normalizes and validates seller phone numbers. |
| [`lib/data/cloudinary_image_uploader.dart`](lib/data/cloudinary_image_uploader.dart) | Direct unsigned photo uploads to Cloudinary. |
| [`lib/config/cloudinary_config.dart`](lib/config/cloudinary_config.dart) | Cloud name and upload preset configuration. |
| [`lib/models/furniture_listing.dart`](lib/models/furniture_listing.dart) | Firestore furniture listing model. |
| [`lib/screens/interior_design_page.dart`](lib/screens/interior_design_page.dart) | “Coming Soon” interior-design screen. |
| [`lib/models/product.dart`](lib/models/product.dart) | Product data model. |
| [`lib/data/products.dart`](lib/data/products.dart) | Hard-coded sample furniture products. |
| [`lib/widgets/`](lib/widgets/) | Reusable UI widget files. |
| [`test/widget_test.dart`](test/widget_test.dart) | Smoke test for the login screen. |
| [`test/furniture_listing_test.dart`](test/furniture_listing_test.dart) | Furniture listing model test. |
| [`test/seller_contact_test.dart`](test/seller_contact_test.dart) | Seller phone normalization and validation tests. |
| [`test/cloudinary_image_uploader_test.dart`](test/cloudinary_image_uploader_test.dart) | Cloudinary upload request tests. |

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
5. In Cloudinary, get the cloud name from the dashboard. Under **Settings →
   Upload → Upload presets**, create an unsigned preset and restrict it to
   image formats and a reasonable file size. Unsigned presets are public and
   can be abused if left unrestricted. Never put your Cloudinary API secret in
   the app.
6. In the project folder, select your Firebase project with
   `firebase use --add`, then deploy the Firestore rules:

   ```shell
   firebase deploy --only firestore:rules
   ```

### Start the app

Install Flutter and configure the required platform SDK/emulator. Create an
ignored local Cloudinary config file:

```shell
Copy-Item config\cloudinary.example.json config\cloudinary.local.json
```

Edit `config\cloudinary.local.json` with the cloud name and unsigned preset
from your Cloudinary dashboard. This file is ignored by Git. Run the app:

```shell
flutter pub get
flutter emulators
flutter emulators --launch <emulator-id>
flutter run --dart-define-from-file=config/cloudinary.local.json
```

Replace `<emulator-id>` with an ID listed by `flutter emulators`. To build a
debug APK without launching it, pass the same local config file:

```shell
flutter build apk --debug --dart-define-from-file=config/cloudinary.local.json
```

In VS Code, select **Kayra Craft (local Cloudinary)** in Run and Debug before
starting the app; that launch profile passes the local config to Flutter.

The cloud name and unsigned preset are included in the app when it is built;
they are configuration values, not secrets. Never add the Cloudinary API
secret to the app or local config file.

## Product images

The home screen uses bundled SVG placeholder illustrations for the sofa, bed,
and dining table in [`assets/images/`](assets/images/). They are sample artwork,
not product photography; replace them with suitable licensed product images
when real catalog photography is available.

## MVP roadmap

Keep the first release focused on one job: help a seller post a piece of
furniture and help a nearby buyer contact them. For the MVP, use direct
seller-buyer contact instead of building checkout, payments, or in-app chat.

### Before the first public launch

1. **Complete the listing flow.** Implemented: sellers can post a listing with
   description, price, condition, area, and one photo, then edit, remove, or
   mark their own listing as sold. Before launch, deploy the updated Firestore
   rules and verify these actions against the production project.
2. **Make contacting the seller easy.** Implemented: sellers can opt in to
   sharing an international phone number; buyers only see call and WhatsApp
   actions for listings where the seller has consented. The number is not
   stored on the public listing when sharing is off.
3. **Prepare production data and uploads.** Verify Firebase sign-in, Firestore
   rules, and the Cloudinary upload preset in the production project. Test
   posting, viewing, and removing listings. Disable the demo listings in
   production so sample items are never mistaken for real stock.
4. **Cover launch essentials.** Publish a privacy policy and support contact,
   provide a simple way to report a listing, and decide how reports and
   inappropriate posts will be handled.
5. **Test and release a small pilot.** Test the complete seller and buyer flows
   on real Android devices, including slow or failed image uploads and
   connectivity errors. Start in one service area with a small group of sellers
   before broader promotion.

### Defer until users ask for them

- Cart, checkout, payment processing, and order management.
- In-app chat, push notifications, reviews, and recommendations.
- Advanced search and filters; add basic category or price filters only when
  the number of listings makes browsing difficult.
- Interior-design services and other non-marketplace features.
