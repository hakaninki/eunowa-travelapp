# EUNOWA (travelapp)

A Flutter + Firebase social travel app where users share **photo + description + location** and interact via **likes, comments, follows, notifications, map**, and **direct messages (1:1 chat)**. Built with **Clean Architecture** and **Riverpod**.

---

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Data Model](#data-model)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Firestore Rules](#firestore-rules)
- [Recommended Indexes](#recommended-indexes)
- [Run](#run)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Roadmap](#roadmap)

---

## Features
- **Auth:** Email/Password with Auth Gate
- **Feed:** Realtime sliver feed, like/unlike, comments
- **Profiles:** Avatar, bio, posts grid, followers/following lists, edit profile
- **Notifications:** Like / comment / follow, unread badge, mark-as-read
- **Map:** `flutter_map` (OpenStreetMap), markers from post coordinates (lat/lng)
- **Search:** Case-insensitive username search with simple debouncing
- **Messaging:** 1:1 chat (deterministic `cid`), unread counts, read receipts (✓ / ✓✓)
- **Caching & UX:** Disk-cached images, placeholders, error fallbacks
- **Clean Code:** Small services/controllers, Riverpod providers, strict Firestore rules

---

## Tech Stack
- **Flutter** (Dart) + **Riverpod**
- **Firebase:** Authentication, Cloud Firestore
- **Cloudinary:** Unsigned image uploads
- **OpenStreetMap / Nominatim:** Geocoding autocomplete
- **flutter_map:** OSM tiles
- **cached_network_image:** On-device image cache

---

## Architecture
Clean, layered:
- **presentation** (UI widgets/pages)
- **application** (controllers/state)
- **core** (models/constants/utils/widgets)
- **infrastructure/services** (Firestore/Cloudinary/Geocoding clients)

---

## Directory Structure
-lib/
 - core/
   - *constants/ # collections, config, colors, images
   - *models/ # PostModel, UserModel, CommentModel, ...
   - *services/
   - *geocoding/ # Nominatim client/provider
   - *theme/ # app_theme.dart
   - *utils/ # firestore_date_utils.dart
   - *widgets/ # shared widgets
 - features/
   - *auth/ # pages, widgets, providers, services
   - *home/ # sliver feed + post card + search
   - *main/ # main nav providers/pages
   - *map/ # map page, markers, providers
   - *notifications/ # models, provider, service, UI
   - *post/ # controllers, providers, services, UI
   - *profile/ # header, grid, edit profile
   - *splash/ # splash_page.dart
   - *user/ # follow system (pages/providers/services)
   - *chat/ # conversations, chat page, providers, service
   - *firebase_options.dart
 - main.dart



---

## Data Model
```markdown
**users/{uid}**
- `username`, `username_lc`, `photoUrl`, `bio`, `createdAt`
- Subcollections:
  - `followers/{followerUid}`
  - `following/{followingUid}`

**posts/{postId}**
- `uid`, `username`, `imageUrl`, `description`, `location`, `lat?`, `lng?`, `createdAt`
- Subcollections:
  - `likes/{userId}`
  - `comments/{commentId}`

**notifications/{userId}/items/{notifId}**
- `type` ∈ {`like`, `comment`, `follow`}
- `fromUid`, `fromUsername?`, `postId?`, `commentText?`, `read`, `createdAt`

**conversations/{cid}** (`cid = min(uidA,uidB) + '_' + max(uidA,uidB)`)
- `participants` = [`uidA`, `uidB`], `lastMessage`, `lastMessageAt`, per-user unread counters
- Subcollection `messages/{mid}`: `fromUid`, `text`, `createdAt`, `readBy: [uid]`
```
---

## Prerequisites
- Flutter 3.x+
- A Firebase project with:
  - **Authentication → Email/Password** enabled
  - **Cloud Firestore** enabled
- Cloudinary account with an **unsigned upload preset**
- Internet access for OSM tiles / Nominatim

---

## Setup

1) **Clone & install**
```bash
git clone https://github.com/hakaninki/travelapp.git
cd travelapp
flutter pub get
```
2) **Connect Firebase**

- Add Android/iOS apps in Firebase Console.

- Download google-services.json (Android) / GoogleService-Info.plist (iOS).

- Optionally run:

```bash
flutterfire configure
```
This creates/updates lib/firebase_options.dart.

3) **App configuration**
Create/update lib/core/constants/app_config.dart:

