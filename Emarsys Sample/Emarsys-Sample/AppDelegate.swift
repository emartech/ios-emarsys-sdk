//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import UIKit
import EmarsysSDK

@UIApplicationMain
class AppDelegate: EMSAppDelegate {

    override func provideEMSConfig() -> EMSConfig! {
        return EMSConfig.make { builder in
            builder.setMerchantId("1428C8EE286EC34B")
            builder.setContactFieldId(2575)
            #if DEBUG
                builder.setMobileEngageApplicationCode("EMS11-C3FD3")
            #else
                builder.setMobileEngageApplicationCode("EMS4C-9A869")
            #endif
        }
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        super.application(application, didFinishLaunchingWithOptions: launchOptions)
        NotificationCenter.default.addObserver(forName: .deviceDidShakeNotification, object: nil, queue: nil) { notification in
            print("device did shake")
        }
        return true
    }

    override func handleEvent(_ eventName: String, payload: [String: NSObject]?) {
//        super.handleEvent(eventName, payload: payload)
//        let alertController = UIAlertController(title: eventName, message: "\(String(describing: payload))", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Close", style: .destructive, handler: { (action) in
//            alertController.dismiss(animated: true, completion: nil)
//        }))
//
//        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
//        print("EVENT_NAME: \(eventName), PAYLOAD: \(payload ?? [:])")
//
//        let content = UNMutableNotificationContent()
//        content.title = eventName
//        content.body = payload!.description
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        Emarsys.push.setPushToken(deviceToken)
        NotificationCenter.default.post(name: .pushTokenReceived, object: nil, userInfo: ["push_token": deviceToken])
    }

}

extension NSNotification.Name {
    public static let pushTokenReceived = NSNotification.Name("DidReceivePushToken")
}
