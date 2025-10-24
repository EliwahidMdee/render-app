# Live Agent Flutter App

A modern, attractive Flutter application for real-time customer support in a multi-tenant environment.

## Features

✨ **Modern Material Design 3 UI** with gradient themes
🎨 **Attractive, Stylish Views** with Google Fonts (Poppins & Roboto)
💬 **Real-time Chat Interface** with message bubbles
🔔 **Firebase Cloud Messaging** for push notifications
🔐 **Secure Authentication** with JWT tokens
📱 **Session Management** with status filters
🎯 **Multi-tenant Support** with domain isolation
⚡ **State Management** using Riverpod
🌐 **REST API Integration** with Dio

## Screenshots

The app features:
- **Login Screen**: Beautiful gradient background with modern card design
- **Sessions List**: Clean card-based layout with status badges and unread counts
- **Chat Screen**: WhatsApp-style message bubbles with timestamps
- **Modern UI Elements**: Smooth animations, material shadows, and attractive color schemes

## Architecture

The app follows **Clean Architecture** principles:

```
lib/
├── core/                          # Core utilities
│   ├── constants/                 # App & API constants
│   ├── network/                   # Dio HTTP client
│   ├── storage/                   # Secure storage
│   └── utils/                     # Formatters, loggers
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   │   ├── data/                  # Models & repositories
│   │   └── presentation/          # Screens & providers
│   ├── sessions/                  # Session management
│   │   ├── data/
│   │   └── presentation/
│   ├── chat/                      # Chat functionality
│   │   ├── data/
│   │   └── presentation/
│   └── notifications/             # FCM service
│       └── services/
└── main.dart                      # App entry point
```

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase project (for FCM notifications)

## Installation

1. **Clone the repository**
   ```bash
   cd live_agent_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional but recommended for notifications)
   - Create a Firebase project at https://console.firebase.google.com
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in the respective platform folders:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Configure API endpoint**
   - Edit `lib/core/constants/api_constants.dart`
   - Update `baseUrl` to your backend API URL

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### API Configuration

Update the API base URL in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### Firebase Configuration

1. Add your Firebase configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

2. The app will automatically initialize Firebase on startup

### Theme Customization

Customize colors in `lib/core/constants/app_constants.dart`:

```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color accent = Color(0xFF00BCD4);
  // ... more colors
}
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ipa --release
```

## Features Implementation

### Authentication
- ✅ JWT-based login
- ✅ Secure token storage
- ✅ Auto-login on app restart
- ✅ Beautiful gradient login screen

### Session Management
- ✅ List all sessions with filters
- ✅ Status-based filtering (Pending, Active, Resolved)
- ✅ Unread message badges
- ✅ Auto-assign sessions to agents
- ✅ Pull-to-refresh

### Chat
- ✅ Real-time messaging
- ✅ Message history
- ✅ WhatsApp-style message bubbles
- ✅ Read receipts
- ✅ Timestamp formatting
- ✅ Auto-scroll to latest message

### Notifications
- ✅ FCM push notifications
- ✅ Foreground notifications
- ✅ Background notifications
- ✅ Notification tap handling
- ✅ Online/offline status

## API Integration

The app integrates with the Live Agent backend API with the following endpoints:

- `POST /api/v1/auth/login` - Agent login
- `GET /api/v1/live-agent/sessions` - List sessions
- `GET /api/v1/live-agent/sessions/{id}` - Get session details
- `PUT /api/v1/live-agent/sessions/{id}/status` - Update session status
- `GET /api/v1/live-agent/messages/{sessionId}` - Get messages
- `POST /api/v1/live-agent/messages` - Send message
- `PUT /api/v1/live-agent/agent/status` - Update agent online status

## Dependencies

Key dependencies used:

- `flutter_riverpod` - State management
- `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage
- `firebase_core` & `firebase_messaging` - Push notifications
- `google_fonts` - Beautiful typography
- `intl` - Date formatting
- `timeago` - Relative time formatting
- `hive` - Local database (optional)

## Design System

### Colors
- **Primary**: Blue gradient (#2196F3 → #1976D2)
- **Accent**: Cyan (#00BCD4)
- **Success**: Green (#4CAF50)
- **Error**: Red (#F44336)
- **Warning**: Amber (#FFC107)

### Typography
- **Headings**: Poppins (Bold)
- **Body**: Roboto (Regular)

### Components
- **Cards**: Elevated with rounded corners (12px)
- **Buttons**: Rounded with elevation
- **Input Fields**: Filled with outline
- **Message Bubbles**: WhatsApp-style with shadows

## Testing

### Test Credentials

For testing purposes, you can use:
- Email: `agent@example.com`
- Password: `password123`

(Update these based on your backend setup)

### Manual Testing Steps

1. **Login Test**
   - Enter credentials
   - Verify successful login
   - Check token storage

2. **Sessions Test**
   - Verify sessions list loads
   - Test status filters
   - Check pull-to-refresh

3. **Chat Test**
   - Open a session
   - Send messages
   - Verify message delivery
   - Check read receipts

4. **Notifications Test**
   - Create new session from web
   - Verify FCM notification received
   - Test notification tap navigation

## Troubleshooting

### Common Issues

1. **Firebase not configured**
   - Error: "Firebase initialization failed"
   - Solution: Add `google-services.json` / `GoogleService-Info.plist`

2. **API connection failed**
   - Error: "Failed to fetch sessions"
   - Solution: Check API URL in `api_constants.dart`

3. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Rebuild the app

## Contributing

This is a complete implementation based on the Live Agent Flutter App Development Guide. Feel free to customize and enhance as needed.

## License

MIT License - Feel free to use this in your projects

## Support

For issues and questions, please refer to the original development guide:
`LIVE_AGENT_FLUTTER_APP_DEVELOPMENT_GUIDE(1).md`

## Version

Current version: 1.0.0

---

**Built with ❤️ using Flutter**
