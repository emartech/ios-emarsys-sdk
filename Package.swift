// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "EmarsysSDK",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "EmarsysSDKLibrary",
            targets: ["EmarsysSDK"]),
        .library(
            name: "EmarsysNotificationExtensionLibrary",
            targets: ["EmarsysSDK"]),
    ],
    targets: [
        .target(
            name: "EmarsysSDK",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            cSettings: [
                .headerSearchPath("./Private/")
            ]
        )
    ]
)
