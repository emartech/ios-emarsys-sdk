//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

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

    override func handleEvent(_ eventName: String, payload: [String: NSObject]?) {
        super.handleEvent(eventName, payload: payload)
        let alertController = UIAlertController(title: eventName, message: "\(String(describing: payload))", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .destructive, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        print("EVENT_NAME: \(eventName), PAYLOAD: \(payload ?? [:])")
        
        let content = UNMutableNotificationContent()
        content.title = eventName
        content.body = payload!.description
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        NotificationCenter.default.post(name: NotificationNames.pushTokenArrived.asNotificationName(), object: nil, userInfo: ["push_token": deviceToken])
    }
}
