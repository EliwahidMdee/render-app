# Live Agent Flutter App - Complete Setup Guide

## 🎯 Overview

This is a **production-ready**, **modern**, and **attractive** Flutter application implementing the complete Live Agent system as described in the development guide. The app features:

- ✨ **Material Design 3** with beautiful gradient themes
- 🎨 **Google Fonts** (Poppins & Roboto) for modern typography
- 💬 **WhatsApp-style chat interface** with message bubbles
- 🔔 **Firebase Cloud Messaging** for real-time notifications
- 🔐 **Secure JWT authentication**
- 📱 **Clean Architecture** with Riverpod state management
- 🌐 **Complete REST API integration**

## 📱 App Features

### 1. Authentication Screen
- Beautiful gradient background (Blue to Cyan)
- Modern card design with elevation and shadows
- Email and password validation
- Show/hide password toggle
- Loading states with progress indicators
- Error handling with snackbars

### 2. Sessions List Screen
- Gradient app bar with agent info
- Card-based session list with:
  - User avatars
  - Status badges (Pending, Active, Resolved, Closed)
  - Unread message counts
  - Message previews
  - Relative timestamps (e.g., "5 minutes ago")
- Filter menu by status
- Pull-to-refresh functionality
- Empty state with friendly messages
- Error state with retry button

### 3. Chat Screen
- WhatsApp-style message bubbles
- Different colors for user and agent messages
- Timestamps with read receipts
- Sender names for user messages
- Auto-scroll to latest message
- Message input with send button
- Session info banner
- Close session functionality
- Gradient app bar with session details

## 🚀 Quick Start

### Option 1: Using Flutter (Recommended)

If you have Flutter installed:

```bash
cd live_agent_app
flutter pub get
flutter run
```

### Option 2: Using Pre-built APK (Android)

1. Build the APK:
   ```bash
   cd live_agent_app
   flutter build apk --release
   ```

2. Install on device:
   ```bash
   flutter install
   ```

## 🔧 Configuration

### 1. API Endpoint Configuration

Edit `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-backend-url.com';
  // ... other constants
}
```

### 2. Firebase Setup (for Notifications)

**Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

**iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/GoogleService-Info.plist`

### 3. Theme Customization

Edit `lib/core/constants/app_constants.dart` to customize colors:

```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);      // Blue
  static const Color primaryDark = Color(0xFF1976D2);  // Dark Blue
  static const Color accent = Color(0xFF00BCD4);       // Cyan
  // Customize these colors to match your brand
}
```

## 📂 Project Structure

```
live_agent_app/
├── lib/
│   ├── core/                       # Core utilities
│   │   ├── constants/              # App-wide constants
│   │   │   ├── api_constants.dart  # API endpoints
│   │   │   └── app_constants.dart  # App constants & colors
│   │   ├── network/
│   │   │   └── dio_client.dart     # HTTP client
│   │   ├── storage/
│   │   │   └── secure_storage.dart # Secure token storage
│   │   └── utils/
│   │       ├── date_formatter.dart # Date formatting
│   │       └── logger.dart         # Logging utility
│   │
│   ├── features/                   # Feature modules
│   │   ├── auth/                   # Authentication
│   │   │   ├── data/
│   │   │   │   ├── models/         # Agent model
│   │   │   │   └── repositories/   # Auth repository
│   │   │   └── presentation/
│   │   │       ├── providers/      # Auth state provider
│   │   │       └── screens/        # Login screen
│   │   │
│   │   ├── sessions/               # Session management
│   │   │   ├── data/
│   │   │   │   ├── models/         # Session model
│   │   │   │   └── repositories/   # Session repository
│   │   │   └── presentation/
│   │   │       ├── providers/      # Sessions provider
│   │   │       ├── screens/        # Sessions list screen
│   │   │       └── widgets/        # Session card widget
│   │   │
│   │   ├── chat/                   # Chat feature
│   │   │   ├── data/
│   │   │   │   ├── models/         # Message model
│   │   │   │   └── repositories/   # Chat repository
│   │   │   └── presentation/
│   │   │       ├── providers/      # Chat provider
│   │   │       ├── screens/        # Chat screen
│   │   │       └── widgets/        # Message bubble widget
│   │   │
│   │   └── notifications/          # FCM notifications
│   │       └── services/
│   │           └── fcm_service.dart # Firebase messaging
│   │
│   └── main.dart                   # App entry point
│
├── android/                        # Android configuration
├── ios/                            # iOS configuration
├── assets/                         # App assets
├── pubspec.yaml                    # Dependencies
├── README.md                       # Main documentation
└── SETUP_GUIDE.md                  # This file
```

## 🎨 UI Design System

### Colors

- **Primary Blue**: `#2196F3` - Main app color, buttons, app bar
- **Dark Blue**: `#1976D2` - Gradient accent
- **Cyan**: `#00BCD4` - Secondary accent
- **Green**: `#4CAF50` - Success, active status
- **Amber**: `#FFC107` - Warning, pending status
- **Red**: `#F44336` - Error, danger
- **Grey**: `#9E9E9E` - Resolved, disabled states

