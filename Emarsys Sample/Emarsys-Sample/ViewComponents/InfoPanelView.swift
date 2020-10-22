//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI

struct InfoPanelView: View {
    
    @EnvironmentObject var loginData: LoginData
    @State var showMore: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                self.addLoginImage().frame(width: 30).multilineTextAlignment(.leading)
                if(self.loginData.isLoggedIn){
                    Text("Logged in as: ").bold()
                    Text("\(self.loginData.contactFieldValue)")
                } else {
                    Text("Logged out").bold()
                }
                
                Spacer()
            }
            
            if(self.loginData.isLoggedIn) {
                self.addAppcodeInformation()
            }
            if(!self.showMore){
                HStack {
                    Spacer()
                    Button(action: {self.showMore = true}) {
                        Text("show more").font(.system(size: 14)).foregroundColor(.gray)
                        Image(systemName: "arrowtriangle.down.fill").foregroundColor(.gray)
                    }.padding(.trailing)
                }
            }
            
            if(self.showMore) {
                HStack {
                    Image(systemName: "gear").frame(width: 30).multilineTextAlignment(.leading)
                    Text("HardwareId: ").bold()
                    Button(action: {
                        UIPasteboard.general.string = loginData.hwid
                    }) {
                        Text("\(loginData.hwid)")
                            .foregroundColor(Color(.label))
                    }
                }
                HStack {
                    Image(systemName: "flag").frame(width: 30).multilineTextAlignment(.leading)
                    Text("LanguageCode: ").bold()
                    Text("\(loginData.languageCode)")
                }
                HStack {
                    Image(systemName: "message").frame(width: 30).multilineTextAlignment(.leading)
                    Text("PushSetting: ").bold()
                }
                
                ForEach(Array(loginData.pushSettings.keys.enumerated()), id: \.element) { _, key in
                    HStack {
                        Text("\u{2022}").frame(width: 30).multilineTextAlignment(.leading)
                        Text("\(key.capitalized): \(loginData.pushSettings[key] ?? "")")
                    }
                }
                if(showMore) {
                    HStack {
                        Spacer()
                        Button(action: {self.showMore = false}) {
                            Text("show less").font(.system(size: 14)).foregroundColor(.gray)
                            Image(systemName: "arrowtriangle.up.fill").foregroundColor(.gray)
                        }.padding(.trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color.init(UIColor.lightGray).opacity(0.1))
        .cornerRadius(16)
    }
    
    func addLoginImage() -> Image {
        let iconName = self.loginData.isLoggedIn ? "person.fill" : "person"
        return Image(systemName: iconName)
    }
    
    func addAppcodeInformation() -> some View {
        return
            HStack {
                Image(systemName: "circle.grid.3x3").frame(width: 30).multilineTextAlignment(.leading)
                Text("AppCode: ").bold()
                Text("\(self.loginData.applicationCode)")
            }
    }
}

struct InfoPanelView_Previews: PreviewProvider {
    static var previews: some View {
        InfoPanelView().environmentObject(LoginData(isLoggedIn: true,
                                                    contactFieldValue: "test@test.com",
                                                    contactFieldId: "2545",
                                                    applicationCode: "EMS11-C3FD3",
                                                    merchantId: "testMerchantId"))
    }
}
