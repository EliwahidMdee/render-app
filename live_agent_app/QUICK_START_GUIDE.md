# Quick Start Guide - Live Agent App Updates

## 🚀 Getting Started

This guide will help you quickly get up and running with the updated Live Agent app.

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio or VS Code
- iOS/Android device or emulator

## Step 1: Install Dependencies

```bash
cd live_agent_app
flutter pub get
```

## Step 2: Add Your Logo (Required)

1. Navigate to: `live_agent_app/assets/images/`
2. Add your logo as: `logo.png`
3. Recommended specs:
   - Size: 512x512px (or similar square)
   - Format: PNG with transparent background
   - File name: `logo.png` (exactly)

**Note:** If you don't add a logo, the app will use a fallback icon.

## Step 3: Configure Backend URL

Edit `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://your-backend-url.com';
  // ... rest of the file
}
```

## Step 4: Run the App

```bash
# Check for any issues
flutter analyze

# Run on connected device
flutter run

# Or run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## Step 5: Test the App

### Login
- Open the app
- You should see your logo (or fallback icon)
- Enter test credentials
- Tap "Login"

### Dashboard
- After login, you'll see the dashboard
- View statistics: Pending, Active, Resolved sessions
- Try date filters: Today, Last Week, etc.
- Tap a statistics card to view filtered sessions

### Sessions
- From dashboard, tap "All Sessions" or a statistics card
- View list of sessions
- Tap a session to open chat

### Chat
- Messages auto-refresh every 800ms
- Agent messages appear on LEFT
- User messages appear on RIGHT
- User messages show status ticks:
  - Grey ✓✓ = Delivered
  - Blue ✓✓ = Read
- Type and send messages
- Observe real-time updates

### Navigation
- Use back buttons to navigate
- Dashboard button (📊) returns to dashboard
- Profile header shows agent info
- Settings button (placeholder - shows "Coming soon")

## Backend Integration

### Required APIs

Implement these endpoints (see API_DOCUMENTATION.md for details):

1. **Mark Message as Read**
   ```
   PUT /api/v1/live-agent/messages/{message_id}/read
   ```

2. **Bulk Mark as Read**
   ```
   PUT /api/v1/live-agent/sessions/{session_id}/messages/read
   ```

3. **Get Messages (Updated)**
   ```
   GET /api/v1/live-agent/sessions/{session_id}/messages
   ```
   Should return: `read_by_agent`, `read_by_user`, `delivered_at`, `read_at`

4. **Session Statistics**
   ```
   GET /api/v1/live-agent/agent/statistics?date_filter=today
   ```

### Database Changes

Add to messages table:
```sql
ALTER TABLE messages 
ADD COLUMN delivered_at TIMESTAMP,
ADD COLUMN read_at TIMESTAMP;

-- Add indexes
CREATE INDEX idx_messages_session_created 
ON messages(session_id, created_at);

CREATE INDEX idx_sessions_created 
ON sessions(created_at);
```

## Troubleshooting

### Logo not showing
- Check file exists: `assets/images/logo.png`
- Check pubspec.yaml includes assets
- Run `flutter clean` then `flutter pub get`

### Auto-refresh not working
- Check backend is returning updated data
- Verify API endpoints are working
- Check network connectivity

### Push notifications not working
- Configure Firebase (see existing docs)
- Update google-services.json (Android)
- Update GoogleService-Info.plist (iOS)

### Build errors
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## Testing Checklist

Use this checklist to verify everything works:

- [ ] App builds without errors
- [ ] Logo appears on login screen
- [ ] Can login with valid credentials
- [ ] Dashboard shows statistics
- [ ] Date filters work (Today, Last Week, etc.)
- [ ] Clicking statistics cards navigates to filtered sessions
- [ ] Session list displays correctly
- [ ] Can navigate to chat from session
- [ ] Chat shows WhatsApp-style layout (agent left, user right)
- [ ] Can send messages
- [ ] Messages auto-refresh
- [ ] Status ticks show on user messages
- [ ] Timestamps are accurate
- [ ] Profile header shows agent info
- [ ] Navigation works (back buttons, dashboard button)
- [ ] Can logout
- [ ] Push notifications work (if backend configured)

## Common Issues

### Issue: "Unexpected null value"
**Solution:** Check backend API responses match expected format

### Issue: Messages not refreshing
**Solution:** 
1. Check network connection
2. Verify API endpoint is accessible
3. Check for CORS issues

### Issue: Logo not found error
**Solution:** 
- Add logo.png to assets/images/
- Or ignore - fallback icon will be used

### Issue: Build fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## Performance Tips

1. **Auto-refresh interval**: Currently 800ms
   - Can be adjusted in `chat_screen.dart`
   - Consider exponential backoff for idle chats

2. **Dashboard caching**: 
   - Implement server-side caching
   - 5-minute TTL recommended

3. **Message pagination**:
   - Currently loads all messages
   - Consider implementing pagination for long chats

## Next Steps

1. ✅ Install dependencies
2. ✅ Add logo
3. ✅ Configure backend URL
4. ✅ Test on device
5. ⬜ Implement backend APIs
6. ⬜ Deploy to production
7. ⬜ Monitor and optimize

## Support Resources

- **API Documentation**: See `API_DOCUMENTATION.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`
- **Visual Guide**: See `VISUAL_CHANGES_GUIDE.md`
- **Original Docs**: Check other .md files in project root

## Development Workflow

```bash
# Development cycle
flutter run --hot-reload

# Testing
flutter test

# Build for production
flutter build apk  # Android
flutter build ios  # iOS

# Analyze code
flutter analyze

# Format code
dart format lib/
```

## Environment Setup

### Android
- Min SDK: Check build.gradle
- Target SDK: Latest recommended
- Permissions: Internet, notifications

### iOS
- iOS version: Check Podfile
- Permissions: Check Info.plist
- Notifications: Configure in Xcode

## Firebase Configuration

If push notifications needed:

1. Add google-services.json (Android)
2. Add GoogleService-Info.plist (iOS)
3. Update Firebase console with app details
4. Test notification delivery

## Production Deployment

Before deploying:

1. ✅ All tests pass
2. ✅ Backend APIs implemented
3. ✅ Logo added
4. ✅ Firebase configured
5. ✅ Tested on physical devices
6. ✅ Performance optimized
7. ✅ Security reviewed

## Questions?

Check the documentation files:
- API_DOCUMENTATION.md
- IMPLEMENTATION_SUMMARY.md
- VISUAL_CHANGES_GUIDE.md

---

**Happy Coding! 🎉**
