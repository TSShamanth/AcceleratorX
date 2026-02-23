# Real-Time Task Sharing App

A minimalist, real-time task management application built with Flutter and Firebase. This app features a "Workspace" aesthetic and ensures that every user has their own private, synchronized task list.

## ✨ Features

- **Real-Time Sync:** Tasks update instantly across all devices using Cloud Firestore.
- **User Authentication:** 
  - Secure Login and Sign Up.
  - "Forgot Password" email reset flow.
  - Password visibility toggle.
- **Private Workspaces:** Each user's tasks are stored in a unique subcollection (`users/{userId}/tasks`), ensuring total data privacy.
- **Workspace Aesthetic:** 
  - Typography: DM Serif Display & DM Sans.
  - Minimalist design with a custom progress tracker and filterable task views.
  - Swipe-to-delete functionality.
- **Filtering:** Quickly toggle between "All", "Active", and "Done" tasks.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Authentication & Cloud Firestore)
- **State Management:** Provider
- **Fonts:** Google Fonts (DM Serif Display, DM Sans)

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A [Firebase account](https://console.firebase.google.com/).
- [Node.js](https://nodejs.org/) (required for Firebase CLI).

### Setup Instructions

1. **Clone and Install Dependencies:**
   ```bash
   cd task_sharing_app
   flutter pub get
   ```

2. **Firebase Console Setup:**
   - Create a new Firebase project (e.g., `acceleratorx-f667f`).
   - **Authentication:** Enable the **Email/Password** sign-in provider.
   - **Firestore Database:** 
     - Create a database in your preferred region.
     - Start in "Test Mode" or apply the security rules provided below.

3. **Configure FlutterFire:**
   Install the CLI and run the configuration to link your app:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   dart pub global run flutterfire_cli:flutterfire configure --project=YOUR_PROJECT_ID
   ```

4. **Apply Firestore Security Rules:**
   Paste these rules into the "Rules" tab of your Firestore Database in the Firebase Console:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/tasks/{taskId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

## 🏃 Running the App

To launch the app on your connected device or emulator:

```bash
flutter run
```

## 📂 Project Structure

- `lib/models/task.dart`: Data model for tasks.
- `lib/services/auth_service.dart`: Firebase Authentication logic.
- `lib/services/task_service.dart`: Firestore CRUD operations and streams.
- `lib/screens/auth_screen.dart`: Login and Sign Up UI.
- `lib/main.dart`: Main application entry, state management, and Task List UI.

---
Created for the AcceleratorX Assignment.
