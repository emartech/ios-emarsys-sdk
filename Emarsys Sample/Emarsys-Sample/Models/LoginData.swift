//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation

class LoginData: ObservableObject {
    
    @Published var isLoggedIn : Bool
    @Published var contactFieldValue: String
    @Published var contactFieldId : String
    @Published var applicationCode : String
    @Published var merchantId : String
    @Published var hwid : String = "hardwareId"
    @Published var languageCode: String = "en-US"
    @Published var pushSettings: Dictionary<String, String> = ["notificationEnabled": "true",
                                                               "authorizationStatus": "authorized",
                                                               "soundSettings": "soundsetting"]
    
    init(isLoggedIn: Bool = false,
         contactFieldValue: String = "",
         contactFieldId: String = "",
         applicationCode: String = "",
         merchantId: String = "",
         hwId: String = "",
         languageCode: String = "",
         pushSettings: Dictionary<String, String> = [:]) {
        self.isLoggedIn = isLoggedIn
        self.contactFieldValue = contactFieldValue
        self.contactFieldId = contactFieldId
        self.applicationCode = applicationCode
        self.merchantId = merchantId
    }

}
