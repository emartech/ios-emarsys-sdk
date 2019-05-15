# PILOT VERSION

This SDK is still in Pilot phase, please only use if you have a pilot agreement contract in place!

If you are looking for our recommended SDK then please head to [Mobile Engage SDK](https://github.com/emartech/ios-mobile-engage-sdk.git "Mobile Engage SDK")

## What is the Emarsys SDK?

The Emarsys SDK enables you to use Mobile Engage and Predict in a very straightforward way. By incorporating the SDK in your app, we support you, among other things, in handling credentials, API calls, tracking of opens and events as well as logins and logouts in the app.

The Emarsys SDK is open sourced to enhance transparency and to remove privacy concerns. This also means that you can always be up-to-date with what we are working on.

Using the SDK is also beneficial from the product aspect: it simply makes it much easier to send push messages through your app. Please always use the latest version of the SDK in your app.

### Why Emarsys SDK over Mobile Engage SDK?

We learned a lot from running Mobile Engage SDK in the past 2 years and managed to apply these learnings and feedbacks in our new SDK.

##### The workflow for linking/unlinking a contact to a device was too complex
* We removed anonymous contacts from our API. This way you can always send behaviour events, opens without having the complexity to login first with an identified contact or use hard-to-understand anonymous contact concept
##### The API was stateful and limited our scalability
* We can scale with our new stateless APIs in the backend We now include anonymous inapp metrics support
* We would like to make sure we understand end to end the experience of your app users and give you some insights through the data platform
##### Swift first approach
* We have improved the interoperability of our SDK with Swift. Using our SDK from Swift is now more convenient.
#####  Repetition of arguments
* We have improved the implementation workflow, so the energy is spent during the initial integration but not repeated during the life time of the app
#####  Unification of github projects
* The Predict SDK, The Emarsys core SDK, the Mobile Engage SDK and the corresponding sample app are all now in a single repository. You can now find up to date and tested usage examples easily
## Emarsys SDK iOS integration guide
### 1. Installation with CocoaPods
#### 1.1 Install CocoaPods
CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries.
You can install it with the following command:

`$ gem install cocoapods`

#### 1.2 Podfile
To integrate the Emarsys SDK into your Xcode project using CocoaPods, specify it in your Podfile:
```ruby
platform :ios, '11.0'

source 'https://github.com/CocoaPods/Specs.git'

target "<TargetName>" do
	pod ‘EmarsysSDK’, '~> 2.0.0’
end
```
>Wherever you see <TargetName> or anything similar in <> brackets, you should change those according to your own naming convention.

#### 1.3 Install Pods
After creating the Podfile, you need to execute the command below to download dependencies:
`pod install`
### 2. Requirements
* The iOS target should be iOS 11 or higher.
* In order to be able to send push messages to your app, you need to have certifications from Apple Push Notification service (APNs).
For more information please check our [documentation](https://help.emarsys.com/hc/en-us/articles/115003342665-Obtaining-certifications-and-tokens-for-sending-push-messages#obtaining_certificate_for_apple_push_notification_service "Obtaining certification").
### 3. Usage
#### 3.1 Initialization
To configure the SDK, the following has to be done in the `AppDelegate` of the application:
###### Objective-C
```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    EMSConfig *config = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:<applicationCode: NSString>
                            applicationPassword:<applicationPassword: NSString>];
        [builder setContactFieldId:<contactFieldId: NSNumber>];
        [builder setMerchantId:<predictMerchantId: NSString>];
    }];
    [Emarsys setupWithConfig:config];
    
    return YES;
}
```
###### Swift
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let config = EMSConfig.make { builder in
        builder.setMobileEngageApplicationCode(<applicationCode: String>, applicationPassword: <applicationPassword: String>)
        builder.setContactFieldId(<contactFieldId: Number>)
        builder.setMerchantId(<predictMerchantId: String>)
    }
    Emarsys.setup(with: config)
    
    return true
}
```
#### 3.2 setContact
After application setup is finished, you can use `setContact` method to identify the user with `contactFieldValue`.
###### Objective-C
```objectivec
[Emarsys setContactWithContactFieldValue:<contactFieldValue: NSString>
                         completionBlock:^(NSError *error) {
                         }];
```
###### Swift
```swift
Emarsys.setContactWithContactFieldValue(<contactFieldValue: String>) { error in
}
```
#### 3.3 clearContact
When the user signs out, the `clearContact` method should be used:
###### Objective-C
```objectivec
[Emarsys clearContactWithCompletionBlock:^(NSError *error) {
}];
```
###### Swift
```swift
Emarsys.clearContact { error in
}
```
#### 3.4 trackCustomEvent
If you want to track custom events, the `trackCustomEvent` method should be used, where the `eventName` parameter is required, but the other attributes are optional.
###### Objective-C
```objectivec
[Emarsys trackCustomEventWithName:<eventName: String>
                  eventAttributes:<eventAttributes: NSDictionary<String, String>
                  completionBlock:^(NSError *error) {
                  }];
```
###### Swift
```swift
Emarsys.trackCustomEvent(withName: <eventName: String>, eventAttributes: <eventAttributes: NSDictionary<String, String>) { error in
}
```
### 4. Push
#### 4.1 setPushToken
The `pushToken` has to be set when it arrives:
###### Objective-C
```objectivec
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Emarsys.push setPushToken:deviceToken
               completionBlock:^(NSError *error) {
               }];
}
```
###### Swift
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Emarsys.push.setPushToken(deviceToken) { error in   
    }
}
```
#### 4.2 clearPushToken
If you want to remove `pushToken` for the Contact, you can use `clearPushToken`
###### Objective-C 
```objectivec
[Emarsys.push clearPushTokenWithCompletionBlock:^(NSError *error) {
}];
```
###### Swift
```swift
Emarsys.push.clearPushToken { error in
}
```
#### 4.3 trackMessageOpen
If you want to track whether the push messages have been opened, the `trackMessageOpen` method should be used. 
In the simplest case this call will be in the AppDelegate's `didReceiveRemoteNotification:fetchCompletionHandler:` method:
###### Objective-C
```objectivec
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [Emarsys.push trackMessageOpenWithUserInfo:userInfo
                               completionBlock:^(NSError *error) {
                               }];
}
```
###### Swift
```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Emarsys.push.trackMessageOpen(userInfo: userInfo) { error in
    }
}
```
### 5. Inbox
#### 5.1 fetchNotifications
In order to receive the inbox content, you can use the `fetchNotifications` method.
###### Objective-C
```objectivec
[Emarsys.inbox fetchNotificationsWithResultBlock:^(EMSNotificationInboxStatus *inboxStatus, NSError *error) {
    if (error) {
        NSLog(error);
    } else {
        NSLog(inboxStatus.notifications);
        NSLog(inboxStatus.badgeCount);
    }
}];
```
###### Swift
```swift
Emarsys.inbox.fetchNotifications { status, error in
    if let error = error {
        print(error as Any)
    } else if let status = status {
        print("Notifications: \(status.notifications) badgeClount: \(status.badgeCount)")
    }
}
```
#### 5.2 resetBadgeCount
When your user opened the application inbox you might want to reset the unread count (badge). To do so you can use the `resetBadgeCount` method.
###### Objective-C
```objectivec
[Emarsys.inbox resetBadgeCountWithCompletionBlock:^(NSError *error) {
}];
```
###### Swift
```swift
Emarsys.inbox.resetBadgeCount { error in
}
```
#### 5.3 trackNotificationOpen
To track the notification opens in inbox, use the following `trackNotificationOpen` method.
###### Objective-C
```objectivec
[Emarsys.inbox trackNotificationOpenWithNotification:<notification: EMSNotification>
                                     completionBlock:^(NSError *error) {
}];
```
###### Swift
```swift
Emarsys.inbox.trackNotificationOpen(with: <notification: EMSNotification>) { error in
}
```
### 6. InApp
#### 6.1 pause
When a critical activity starts and should not be interrupted by InApp, `pause` InApp messages
###### Objective-C
```objectivec
[Emarsys.inApp pause];
```
###### Swift
```swift
Emarsys.inApp.pause()
```
#### 6.2 resume
In order to show inApp messages after being paused use the `resume` method
###### Objective-C
```objectivec
[Emarsys.inApp resume];
```
###### Swift
```swift
Emarsys.inApp.resume()
```
#### 6.3 setEventHandler
In order to get an event, triggered from the InApp message, you can register for it using the `setEventHandler` method.
###### Objective-C
```objectivec
[Emarsys.inApp setEventHandler:<eventHandler: id<EMSEventHandler>>];
```
###### Swift
```swift
Emarsys.inApp.eventHandler = <eventHandler: EMSEventHandler>
```
### 7. Predict
>Please be informed that Predict is not available with the current version of the Emarsys SDK

