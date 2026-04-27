# Facebook App ID Setup Guide

A Facebook App ID is required to fully use the Instagram Stories sharing feature.

## 1. Create a Facebook Developer Account

1. Go to [Facebook for Developers](https://developers.facebook.com/)
2. Click "Get Started" in the top right
3. Log in with your Facebook account (create one if you don't have one)
4. Complete developer account registration

## 2. Create an App

1. Go to the [My Apps](https://developers.facebook.com/apps/) page
2. Click the "Create App" button
3. Select app type: "Other" or "Consumer"
4. Enter app name (e.g. "벌컥벌컥")
5. Enter contact email
6. Click "Create App"

## 3. Find Your App ID

1. In the app dashboard, click "Settings" > "Basic"
2. Copy the "App ID" shown at the top (a numeric ID)

## 4. Add Configuration to Your iOS App

Add to the `infoPlist` section in `ios/Project.swift`:

```swift
infoPlist: .extendingDefault(with: [
    // existing settings...
    "FacebookAppID": "YOUR_APP_ID_HERE",
    "CFBundleURLTypes": .array([
        .dictionary([
            "CFBundleURLSchemes": .array([
                .string("fb YOUR_APP_ID_HERE")
            ])
        ])
    ])
])
```

Replace `YOUR_APP_ID_HERE` with your actual App ID.

## 5. Link Instagram Account (Optional)

For better analytics, link an Instagram account:

1. Click "Add Product" in the app dashboard
2. Set up "Instagram Basic Display API"
3. Link your Instagram business/creator account following the instructions

## 6. Testing

1. Run `tuist generate`
2. Build and run the app
3. Test the sharing feature on a real device with Instagram installed

## Notes

- Basic sharing works without a Facebook App ID
- Setting an App ID enables share analytics and tracking
- You don't need Facebook app review before App Store release (when using basic sharing only)

## Troubleshooting

### Instagram doesn't open after sharing
- Check that `instagram-stories` URL scheme is registered in Info.plist
- Test on a real device (Instagram can't be installed on the simulator)

### "Can't open app" error
- Check that Facebook App ID is configured correctly
- Try a clean build after `tuist generate`

## Related Documents

- [Instagram Sharing to Stories](https://developers.facebook.com/docs/instagram/sharing-to-stories/)
- [Facebook App ID Setup](https://developers.facebook.com/docs/development/create-an-app/)