### Typography

- **Headings**: Poppins Bold
- **Body Text**: Roboto Regular
- **Small Text**: Roboto 12-14px

### Components

- **Cards**: 12px border radius, elevation 2
- **Buttons**: 12px border radius, gradient background
- **Input Fields**: 12px border radius, filled with outline
- **Message Bubbles**: 16px border radius, 4px corner on sender side

## 🔌 API Integration

The app expects the following API endpoints:

### Authentication
```
POST /api/v1/auth/login
Body: { "email": "agent@example.com", "password": "password", "role": "agent" }
Response: { "access_token": "jwt_token", "agent": {...} }
```

### Sessions
```
GET /api/v1/live-agent/sessions?status=pending&page=1&per_page=20
Response: { "sessions": [...], "total": 45, "page": 1 }
```

### Session Details
```
GET /api/v1/live-agent/sessions/{session_id}
Response: { "session_id": "...", "tenant_domain": "...", ... }
```

### Update Session
```
PUT /api/v1/live-agent/sessions/{session_id}/status
Body: { "status": "active", "assigned_agent_id": "123", "assigned_agent_name": "Agent" }
```

### Messages
```
GET /api/v1/live-agent/messages/{session_id}?mark_as_read=true
Response: { "messages": [...], "total": 10 }
```

### Send Message
```
POST /api/v1/live-agent/messages
Body: { "session_id": "...", "message_text": "Hello", "sender_type": "agent" }
Response: { "message_id": 123, "created_at": "...", ... }
```

### Agent Status
```
PUT /api/v1/live-agent/agent/status
Body: { "is_online": true, "fcm_token": "..." }
```

## 🧪 Testing the App

### Test Credentials

Use these test credentials (update based on your backend):
- Email: `agent@example.com`
- Password: `password123`

### Manual Testing Flow

1. **Login**
   - Open the app
   - Enter test credentials
   - Tap Login
   - Should navigate to Sessions List

2. **View Sessions**
   - See list of sessions
   - Try different status filters (All, Pending, Active, Resolved)
   - Pull to refresh

3. **Open Chat**
   - Tap on a session card
   - Should see message history
   - Session should auto-assign to current agent

4. **Send Messages**
   - Type a message
   - Tap send button
   - Message should appear in chat
   - Should scroll to bottom

5. **Close Session**
   - Tap close button in chat screen
   - Confirm closure
   - Should navigate back to sessions list

6. **Test Notifications** (if Firebase configured)
   - Create new session from web/backend
   - Should receive push notification
   - Tap notification
   - Should open chat for that session

## 🐛 Troubleshooting

### Issue: "Failed to fetch sessions"
**Solution**: Check API URL in `lib/core/constants/api_constants.dart`

### Issue: "Login failed"
**Solution**: 
- Verify backend is running
- Check credentials
- Check API response format

### Issue: "Firebase initialization failed"
**Solution**: 
- This is normal if Firebase is not configured
- Add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
- Or remove Firebase dependencies if not needed

### Issue: Build errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Dio error"
**Solution**:
- Check network connection
- Verify API endpoint is reachable
- Check CORS settings on backend

## 📦 Dependencies Explained

- **flutter_riverpod**: State management
- **dio**: HTTP client for API calls
- **flutter_secure_storage**: Secure token storage
- **firebase_core & firebase_messaging**: Push notifications
- **flutter_local_notifications**: Local notification display
- **google_fonts**: Poppins and Roboto fonts
- **intl**: Date formatting
- **timeago**: Relative time (e.g., "5 mins ago")
- **logger**: Debug logging
- **uuid**: Generate unique IDs
- **hive**: Local database (optional)

## 🚢 Deployment

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

APK will be in: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Build for iOS
flutter build ios --release

# Or create IPA
flutter build ipa --release
```

## 📝 Customization Tips

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Your App Name">
```

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>Your App Name</string>
```

### Change App Icon
Replace icon files in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Or use `flutter_launcher_icons` package

### Add New Features
1. Create feature folder in `lib/features/`
2. Add models in `data/models/`
3. Add repository in `data/repositories/`
4. Add provider in `presentation/providers/`
5. Add screens in `presentation/screens/`
6. Add widgets in `presentation/widgets/`

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Firebase Messaging](https://firebase.google.com/docs/cloud-messaging/flutter/client)

## ✨ What's Next?

Suggested enhancements:
- [ ] Add voice messages
- [ ] Add file attachments
- [ ] Add emoji picker
- [ ] Add typing indicators
- [ ] Add message search
- [ ] Add agent availability toggle
- [ ] Add analytics dashboard
- [ ] Add dark mode
- [ ] Add localization (multiple languages)
- [ ] Add biometric authentication

## 🤝 Support

For issues or questions:
1. Check this setup guide
2. Review the main development guide
3. Check API documentation
4. Review code comments

## 📄 License

MIT License - Free to use and modify

---

**Happy Coding! 🚀**

*Built with Flutter and love for modern, attractive UIs*
