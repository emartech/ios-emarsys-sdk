# Migrate from Mobile Engage SDK

This is a guide on how to move from the Mobile Engage SDK to the new Emarsys SDK. This guide only covers the actual migration from the Mobile Engage SDK to the Emarsys SDK, please look at the [README](README.md) for more general details on how to get started with the Emarsys SDK.

## Project Configuration

In the Podfile configuration you need to remove the dependency to MobileEngage and the CoreSDK and add the new EmarsysSDK.

```
pod 'MobileEngageSDK'
pod 'CoreSDK'
```
↓
```
pod 'EmarsysSDK', :git => 'git@github.com:emartech/ios-emarsys-sdk.git', :tag => '1.99.0'
```

## Classes

The `MEEventHandler` interface was renamed to `EMSEventHandler`.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, MEEventHandler {
  ...
}
```
↓
```
class AppDelegate: UIResponder, UIApplicationDelegate, EMSEventHandler {
  ...
}
```

## Methods

### appLogin()

A call of `MobileEngage.appLogin` without parameters is no longer necessary. You no longer login anonymously, instead upon registering your device, we will automatically create an anonymous contact if we never saw this device.

### appLogin(contactFieldId, contactFieldvalue)

The workflow for linking a device to a contact was changed slightly. Instead of passing both the *contactFieldId* and the *contactFieldValue* when the user logs in, you now only need to send the *contactFieldValue*. The *contactFieldId* is set once during the configuration of the EmarsysSDK.

```swift
MobileEngage.appLogin(contactFieldId, contactFieldvalue)
```
↓
```swift
let config = EMSConfig.make { builder in
  ...
  builder.setContactFieldId(contactFieldId)
  ...
}

Emarsys.setContactWithContactFieldValue(contactFieldValue)
```

### appLogout

```swift
MobileEngage.appLogout()
```
↓
```swift
Emarsys.clearContact()
```

### setPushToken

```swift
MobileEngage.setPushToken(deviceToken)
```
↓
```swift
Emarsys.push.setPushToken(deviceToken)
```

### setPushToken(null)

If you were calling the `setPushToken` method with `null` in order to remove the token you need to change those calls to use the dedicated method `removePushToken` instead.

```swift
MobileEngage.setPushToken(null)
```
↓
```swift
Emarsys.push.removePushToken()
```

### trackMessageOpen(info)

```swift
MobileEngage.trackMessageOpen(userInfo)
```
↓
```swift
Emarsys.push.trackMessageOpen(userInfo)
```

### statusDelegate

The `MobileEngage.statusDelegate` property was removed, you can now specify a completion block for each method instead.

```swift
MobileEngage.statusDelegate = self
```
↓
```swift
Emarsys.push.setPushToken(token) { (err) in
  ...
}
```
