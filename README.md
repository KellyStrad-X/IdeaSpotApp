# IdeaSpot

> Capture and expand your creative ideas with voice and AI

IdeaSpot is an iOS app that lets you quickly capture ideas via voice recording, with real-time transcription and AI-powered expansion using Claude by Anthropic.

## Features

- **Voice Recording** - Quick voice capture with live transcription
- **AI Expansion** - Claude AI expands your raw ideas into structured insights
- **Smart Organization** - Ideas grouped by date with search and favorites
- **Native Design** - Clean, Apple HIG-compliant interface
- **Secure Sync** - Firebase backend with Apple Sign-In authentication

## Tech Stack

### iOS App
- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Native iOS 17+ data persistence
- **Speech Framework** - Native voice recognition
- **iOS 17+** - Minimum deployment target

### Backend
- **Firebase Auth** - Apple Sign-In authentication
- **Firebase Firestore** - Cloud database for sync
- **Firebase Functions** - Serverless AI processing
- **Anthropic Claude** - AI idea expansion

## Project Structure

```
IdeaSpot/
├── Models/               # SwiftData models (Idea, AIExpansion)
├── Views/                # SwiftUI views (List, Detail, Recording, Settings)
├── ViewModels/           # MVVM view models
├── Components/           # Reusable UI components (Cards, Buttons)
├── Services/             # Business logic (Speech, Firebase)
└── IdeaSpotApp.swift     # App entry point
```

## Getting Started

### Prerequisites

- macOS with Xcode 15+
- iOS 17+ device or simulator
- Apple Developer Account (for TestFlight/App Store)
- Firebase project
- Anthropic API key

### Setup

See [SETUP.md](./IdeaSpot/SETUP.md) for detailed setup instructions.

**Quick Start:**

1. Open `IdeaSpot.xcodeproj` in Xcode
2. Add Firebase and BottomSheet package dependencies
3. Download and add `GoogleService-Info.plist` from Firebase Console
4. Add privacy permissions to Info.plist
5. Deploy the Firebase Cloud Function
6. Build and run

## Design Philosophy

IdeaSpot follows strict design standards to avoid "AI-generated" aesthetics:

- **Native First** - Follows Apple Human Interface Guidelines
- **Restraint Over Flash** - Clean, simple designs that age well
- **Functional Before Decorative** - Every element serves a purpose

See [UI-Quality-Standards.md](./UI-Quality-Standards.md) for full guidelines.

## Development Status

### Completed ✅
- [x] SwiftData models
- [x] MVVM architecture
- [x] Core UI views and components
- [x] Voice recording service
- [x] Firebase integration structure
- [x] Native design system

### To Do 📋
- [ ] Add Firebase packages and configure
- [ ] Deploy Cloud Function for AI expansion
- [ ] Implement Apple Sign-In
- [ ] Add app icon and branding
- [ ] Set up Info.plist permissions
- [ ] Test voice recording flow
- [ ] Test AI expansion
- [ ] Add loading states and error handling polish
- [ ] TestFlight distribution
- [ ] App Store submission

## Firebase Cloud Function

The AI expansion happens server-side via a Firebase Cloud Function:

```javascript
exports.expandIdea = functions.https.onCall(async (data, context) => {
  // Authenticate user
  // Call Claude API with transcript
  // Return structured expansion
});
```

This keeps API keys secure and allows easy model/prompt updates without app updates.

## Architecture Decisions

### Why SwiftData over Core Data?
- iOS 17+ target allows modern SwiftData
- Cleaner API, less boilerplate
- Better SwiftUI integration

### Why Firebase over Custom Backend?
- Faster MVP development
- Built-in auth with Apple Sign-In
- Managed infrastructure
- Easy Cloud Functions for AI calls

### Why Cloud Function vs Direct API Call?
- Keeps Anthropic API key secure (server-side only)
- Allows prompt iteration without app updates
- Centralized usage tracking and rate limiting

## Contributing

This is a personal project, but feedback and suggestions are welcome via issues.

## License

Private - All rights reserved

## Contact

Kelly Stradley - [Your contact info]

---

Built with ❤️ using SwiftUI and Claude AI
