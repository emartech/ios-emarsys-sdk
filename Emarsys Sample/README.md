# Emarsys SDK Sample app

We created a sample app to demonstrate the basic functionality of our SDK, and to give an example how to integrate Emarsys in your application.

## Install CocoaPods

CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries.
You can install it with the following command:

`$ gem install cocoapods`


## Getting started with the released SDK

1. Clone the project from [here](https://github.com/emartech/ios-emarsys-sdk)
2. Run `pod install` in the terminal in the root directory of the repository
3. Run `pod install` in the terminal in the `Emarsys Sample` directory of the repository

> __`Note`__
>  
>  These steps are working with the currently released version of the SDK. Please be aware that the master branch might not be compatible with it!


## Getting started with the current development state of the SDK

1. Clone the project from [here](https://github.com/emartech/ios-emarsys-sdk)
2. Run `export DEV=true` in your terminal
3. Run `pod install` in the terminal in the root directory of the repository
4. Run `pod install` in the terminal in the `Emarsys Sample` directory of the repository

> __`Note`__
>  
>  Please keep in mind that this may contain unstable/in-development features which are not currently supported to use in production.

You can check which version of the SDK is in use as a dependency in the `Podfile.lock` file. If it is not the wanted version, just run `pod deintegrate` in both of the root and `Emarsys Sample` directories and start the process over.

 