//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI
import EmarsysSDK

struct InAppView: View {
    
    @State var customEventName = ""
    @State var viewId = "ia"
    @State var isInappPaused: Bool = false
    @State var showingEmptyEventNameAlert = false
    @State var isHidden: Bool = false
    @State var showAppEventAlert = false
    @State var showCompletionAlert = false
    @State var appeventName : String = ""
    @State var appEventPayload: Dictionary<String, Any?> = Dictionary()
    @State var completion: String = ""
    @State var viewIds = ["ia"]
    
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
                }.alert(isPresented: $showingEmptyEventNameAlert) {
                    Alert(title: Text("Missing eventName"),
                          message: Text("eventName should not be empty if you want to track a custom event"),
                          dismissButton: .default(Text("Got it!")))
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
                    TextField("viewId", text: $viewId) {
                        UIApplication.shared.endEditing()
                    }
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: self.showInlineInApp) {
                        Text("Show")
                    }
                }
                .padding()
                
                ForEach(Array(viewIds.enumerated()), id: \.element) { _, key in
                    if(!isHidden) {
                        InlineInAppView(viewId: "ia",
                                        onClose: {
                                            self.isHidden = true
                                        },
                                        onEvent: { name, payload in
                                            self.appeventName = name
                                            self.appEventPayload = payload ?? Dictionary()
                                            self.showAppEventAlert = true
                                        },
                                        onCompletion: { error in
                                            if(error == nil) {
                                                self.completion = "completed"
                                            } else {
                                                self.completion = error.debugDescription
                                            }
                                        })
                    }
                }
                .alert(isPresented: $showAppEventAlert) {
                    Alert(title: Text(self.appeventName), message: Text(self.appEventPayload.description), dismissButton: .cancel())
                }
                .alert(isPresented: $showCompletionAlert) {
                    Alert(title: Text("CompletionBlock"), message: Text(self.completion), dismissButton: .cancel())
                }
                
                Spacer()
            }
        }
    }
    
    func trackCustomEventButtonClicked() {
        if(self.customEventName.isEmpty) {
            self.showingEmptyEventNameAlert = true
        } else {
            Emarsys.trackCustomEvent(withName: self.customEventName, eventAttributes: nil) { error in
                if(error == nil) {
                    print("succesful eventName tracking")
                } else {
                    print("something went wrong")
                }
            }
        }
    }
    
    func showInlineInApp() {
        viewIds.append(viewId)
    }
    
    func addInlineInAppView() -> InlineInAppView {
        InlineInAppView(viewId: "ia",
                        onClose: {
                            self.isHidden = true
                        })
        
    }
}

struct InAppView_Previews: PreviewProvider {
    static var previews: some View {
        InAppView()
    }
}
