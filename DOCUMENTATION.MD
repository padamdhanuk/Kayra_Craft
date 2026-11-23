# Kayra Craft Contributor Guide

## What this project does

Kayra Craft is a Flutter app for browsing furniture and posting second-hand
furniture listings. Firebase Authentication handles sign-in, Cloud Firestore
stores listings and user profiles, and Cloudinary stores listing photos.

The app is an early-stage prototype. The cart and interior-design areas are
placeholders; checkout and payments are not implemented.

## How the app is organized

The main flow is:

1. `lib/main.dart` initializes Firebase and applies the app theme.
2. `lib/widgets/auth_gate.dart` listens for the current authentication state.
3. Signed-out users see `lib/screens/login_page.dart`; signed-in users see
   `lib/screens/home_page.dart`.
4. `HomePage` provides the Home, Furniture, Interior, Cart, and Profile tabs.
5. Screens use the data layer for Firestore and Cloudinary operations. Models
   represent the data returned from or written to those services.

For a small feature, start at the screen that displays it, then follow its
repository and model. Keep UI in screens/widgets, service calls in `data/`,
and shared validation or formatting in `utils/`.

## Project structure

```text
Kayra_Craft/
├── assets/
│   └── images/                Bundled sofa, bed, and dining photos
├── config/
│   ├── cloudinary.example.json
│   └── cloudinary.local.json  Local-only config; ignored by Git
├── lib/
│   ├── config/                Compile-time app configuration
│   ├── data/                  Firebase, Cloudinary, and sample data
│   ├── models/                Product, listing, and profile data types
│   ├── screens/               Full pages and feature forms
│   ├── utils/                 Shared validation and error helpers
│   ├── widgets/               Reusable UI and authentication routing
│   ├── firebase_options.dart  FlutterFire-generated platform options
│   └── main.dart              App entry point and theme
├── test/                      Widget and unit tests
├── android/, ios/, linux/,
│   macos/, web/, windows/      Flutter platform runners and configuration
├── firestore.rules            Firestore access and data validation rules
├── firebase.json              Firebase CLI configuration
├── pubspec.yaml               Dependencies and Flutter asset declarations
├── README.md                  Project status and setup overview
└── COMMANDS.md                Run, test, and build commands
```

### Key files

| File | Responsibility |
| --- | --- |
| `lib/main.dart` | Firebase initialization, app theme, and root widget. |
| `lib/widgets/auth_gate.dart` | Routes users between login and the signed-in app. |
| `lib/screens/home_page.dart` | Main navigation and home product previews. |
| `lib/screens/furniture_listings_page.dart` | Loads and displays furniture listings. |
| `lib/screens/add_furniture_listing_page.dart` | Creates or edits a listing. |
| `lib/data/furniture_listing_repository.dart` | Reads/writes Firestore listings and uploads photos. |
| `lib/data/cloudinary_image_uploader.dart` | Sends unsigned image uploads to Cloudinary. |
| `lib/models/furniture_listing.dart` | Listing fields and Firestore parsing. |
| `lib/screens/profile_page.dart` | Creates and edits the signed-in user's profile. |
| `lib/data/user_profile_repository.dart` | Reads/writes `users/{uid}` profile documents. |
| `lib/data/products.dart` | Bundled sample products shown on Home. |
| `firestore.rules` | Limits profile access to the owner and validates profile and listing writes. |

## Data and access rules

- Furniture listings are stored in the `furniture_listings` collection.
  Firestore rules allow public reads; only authenticated, non-anonymous owners
  can create, edit, or delete their own listings.
- User profiles are stored at `users/{uid}`. Users can read their own document;
  profile writes require a non-anonymous account and must match that UID.
- Listing images are uploaded to Cloudinary. Cloud name and unsigned preset
  values are build-time configuration, not API secrets.
- Anonymous users can browse but cannot post listings or save a profile.

When changing a Firestore document shape, update the model, repository,
validation, tests, and `firestore.rules` together. Deploy rules only after
reviewing the selected Firebase project.

## Making a small change

1. Find the closest screen or reusable widget under `lib/screens/` or
   `lib/widgets/`.
2. If the change reads or writes data, use or update the matching repository
   under `lib/data/` and model under `lib/models/`.
3. Add or update a focused test under `test/`.
4. For a bundled image, place it in `assets/images/` and reference its exact
   path with `Image.asset(...)`. The directory is already declared in
   `pubspec.yaml`.
5. Run the analyzer and tests before sharing the change:

   ```powershell
   flutter analyze
   flutter test
   ```

6. Review `git diff` and `git status` to ensure only intended files changed.

## Running locally

From the project root:

```powershell
flutter pub get
flutter devices
flutter run -d edge --dart-define-from-file=config/cloudinary.local.json
```

For the Android emulator, replace the last command with:

```powershell
flutter run -d emulator-5554 --dart-define-from-file=config/cloudinary.local.json
```

See `COMMANDS.md` for additional build and test commands. If the local
Cloudinary config is missing, copy `config/cloudinary.example.json` to
`config/cloudinary.local.json` and fill in the cloud name and unsigned preset.
Do not commit the local config or put a Cloudinary API secret in the app.

## Tests

- `test/widget_test.dart` covers login validation and core home-screen UI.
- `test/furniture_listing_test.dart` and
  `test/user_profile_test.dart` cover Firestore data models.
- `test/cloudinary_image_uploader_test.dart` covers upload requests and
  configuration errors.
- `test/seller_contact_test.dart` covers seller phone validation.
- `test/demo_furniture_listings_test.dart` covers the demo listing data.

