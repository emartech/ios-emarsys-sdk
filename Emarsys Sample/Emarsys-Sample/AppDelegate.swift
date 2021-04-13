//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import UIKit
import EmarsysSDK

@UIApplicationMain
class AppDelegate: EMSAppDelegate {
    
    override func provideEMSConfig() -> EMSConfig! {
        let userDefaults = UserDefaults.init(suiteName: "com.emarsys.sampleConfig")
        return EMSConfig.make { builder in
            if let appCode = userDefaults?.string(forKey: ConfigUserDefaultsKey.applicationCode.rawValue) {
                builder.setMobileEngageApplicationCode(appCode)
                builder.enableConsoleLogLevels([EMSLogLevel.basic, EMSLogLevel.error, EMSLogLevel.info, EMSLogLevel.debug])
            }
            
            if let contactFieldId = userDefaults?.string(forKey: ConfigUserDefaultsKey.contactFieldId.rawValue) {
                let contactFieldIdInt = Int(contactFieldId)
                if(contactFieldIdInt != nil) {
                    builder.setContactFieldId(NSNumber(value: contactFieldIdInt!))
                }
            }
            
            if let merchantId = userDefaults?.string(forKey: ConfigUserDefaultsKey.merchantId.rawValue) {
                builder.setMerchantId(merchantId)
            }
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
        Emarsys.push.setPushToken(deviceToken)
        NotificationCenter.default.post(name: .pushTokenReceived, object: nil, userInfo: ["push_token": deviceToken])
    }
}

extension NSNotification.Name {
    public static let pushTokenReceived = NSNotification.Name("DidReceivePushToken")
}
