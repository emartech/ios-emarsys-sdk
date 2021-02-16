//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var loginData: LoginData
    
    var body: some View {
        VStack {
            InfoPanelView().environmentObject(loginData).padding()
        
            TabView {
                DashboardView()
                    .environmentObject(loginData)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Dashboard")
                    }
                MobileEngageView()
                    .tabItem {
                        Image(systemName: "phone.fill")
                        Text("MobileEngage")
                    }
                InboxView()
                    .tabItem {
                        Image(systemName: "envelope.fill")
                        Text("Inbox")
                    }
                PredictView()
                    .tabItem {
                        Image(systemName: "ant.fill")
                        Text("Predict")
                    }
                InAppView()
                    .tabItem {
                        Image(systemName: "chevron.left.slash.chevron.right")
                        Text("In-app")
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(LoginData(isLoggedIn: true,
                                                  contactFieldValue: "test@test.com",
                                                  contactFieldId: "2545",
                                                  applicationCode: "EMS11-C3FD3",
                                                  merchantId: "testMerchantId"))
    }
}
