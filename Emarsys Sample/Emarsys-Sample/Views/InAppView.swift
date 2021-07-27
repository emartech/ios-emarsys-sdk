//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI
import EmarsysSDK

struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text?
    var dismissButton: Alert.Button?
}

struct InAppView: View {
    
    @State var customEventName = ""
    @State var viewId = "ia"
    @State var isInappPaused: Bool = false
    @State var viewIds = ["ia": false]
    @State var alertItem: AlertItem?
    
    var body: some View {
        VStack {
            Text("In-app").bold()
            HStack {
                TextField("customEventName", text: $customEventName) {
                    UIApplication.shared.endEditing()
                }
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: self.trackCustomEventButtonClicked) {
                    Text("Track")
                }
            }
            .padding()
            
            HStack {
                Text("Paused")
                Toggle("Paused", isOn: $isInappPaused).labelsHidden().onTapGesture {
                    if(self.isInappPaused) {
                        Emarsys.inApp.pause()
                    } else {
                        Emarsys.inApp.resume()
                    }
                }
            }
            
            Divider().background(Color.black).padding(.horizontal)
            
            VStack {
                Text("Inline in-app").bold()
                HStack {
                    TextField("viewId", text: $viewId, onCommit:  {
                        UIApplication.shared.endEditing()
                    })
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: self.showInlineInApp) {
                        Text("Show")
                    }
                }
                .padding()
                
                ForEach(Array(viewIds.keys.enumerated()), id: \.element) { _, key in
                    if(!(viewIds[key]!)) {
                        InlineInAppView(viewId: key,
                                        onClose: {
                                            viewIds[key] = true
                                        },
                                        onEvent: { name, payload in
                                            self.alertItem = AlertItem(title: Text(name),
                                                                       message: Text(payload?.description ?? ""),
                                                  dismissButton: .cancel())
                                        },
                                        onCompletion: { error in
                                            if error != nil {
                                                self.alertItem = AlertItem(title: Text(error.debugDescription),
                                                      dismissButton: .cancel())
                                            }
                                        })
                    }
                }
                Spacer()
            }
        }
        .alert(item: $alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
    }
    
    func trackCustomEventButtonClicked() {
        if(self.customEventName.isEmpty) {
            self.alertItem = AlertItem(title: Text("Missing eventName"),
                  message: Text("eventName should not be empty if you want to track a custom event"),
                  dismissButton: .default(Text("Got it!")))
        } else {
            Emarsys.trackCustomEvent(eventName: self.customEventName, eventAttributes: nil) { error in
                if(error == nil) {
                    print("succesful eventName tracking")
                } else {
                    print("something went wrong")
                }
            }
        }
    }
    
    func showInlineInApp() {
        viewIds[viewId] = false
    }

}

struct InAppView_Previews: PreviewProvider {
    static var previews: some View {
        InAppView()
    }
}
