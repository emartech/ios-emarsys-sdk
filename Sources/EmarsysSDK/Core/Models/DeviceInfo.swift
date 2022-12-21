//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct DeviceInfo: Decodable {

    let platform: String
    let applicationVersion: String
    let deviceModel: String
    let osVersion: String
    let sdkVersion: String
    let language: String
    let timezone: String
    let pushSettings: PushSettings
    
}

struct PushSettings: Decodable {
    let authorizationStatus: String
    let soundSetting: String
    let badgeSetting: String
    let alertSetting: String
    let notificationCenterSetting: String
    let lockScreenSetting: String
    let carPlaySetting: String
    let alertStyle: String
    let showPreviewsSetting: String
    let criticalAlertSetting: String
    let providesAppNotificationSettings: String
    let scheduledDeliverySetting: String
    let timeSensitiveSetting: String
}
