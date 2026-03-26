# Rumour

A Flutter-based real-time messaging application with Firebase backend integration. Built with GetX state management for efficient, reactive UI updates.

## Features

- Real-time messaging with Firestore integration
- User authentication and identity management
- Chat room management with member tracking
- Message pagination
- Persistent data with Shared Preferences

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: GetX
- **Backend**: Firebase (Firestore, Firebase Core)
- **Local Storage**: Shared Preferences
- **Utilities**: DIO (HTTP), UUID, Intl (Internationalization), Google Fonts

## Codebase Structure

lib/
├── main.dart                          # App entry point, Firebase init, offline persistence
├── firebase_options.dart              # Auto-generated Firebase config
│
└── app/
    ├── models/
    │   ├── user_identity.dart         # User identity model (userId, name, avatarUrl)
    │   └── message.dart               # Message model with Firestore mapping
    │
    ├── repositories/
    │   ├── identity_repository.dart   # Fetches/caches identity from randomuser.me
    │   ├── room_repository.dart       # Room creation, validation, member count
    │   └── message_repository.dart   # Send, load, paginate, stream messages
    │
    ├── controllers/
    │   ├── home_controller.dart       # Join/create room logic, recent rooms
    │   ├── identity_controller.dart   # Identity acknowledgement flow
    │   └── chat_controller.dart       # Messages, pagination, realtime stream
    │
    ├── screens/
    │   ├── home_screen.dart       # Join A Room screen
    │   ├── identity_screen.dart   # Name generation / acknowledgement screen
    │   └── chat_screen.dart       # Main chat screen
    │
    ├── widgets/
    │   ├── room_code_input.dart       # Custom OTP-style room code input
    │   ├── message_bubble.dart        # Chat bubble (mine vs others)
    │   └── date_separator.dart        # Date pill between messages
    │
    └── routes/        
        └── app_pages.dart             # Route to screen mapping


## Firebase Cloud Firestore data structure

firestore/
│
└── rooms/                             # Collection
    └── {roomCode}/                    # Document (e.g. "AB12CD")
        │
        ├── roomCode: string           # "AB12CD"
        ├── createdAt: timestamp       # Server timestamp
        ├── memberCount: number        # Increments on first join
        │
        └── messages/                  # Subcollection
            └── {messageId}/           # Auto-generated document
                ├── senderId: string   # UUID generated per device per room
                ├── senderName: string # Random name from randomuser.me
                ├── senderAvatar: string # Avatar URL from randomuser.me
                ├── text: string       # Message content
                └── timestamp: timestamp # FieldValue.serverTimestamp()

### Key Directories

**controllers/**
- Handles business logic and state management using GetX
- Manages real-time listeners and stream subscriptions
- Coordinates between UI and repository layers

**models/**
- Dart classes representing core data structures
- Serialization/deserialization logic for Firestore

**repo/**
- Direct Firestore interaction layer
- Query building and cloud operations
- Stream management for real-time updates

**screens/**
- Flutter widgets representing full-screen UIs
- Observes controller state for reactive updates

**widgets/**
- Reusable UI components
- Presentational logic only

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.3
- Java Development Kit (JDK) for Android
- Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
   git clone https://github.com/AnjanaJolly00/Rumour.git
   cd rumour
   ```

2. Install dependencies:
```bash
   flutter pub get
   ```

4. Run the app:
```bash
flutter run
```

## Build & Deployment

### Android APK
```bash
flutter build apk
```

**Download Latest APK**: [Download APK](https://github.com/AnjanaJolly00/Rumour/releases/latest/download/app-release.apk)

## Project Architecture

This project follows a clean architecture pattern:

1. **UI Layer** (screens, widgets) - Presents data and captures user input
2. **Business Logic Layer** (controllers) - Manages state and orchestrates operations
3. **Data Layer** (repositories, models) - Handles data operations and transformations

**State Management**: GetX provides reactive updates and dependency injection across layers.

**Real-time Updates**: Firestore streams enable live message synchronization across users.