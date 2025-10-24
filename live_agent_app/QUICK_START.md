# ⚡ Quick Start Guide - Live Agent Flutter App

## 🚀 Get Started in 3 Steps

### Step 1: Install Dependencies
```bash
cd live_agent_app
flutter pub get
```

### Step 2: Configure API URL
Edit `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### Step 3: Run the App
```bash
flutter run
```

That's it! The app is now running! 🎉

---

## 📱 Test the App

### Demo Login (Update based on your backend)
```
Email: agent@example.com
Password: password123
```

### Test Flow
1. **Login** → Enter credentials → Tap Login
2. **View Sessions** → See list of active sessions
3. **Open Chat** → Tap any session → View messages
4. **Send Message** → Type message → Tap send
5. **Close Session** → Tap close button → Confirm

---

## 🎨 What You'll See

### Login Screen
![Login Screen](https://via.placeholder.com/300x600/2196F3/FFFFFF?text=Beautiful+Gradient+Login)
- Gradient background (Blue to Cyan)
- Modern card with elevation
- Email & password fields
- Show/hide password toggle

### Sessions List
![Sessions List](https://via.placeholder.com/300x600/F5F5F5/2196F3?text=Sessions+List)
- Card-based layout
- Status badges (Pending, Active, Resolved)
- Unread message counts
- Pull-to-refresh
- Filter menu

### Chat Screen
![Chat Screen](https://via.placeholder.com/300x600/FFFFFF/2196F3?text=WhatsApp+Style+Chat)
- WhatsApp-style message bubbles
- Different colors for user/agent
- Timestamps with read receipts
- Modern input field
- Auto-scroll to latest

---

## 🔧 Quick Configuration

### Change App Name
**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<application android:label="Your App Name">
```

**iOS:** `ios/Runner/Info.plist`
```xml
<key>CFBundleName</key>
<string>Your App Name</string>
```

### Change Colors
**File:** `lib/core/constants/app_constants.dart`
```dart
class AppColors {
  static const Color primary = Color(0xFF2196F3);    // Your brand color
  static const Color accent = Color(0xFF00BCD4);     // Your accent color
}
```

### Add Firebase (Optional - for notifications)
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`
3. Done! FCM will work automatically

---

## 📦 Build for Release

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
flutter build ios --release
```
Then open Xcode and archive for App Store

---

## 🐛 Common Issues & Fixes

### "Failed to fetch sessions"
❌ **Problem:** API not reachable
✅ **Fix:** Update `baseUrl` in `api_constants.dart`

### "Firebase initialization failed"
❌ **Problem:** Firebase not configured
✅ **Fix:** Add `google-services.json` OR ignore (optional)

### Build errors
❌ **Problem:** Corrupted cache
✅ **Fix:** Run these commands:
```bash
flutter clean
flutter pub get
flutter run
```

### Login fails
❌ **Problem:** Backend not running or wrong credentials
✅ **Fix:** 
- Check backend is running
- Verify credentials
- Check API endpoint URL

---

## 📚 Helpful Files

- **README.md** - Full documentation
- **SETUP_GUIDE.md** - Detailed setup guide
- **IMPLEMENTATION_SUMMARY.md** - What was built
- **pubspec.yaml** - Dependencies list

---

## 🎯 Project Structure at a Glance

```
lib/
├── core/              # Shared utilities
│   ├── constants/     # API URLs, colors, etc.
│   ├── network/       # HTTP client
│   ├── storage/       # Secure storage
│   └── utils/         # Helpers
│
├── features/          # App features
│   ├── auth/          # Login
│   ├── sessions/      # Session list
│   ├── chat/          # Chat interface
│   └── notifications/ # FCM service
│
└── main.dart          # Entry point
```

---

## ✨ Key Features

✅ **Authentication** - Secure JWT login
✅ **Sessions** - List with filters and status badges
✅ **Chat** - WhatsApp-style messaging
✅ **Notifications** - FCM push notifications
✅ **Modern UI** - Material Design 3 with gradients
✅ **State Management** - Riverpod
✅ **Error Handling** - User-friendly messages
✅ **Loading States** - Progress indicators everywhere

---

## 🎨 Color Palette

```
🔵 Primary: #2196F3 (Blue)
🔷 Dark: #1976D2 (Dark Blue)
💠 Accent: #00BCD4 (Cyan)
🟢 Success: #4CAF50 (Green)
🟡 Warning: #FFC107 (Amber)
🔴 Error: #F44336 (Red)
```

---

## 🚀 Advanced: Environment Setup

### For Development
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://localhost:8000';
```

### For Production
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://api.production.com';
```

### Use Flavors (Optional)
Create separate build configurations:
- Development: `flutter run --flavor dev`
- Production: `flutter run --flavor prod`

---

## 📱 Supported Platforms

✅ **Android** - API 21+ (Android 5.0 Lollipop)
✅ **iOS** - iOS 11+
⚠️ **Web** - Needs additional configuration
⚠️ **Desktop** - Needs additional configuration

---

## 🤝 Getting Help

1. Check **SETUP_GUIDE.md** for detailed instructions
2. Review **IMPLEMENTATION_SUMMARY.md** for features list
3. Check Flutter documentation: https://flutter.dev/docs
4. Check Riverpod docs: https://riverpod.dev

---

## 🎯 What's Next?

### After Basic Setup
1. ✅ Test login flow
2. ✅ Test session listing
3. ✅ Test chat functionality
4. ✅ Test notifications (if Firebase configured)

### Customization
1. ⚙️ Update app name and icon
2. ⚙️ Customize colors to match brand
3. ⚙️ Add your logo to login screen
4. ⚙️ Configure Firebase for your project

### Deployment
1. 📱 Generate signed APK/AAB
2. 📱 Submit to Play Store / App Store
3. 📱 Set up CI/CD (optional)

---

## 💡 Pro Tips

### Faster Development
```bash
# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
# Clear cache: flutter clean
```

### Debug vs Release
```bash
# Debug (faster build, with debugging)
flutter run

# Release (slower build, optimized)
flutter run --release
```

### View Logs
```bash
# View all logs
flutter logs

# View specific logs (in code)
AppLogger.info('Message here');
```

---

## ✅ Checklist Before Launch

- [ ] Update API endpoint to production URL
- [ ] Test all features thoroughly
- [ ] Add Firebase configuration (if using notifications)
- [ ] Change app name and icon
- [ ] Update version in pubspec.yaml
- [ ] Generate signed release build
- [ ] Test on real devices
- [ ] Prepare store listings
- [ ] Submit to app stores

---

## 🎉 You're Ready!

The app is **fully functional** and **ready to customize**!

Just update the API endpoint and start testing. Everything else works out of the box! 🚀

---

**Need more details?** Check the other documentation files in this project.

**Happy coding!** 💻✨