We won't go into the details to introduce how Predict works, and what are the capabilities, but here we aim to explain the mapping between the Predict commands and our interface.
Please visit Predict's [documentation](https://dev.emarsys.com/v2/web-extend-command-reference "Predict documentation") for more details.
#### 7.1 Initialization
To use Predict functionality you have to setup your `merchantId` during the initialization of the SDK.
In order to track Predict events you can use the methods available on our Predict interface.
#### 7.2 trackCart
When you want to track the cart items in the basket you can call the `trackCart` method with a list of CartItems. `CartItem` is an interface
which can be used in your application for your own CartItems and then simply use the same items with the SDK
###### Objective-C
```objectivec
[Emarsys.predict trackCartWithCartItems:<cartItems: NSArray<EMSCartItem *> *>];
```
###### Swift
```swift
Emarsys.predict.trackCart(withCartItems: <cartItems: Array<EMSCartItem>>)
```
#### 7.3 trackPurchase
To report a purchase event you should call `trackPurchase` with the items purchased and with an `orderId`
###### Objective-C
```objectivec
[Emarsys.predict trackPurchaseWithOrderId:<orderId: NSString>
                                    items:<cartItems: NSArray<EMSCartItem *> *>];
```
###### Swift
```swift
Emarsys.predict.trackPurchase(withOrderId: <orderId: String>, items: <cartItems: Array<EMSCartItem>>)
```
#### 7.4 trackItemView
If an item was viewed use the `trackItemView` method with an `itemId`.
###### Objective-C
```objectivec
[Emarsys.predict trackItemViewWithItemId:<itemId: NSString>];
```
###### Swift
```swift
Emarsys.predict.trackItemView(withItemId: <itemId: String>)
```
#### 7.5 trackCategoryView
When the user navigates between the categories you should call `trackCategoryView` in every navigation. Be aware to send `categoryPath`
in the required format. Please visit [Predict's documentation](https://dev.emarsys.com/v2/web-extend-command-reference "Predict documentation") for more information.
###### Objective-C
```objectivec
[Emarsys.predict trackCategoryViewWithCategoryPath:<categoryPath: NSString>];
```
###### Swift
```swift
Emarsys.predict.trackCategoryView(withCategoryPath:<categoryPath: String>)
```
#### 7.6 trackSearchTerm
To report search terms entered by the contact use `trackSearchTerm` method.
###### Objective-C
```objectivec
[Emarsys.predict trackSearchWithSearchTerm:<searchTerm: NSString>];
```
###### Swift
```swift
Emarsys.predict.trackSearch(withSearchTerm: <searchTerm: String>)
```
#### 7.7 trackCustomEvent
If you want to track custom events, the `trackCustomEvent` method should be used, where the `eventName` parameter is required, but the other attributes are optional.
###### Objective-C
```objectivec
[Emarsys trackCustomEventWithName:<eventName: NSString>
                  eventAttributes:<eventAttributes: NSDictionary<NSString, NSString>
                  completionBlock:^(NSError *error) {
                  }];
```
###### Swift
```swift
Emarsys.trackCustomEvent(withName: <eventName: String>, eventAttributes: <eventAttributes: NSDictionary<String, String>) { error in
}
```
### 8. DeepLink
In order to track deep links with the Emarsys SDK, you need to call `trackDeepLink` in your AppDelegate's `application:continueUserActivity:restorationHandler:` method.
###### Objective-C
```objectivec
-  (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
  restorationHandler:(void (^)(NSArray *__nullable restorableObjects))restorationHandler {
    return [Emarsys trackDeepLinkWith:userActivity sourceHandler:^(NSString *source) {
        NSLog([NSString stringWithFormat:@"Source url: %@", source]);
    }];
}
```
###### Swift
```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    return Emarsys.trackDeepLink(with: userActivity, sourceHandler: { url in
        if let source = url {
            print(source)
        }
    })
}
```
The (BOOL) return value of Emarsys.trackDeepLink indicates whether the UserActivity contained a Mobile Engage email deeplink and whether it was handled by the SDK.

The first parameter is the UserActivity that comes from the AppDelegate’s `application:continueUserActivity:restorationHandler:` method.

The second parameter is optional, it is a closure/block that provides the source Url that was extracted from the UserActivity.

For more information, read the [relevant iOS documentation.](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html#//apple_ref/doc/uid/TP40016308-CH12-SW1 "Support Universal Links")
