//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

import UIKit
import UserNotifications
import EmarsysSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, EMSEventHandler {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window?.tintColor = UIColor(red: 101 / 255.0, green: 151 / 255.0, blue: 207 / 255.0, alpha: 1.0)


        let config = EMSConfig.make { builder in
            builder.setExperimentalFeatures([INAPP_MESSAGING, USER_CENTRIC_INBOX]);
            builder.setMerchantId("1428C8EE286EC34B")
            builder.setContactFieldId(3)
            builder.setMobileEngageApplicationCode("EMSA1-927A9", applicationPassword: "kQ8qXPzCuzzXZ9jTnuRT09zcv6aKsYf0")
        }
        Emarsys.setup(with: config)
        Emarsys.inApp.eventHandler = self

        application.registerForRemoteNotifications()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                print(granted, error ?? "no error")
                if (granted) {
                    UNUserNotificationCenter.current().delegate = Emarsys.notificationCenterDelegate
                }
            }
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil))
        }
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return Emarsys.trackDeepLink(with: userActivity, sourceHandler: { url in
            print(url)
        })
    }

    func handleEvent(_ eventName: String, payload: [String: NSObject]?) {
        print(eventName, payload);
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Emarsys.push.setPushToken(deviceToken)
        NotificationCenter.default.post(name: NotificationNames.pushTokenArrived.asNotificationName(), object: nil, userInfo: ["push_token": deviceToken])
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Emarsys.push.trackMessageOpen(userInfo: userInfo)
    }

}
