# Curora — Xcode Setup Guide

## Prerequisites
- Xcode 15+ (iOS 17 target)
- Firebase account at console.firebase.google.com
- Google Fonts: Cormorant Garamond + DM Sans

---

## Step 1 — Create Xcode Project
1. Open Xcode → New Project → **iOS App**
2. Product Name: `Curora`
3. Interface: **SwiftUI**
4. Language: **Swift**
5. Minimum Deployment: **iOS 17.0**

---

## Step 2 — Add Source Files
Drag the entire `Curora/` folder from this project into your Xcode project navigator. When prompted:
- ✅ Copy items if needed
- ✅ Create groups
- ✅ Add to target: Curora

Your group structure in Xcode should match:
```
Curora/
  ├── curoraApp.swift
  ├── ContentView.swift
  ├── Theme.swift
  ├── Models/
  │   ├── Place.swift
  │   ├── AppUser.swift
  │   └── Board.swift
  ├── Resources/
  │   └── Colors.swift
  ├── Services/
  │   ├── FirestoreService.swift
  │   └── StorageService.swift
  ├── ViewModels/
  │   ├── AuthViewModel.swift
  │   └── PlacesViewModel.swift
  └── Views/
      ├── Auth/           (LoginView.swift)
      ├── Onboarding/     (SplashView, ConnectAccountsView, ImportingView)
      ├── Main/           (MainTabView.swift)
      ├── Home/           (HomeView.swift)
      ├── Board/          (CityBoardView.swift, PlaceDetailView.swift)
      ├── Search/         (SearchView.swift)
      ├── Trip/           (PlanTripView.swift)
      ├── Profile/        (ProfileView.swift)
      └── Add/            (AddPlaceView.swift)
```

---

## Step 3 — Firebase Setup

### 3a. Create Firebase Project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** → name it `Curora`
3. Skip Google Analytics (optional)

### 3b. Add iOS App
1. In Firebase console → **Project Overview** → iOS icon (+)
2. Bundle ID: match your Xcode bundle ID (e.g. `com.yourname.curora`)
3. Download **GoogleService-Info.plist**
4. Drag it into Xcode (root of project, ✅ Add to target)

### 3c. Enable Firebase Services
In Firebase console, enable:
- **Authentication** → Sign-in method → Email/Password ✅
- **Firestore Database** → Create database → Start in **test mode**
- **Storage** → Get started → Start in **test mode**

### 3d. Firestore Security Rules (after testing, before submission)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/places/{placeId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## Step 4 — Install Firebase SDK via Swift Package Manager

1. In Xcode → File → **Add Package Dependencies**
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select these packages:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseStorage`
4. Click **Add Package**

---

## Step 5 — Install Custom Fonts

### Download fonts (free on Google Fonts)
- [Cormorant Garamond](https://fonts.google.com/specimen/Cormorant+Garamond) — download all weights
- [DM Sans](https://fonts.google.com/specimen/DM+Sans) — download Light, Regular, Medium

### Add to Xcode
1. Drag all `.ttf` files into your Xcode project (create a `Fonts/` group)
2. Make sure **Add to target: Curora** is checked
3. In `Info.plist`, add key **Fonts provided by application** (array), then add each filename:
   ```
   CormorantGaramond-Light.ttf
   CormorantGaramond-LightItalic.ttf
   CormorantGaramond-Medium.ttf
   CormorantGaramond-SemiBold.ttf
   DMSans-Light.ttf
   DMSans-Regular.ttf
   DMSans-Medium.ttf
   ```

> ⚡ **If you skip this step**, the app still works — iOS falls back to system fonts automatically.

---

## Step 6 — PhotosUI Permission

In `Info.plist`, add:
- Key: `NSPhotoLibraryUsageDescription`
- Value: `Curora uses your photos to add images to saved places.`

---

## Step 7 — Build & Run

1. Select your iPhone or Simulator
2. Press **⌘R** to build
3. First launch: Splash → Sign up → Connect Accounts → Importing → Home

---

## App Flow Summary

```
First Launch:  Splash → LoginView (Sign Up) → ConnectAccounts → Importing → MainApp
Return User:   LoginView (Sign In) → MainApp (directly)
```

**MainTabView tabs:**
| Tab | Screen |
|-----|--------|
| 📋 Boards | Home — city boards overview |
| 🔍 Search | Search + filter all places |
| ➕ (center) | Add Place — manual or paste link |
| 🗺 Trip | Trip planner with itinerary |
| 👤 Profile | Stats, breakdown, sign out |

---

## Firestore Data Structure

```
/users/{userId}/places/{placeId}
  - id:        String
  - name:      String
  - city:      String
  - country:   String
  - category:  String
  - vibe:      String
  - sourceURL: String
  - imageURL:  String  (Firebase Storage URL)
  - notes:     String
  - visited:   Bool
  - rating:    Double?
  - savedAt:   Timestamp
  - userId:    String
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Color(hex:)` redeclaration error | Delete `Resources/Colors.swift` if you added the old version |
| Firebase not found | Ensure `GoogleService-Info.plist` is in the project root and added to target |
| Fonts not loading | Check `Info.plist` has exact filenames including `.ttf` extension |
| Firestore permission denied | Enable test mode rules in Firebase console |

---

*Built with SwiftUI + Firebase — Curora, 2026*
