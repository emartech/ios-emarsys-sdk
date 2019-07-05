# PILOT VERSION

This SDK is still in Pilot phase, please only use if you have a pilot agreement contract in place!

If you are looking for our recommended SDK then please head to [Mobile Engage SDK](https://github.com/emartech/ios-mobile-engage-sdk.git "Mobile Engage SDK")

#### Contents
- [What is the Emarsys SDK?](#what-is-the-emarsys-sdk "What is EmarsysSDK?")
- [Why Emarsys SDK over Mobile Engage SDK?](#why-emarsys-sdk-over-mobile-engage-sdk "Why use EmarsysSDK")
    - [The workflow for linking/unlinking a contact to a device was too complex](#the-workflow-for-linkingunlinking-a-contact-to-a-device-was-too-complex "Contact workflow")
    - [The API was stateful and limited our scalability](#the-api-was-stateful-and-limited-our-scalability "Scalability")
    - [Swift first approach](#swift-first-approach "Swift first")
    - [Repetition of arguments](#repetition-of-arguments "Repetition of arguments")
    - [Unification of github projects](#unification-of-github-projects "Unification")
- [Setup](#setup "Setup")
    - [Installation with CocoaPods](#1-installation-with-cocoapods "CocoaPods")
    - [Requirements](#2-requirements "Requirements")
- [Documentation](https://github.com/emartech/ios-emarsys-sdk/wiki "Wiki")
- [DeepLink](https://github.com/emartech/ios-emarsys-sdk/wiki/deeplink "DeepLink")
- [Glossary](https://github.com/emartech/ios-emarsys-sdk/wiki/glossary "Glossary")
- [Migrate from MobileEngage](https://github.com/emartech/ios-emarsys-sdk/wiki/migrate-from-mobile-engage "Migration guide")
- [Rich Push Notifications](https://github.com/emartech/ios-emarsys-sdk/wiki/rich-push-notifications "Rich Push notifications")

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
[Emarsys setContactWithContactFieldValue:<contactFieldValue: NSString>

## Setup
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
> Wherever you see <TargetName> or anything similar in <> brackets, you should change those according to your own naming convention.

#### 1.3 Install Pods
After creating the Podfile, you need to execute the command below to download dependencies:
`pod install`
### 2. Requirements
* The iOS target should be iOS 11 or higher.
* In order to be able to send push messages to your app, you need to have certifications from Apple Push Notification service (APNs).

> `Note`
>
> For further informations about how to use our SDK please visit our [Documentation](https://github.com/emartech/ios-emarsys-sdk/wiki "Wiki")