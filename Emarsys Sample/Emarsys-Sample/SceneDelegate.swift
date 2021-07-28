//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import UIKit
import SwiftUI
import EmarsysSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    @StoredValue<String>(key: "contactFieldValue")
    var contactFieldValue: String?
    
    @StoredValue<String>(key: "contactFieldId")
    var contactFieldId
    
    @StoredValue<String>(key: "applicationCode")
    var applicationCode
    
    @StoredValue<String>(key: "merchantId")
    var merchantId
    
    @StoredValue<Bool>(key: "isLoggedIn")
    var isLoggedIn
    
    var loginData: LoginData?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        // Create the SwiftUI view that provides the window contents.
        let configUserDefaults = UserDefaults(suiteName: "com.emarsys.sampleConfig")
        self.contactFieldId = configUserDefaults?.string(forKey: ConfigUserDefaultsKey.contactFieldId.rawValue)
        self.applicationCode = configUserDefaults?.string(forKey: ConfigUserDefaultsKey.applicationCode.rawValue)
        self.merchantId = configUserDefaults?.string(forKey: ConfigUserDefaultsKey.merchantId.rawValue)
        
        let pushToken = Emarsys.push.pushToken()?.reduce("", {$0 + String(format: "%2X", $1)}).uppercased()
        let sdkVersion = Emarsys.config.sdkVersion()
        
        loginData = LoginData(isLoggedIn: self.isLoggedIn ?? false,
                              contactFieldValue: self.contactFieldValue ?? nil,
                              contactFieldId: self.contactFieldId ?? Emarsys.config.contactFieldId().stringValue,
                              applicationCode: self.applicationCode ?? Emarsys.config.applicationCode(),
                              merchantId: self.merchantId ?? Emarsys.config.merchantId(),
                              hwId: Emarsys.config.hardwareId(),
                              languageCode: Emarsys.config.languageCode(),
                              pushSettings: Emarsys.config.pushSettings() as? Dictionary<String, String> ?? [:],
                              pushToken: pushToken ?? "",
                              sdkVersion: sdkVersion
        )
        let signInWithAppleDelegate = SignInWithAppleDelegate(loginData: loginData!)
        
        let contentView = ContentView()
            .environmentObject(loginData!)
            .environmentObject(signInWithAppleDelegate)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)

            self.window = window
            window.makeKeyAndVisible()
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let components = URLComponents(string: url.absoluteString)
        var appCode: String?
        var merchantId: String?
        var contactFieldId: String?
        components?.queryItems?.forEach({ queryItem in
            switch queryItem.name {
            case "appCode":
                appCode = queryItem.value!
            case "merchantId":
                merchantId = queryItem.value!
            case "contactFieldId":
                contactFieldId = queryItem.value!
            default:
                print(queryItem)
            }
        })
        if let merchantId = merchantId {
            Emarsys.config.changeMerchantId(merchantId: merchantId)
            self.loginData!.merchantId = merchantId
        }
        if let appCode = appCode {
            Emarsys.config.changeApplicationCode(applicationCode: appCode)
            self.loginData?.applicationCode = appCode
        }
    }
}


struct SceneDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
