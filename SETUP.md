# IdeaSpot - Setup Instructions

This document outlines the manual steps needed to complete the project setup in Xcode.

## 1. Add Package Dependencies

Open the Xcode project and add the following Swift Package Manager dependencies:

### Required Packages

1. **Firebase iOS SDK**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: Latest (10.0.0+)
   - Select these products:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseFunctions
     - FirebaseCore

**Note:** No other packages needed! The app uses native SwiftUI presentation modifiers.

### How to Add Packages

1. In Xcode, select your project in the navigator
2. Select the "IdeaSpot" target
3. Go to the "Package Dependencies" tab
4. Click the "+" button
5. Enter the package URL
6. Click "Add Package"
7. Select the required products
8. Click "Add Package" again

---

## 2. Configure Info.plist

Add the following privacy permission keys to your Info.plist:

### Required Privacy Permissions

Add these entries to `Info.plist` (Right-click on Info.plist → Open As → Source Code):

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>IdeaSpot needs access to speech recognition to transcribe your voice ideas.</string>

<key>NSMicrophoneUsageDescription</key>
<string>IdeaSpot needs access to your microphone to record your voice ideas.</string>
```

### How to Add in Xcode UI

1. Select the IdeaSpot project in the navigator
2. Select the "IdeaSpot" target
3. Go to the "Info" tab
4. Hover over any row and click the "+" button
5. Add "Privacy - Speech Recognition Usage Description"
   - Value: "IdeaSpot needs access to speech recognition to transcribe your voice ideas."
6. Add "Privacy - Microphone Usage Description"
   - Value: "IdeaSpot needs access to your microphone to record your voice ideas."

---

## 3. Add Files to Xcode Project

All the Swift files have been created in the proper directory structure, but they need to be added to the Xcode project:

### Directory Structure
```
IdeaSpot/
├── Models/
│   └── Idea.swift
├── Views/
│   ├── ContentView.swift
│   ├── IdeasListView.swift
│   ├── IdeaDetailView.swift
│   ├── RecordingView.swift
│   └── SettingsView.swift
├── ViewModels/
│   ├── IdeasListViewModel.swift
│   └── RecordingViewModel.swift
├── Components/
│   ├── IdeaCard.swift
│   └── RecordButton.swift
├── Services/
│   ├── SpeechRecognitionService.swift
│   └── FirebaseService.swift
└── IdeaSpotApp.swift
```

### How to Add Files to Project

1. In Xcode, right-click on the "IdeaSpot" folder in the Project Navigator
2. Select "Add Files to IdeaSpot..."
3. Navigate to each folder (Models, Views, ViewModels, Components, Services)
4. Select all files in the folder
5. Make sure "Copy items if needed" is UNCHECKED (files are already in place)
6. Make sure "Create groups" is selected
7. Ensure "IdeaSpot" target is checked
8. Click "Add"

**OR** simply delete the file references in Xcode and re-add the folders using "Add Files to IdeaSpot..." selecting the entire directory structure at once.

---

## 4. Firebase Configuration

### Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your IdeaSpot project (or create a new one)
3. Click the iOS icon to add an iOS app
4. Bundle ID: `com.yourcompany.IdeaSpot` (match your Xcode bundle ID)
5. Download the `GoogleService-Info.plist` file
6. Drag it into your Xcode project (root level, next to IdeaSpotApp.swift)
7. Make sure "Copy items if needed" is CHECKED
8. Make sure "IdeaSpot" target is checked

### Configure Firebase in AppDelegate

Update `IdeaSpotApp.swift` to initialize Firebase:

```swift
import SwiftUI
import SwiftData
import FirebaseCore

@main
struct IdeaSpotApp: App {
    init() {
        FirebaseApp.configure()
    }

    // ... rest of the code
}
```

---

## 5. Set up Apple Sign-In Capability

1. Select the IdeaSpot project in the navigator
2. Select the "IdeaSpot" target
3. Go to the "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Sign in with Apple"

---

## 6. Deploy Firebase Cloud Function

Create a Firebase Cloud Function to handle AI expansion calls to Claude API.

### Function Code (Cloud Functions for Firebase)

Create `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const Anthropic = require('@anthropic-ai/sdk');

exports.expandIdea = functions.https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { transcript } = data;

  if (!transcript) {
    throw new functions.https.HttpsError('invalid-argument', 'Transcript is required');
  }

  try {
    const anthropic = new Anthropic({
      apiKey: functions.config().anthropic.key,
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 2048,
      messages: [{
        role: 'user',
        content: `You are an AI assistant that helps expand on creative ideas. Given the following voice transcript of an idea, provide:

1. A concise title (5-10 words)
2. 3-5 expansion sections with titles and detailed content

Format your response as JSON:
{
  "title": "Title Here",
  "expansions": [
    {
      "sectionTitle": "Problem Statement",
      "content": "Detailed content here..."
    },
    ...
  ]
}

Transcript: "${transcript}"`
      }]
    });

    const content = message.content[0].text;
    const result = JSON.parse(content);

    return result;
  } catch (error) {
    console.error('Error expanding idea:', error);
    throw new functions.https.HttpsError('internal', 'Failed to expand idea');
  }
});
```

### Deploy

```bash
cd functions
npm install @anthropic-ai/sdk
firebase deploy --only functions
firebase functions:config:set anthropic.key="your-anthropic-api-key"
```

---

## 7. Build and Run

1. Select a simulator or device
2. Press Cmd+B to build
3. Fix any remaining import/reference issues
4. Press Cmd+R to run

---

## Next Steps After Setup

- [ ] Test voice recording permissions
- [ ] Test Firebase authentication
- [ ] Test AI expansion functionality
- [ ] Add app icon
- [ ] Configure proper bundle identifier
- [ ] Set up TestFlight when ready

---

## Troubleshooting

### Common Issues

**Build Error: "No such module 'Firebase'"**
- Make sure you've added the Firebase package dependencies
- Clean build folder: Cmd+Shift+K
- Rebuild: Cmd+B

**Speech Recognition Not Working**
- Check that Info.plist has the required privacy keys
- Make sure you're testing on a real device or simulator with speech support
- Verify permissions are granted in Settings

**Firebase Errors**
- Verify GoogleService-Info.plist is in the project
- Check that FirebaseApp.configure() is called in AppDelegate
- Ensure bundle ID matches Firebase console

---

## Development Timeline

Estimated time to complete setup: **30-45 minutes**

1. Add packages: 5-10 min
2. Configure Info.plist: 2 min
3. Add files to project: 5 min
4. Firebase setup: 10-15 min
5. Apple Sign-In: 3 min
6. Deploy Cloud Function: 10-15 min
7. Build and test: 5-10 min