```dart
class AppConfig {
  // Cloudinary
  static const cloudName = 'YOUR_CLOUD_NAME';
  static const unsignedPreset = 'YOUR_UNSIGNED_PRESET';

  // Geocoding (Nominatim)
  static const nominatimBase = 'https://nominatim.openstreetmap.org';
  static const userAgent = 'com.example.travel_app'; // use your package id
}
```
4) **Android manifest (network)**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```
---
## Firestore Rules
Copy into Firebase Console → Firestore → Rules:

```pgsql
// rules_version = '2';
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // USERS
    match /users/{uid} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == uid;

      match /followers/{followerUid} {
        allow read: if true;
        allow create, delete: if request.auth != null
          && request.auth.uid == followerUid;
        allow update: if false;
      }

      match /following/{followingUid} {
        allow read: if true;
        allow create, delete: if request.auth != null
          && request.auth.uid == uid;
        allow update: if false;
      }
    }

    // POSTS
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;

      // Only owner can update, except commentCount-only updates
      allow update: if request.auth != null && (
        (
          request.resource.data.diff(resource.data).changedKeys().hasOnly(['commentCount'])
          && request.resource.data.get('commentCount') is int
        )
        || (request.auth.uid == resource.data.uid)
      );

      allow delete: if request.auth != null
        && request.auth.uid == resource.data.uid;

      match /likes/{userId} {
        allow read: if true;
        allow create, delete: if request.auth != null
          && request.auth.uid == userId;
        allow update: if false;
      }

      match /comments/{commentId} {
        allow read: if true;

        allow create: if request.auth != null
          && request.resource.data.userId == request.auth.uid
          && request.resource.data.text is string
          && request.resource.data.text.size() > 0
          && request.resource.data.text.size() <= 2000;

        allow delete: if request.auth != null
          && resource.data.userId == request.auth.uid;

        allow update: if false;
      }
    }

    // NOTIFICATIONS
    match /notifications/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;

      match /items/{notifId} {
        // Only creator writes
        allow create: if request.auth != null
          && request.resource.data.fromUid == request.auth.uid;

        // Only owner toggles read
        allow update: if request.auth != null
          && request.auth.uid == userId
          && request.resource.data.diff(resource.data).changedKeys().hasOnly(['read'])
          && request.resource.data.read is bool;

        allow read: if request.auth != null && request.auth.uid == userId;
        allow delete: if false;
      }
    }

    // CONVERSATIONS & MESSAGES
    match /conversations/{cid} {
      allow read, write: if request.auth != null
        && request.resource.data.participants is list
        && request.auth.uid in request.resource.data.participants;

      match /messages/{mid} {
        allow read: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/conversations/$(cid)).data.participants;

        // Sender writes; participants may update readBy
        allow create: if request.auth != null
          && request.auth.uid == request.resource.data.fromUid;
        allow update: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/conversations/$(cid)).data.participants;
        allow delete: if request.auth != null
          && request.auth.uid == resource.data.fromUid;
      }
    }
  }
}
```
---

## Recommended Indexes
 Create in Firestore → Indexes:

* posts: orderBy createdAt desc

* posts with filter uid == ? + orderBy createdAt desc (composite)

* notifications/{uid}/items: where read == false

* conversations: array-contains participants + orderBy lastMessageAt desc (composite)

* messages: orderBy createdAt asc
---

## Run
```bash
flutter run -d chrome   # web (quick check)
flutter run             # device/emulator
```
---
## Troubleshooting
* Permission denied: Ensure you are authenticated, rules are published, and conversations/{cid}.participants includes both users. cid must be min(uidA, uidB) + '_' + max(uidA, uidB).

* Images not refreshing after change: Bump URL (query param) or adjust cache manager/stale period.

* Nominatim 429 / blocked: Set a proper userAgent and debounce queries.
---

## Contributing
* Branch from main using feature/<short-name>.

* Keep PRs small and focused; add screenshots for UI changes.

* Follow these guidelines:

  * Keep controllers/services small and testable.

  * UI layer has no direct Firestore calls.

  * Prefer Streams for realtime; avoid side-effects in build.

  * Reuse providers; avoid duplicate queries.

* Before pushing:

```bash
flutter analyze
flutter test
```
---

## Roadmap
* Post filters (nearby / recent), map cluster markers

* Offline-first (Firestore cache) & image prefetch

* Push notifications (FCM) for likes/comments/follows/messages

* Moderation (report/delete) & blocking

* Analytics + Crashlytics instrumentation
