# PILOT VERSION

This SDK is still in Pilot phase, please only use if you have a pilot agreement contract in place!

If you are looking for our recommended SDK then please head to [Mobile Engage SDK](https://github.com/emartech/ios-mobile-engage-sdk.git "Mobile Engage SDK")

#### Contents
- [What is the Emarsys SDK?](#what-is-the-emarsys-sdk?)
- [Why Emarsys SDK over Mobile Engage SDK?](#why-emarsys-sdk-over-mobile-engage-sdk?)
    - [The workflow for linking/unlinking a contact to a device was too complex](#the-workflow-for-linking/unlinking-a-contact-to-a-device-was-too-complex)
    - [The API was stateful and limited our scalability](#the-api-was-stateful-and-limited-our-scalability)
    - [Swift first approach](#swift-first-approach)
    - [Repetition of arguments](#repetition-of-arguments)
    - [Unification of github projects](#unification-of-github-projects)
- [Documentation](#documentation)

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
### Documentation
> `Note`
>
> For further informations about how to use our SDK please visit our [Documentation](https://github.com/emartech/ios-emarsys-sdk/wiki "Wiki")