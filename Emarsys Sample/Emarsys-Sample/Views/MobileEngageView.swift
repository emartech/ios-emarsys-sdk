//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI
import EmarsysSDK


struct MobileEngageView: View {
    @State var sid: String = ""
    @State var customEventName = ""
    @State var customEventPayload: String? = """
    {"eventAttributeKey1":"value1",
     "eventAttributeKey2":"value2"}
    """
    
    @State var showingEmptySidAlert = false
    @State var showingEmptyEventNameAlert = false
    
    @State var messageText = ""
    @State var messageColor: UIColor = .green
    @State var showTrackOpenMessage: Bool = false
    @State var showTrackCustomEventMessage: Bool = false
    
    
    var body: some View {
        VStack(spacing: 5) {
            
            if (self.showTrackOpenMessage) {
                Text(self.messageText).foregroundColor(Color(self.messageColor))
            }
            HStack() {
                Spacer()
                FloatingTextField(title: "sid", text:$sid)
                
                Button(action: self.trackMessageOpenButtonClicked) {
                    Text("Track")
                }.alert(isPresented: $showingEmptySidAlert) {
                    Alert(title: Text("Invalid input"),
                          message: Text("sid should not be empty if you want to track a message open"),
                          dismissButton: .default(Text("Got it!")))
                }
                
            }
            .padding()
            
            Divider().background(Color.black).padding(.horizontal)
            
            VStack(spacing: 15) {
                
                if (self.showTrackCustomEventMessage) {
                    Text(self.messageText).foregroundColor(Color(self.messageColor))
                }
                
                FloatingTextField(title: "customEventName", text: $customEventName)
                
                MultilineTextView(text: self.customEventPayload?.description ?? "")
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1)
                            .opacity(0.2)
                    )
                HStack {
                    Spacer()
                    
                    Button(action: self.trackCustomEventButtonClicked) {
                        Text("Track")
                    }.alert(isPresented: $showingEmptyEventNameAlert) {
                        Alert(title: Text("Missing eventName"),
                              message: Text("eventName should not be empty if you want to track a custom event"),
                              dismissButton: .default(Text("Got it!")))
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    func trackMessageOpenButtonClicked() {
        if(self.sid.isEmpty) {
            self.showingEmptySidAlert = true
        } else {
            let userInfo = ["u": "{\"sid\":\"\(self.sid)\"}"]
            Emarsys.push.trackMessageOpen(userInfo: userInfo) { error in
                if (error == nil) {
                    showMessage(successful: true)
                } else {
                    showMessage(successful: false)
                }
            }
            self.showTrackOpenMessage = true
        }
    }
    
    func trackCustomEventButtonClicked() {
        if(self.customEventName.isEmpty) {
            self.showingEmptyEventNameAlert = true
        } else {
            let eventAttributes = self.convertEventPayloadToJson()
            Emarsys.trackCustomEvent(withName: self.customEventName, eventAttributes: eventAttributes) { error in
                if(error == nil) {
                    showMessage(successful: true)
                } else {
                    showMessage(successful: false)
                }
                self.showTrackCustomEventMessage = true
            }
        }
    }
    
    func convertEventPayloadToJson() -> Dictionary<String, String>? {
        var eventAttributes: [String: String]?
        if let attributes = self.customEventPayload {
            if let data = attributes.data(using: .utf8) {
                            do {
                                eventAttributes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
        }
        return eventAttributes
    }
    
    func showMessage(successful: Bool) {
        if(successful) {
            self.messageText = "Successful"
            self.messageColor = .green
        } else {
            self.messageText = "Something went wrong"
            self.messageColor = .red
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        hideMessage()
    }
    
    func hideMessage() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.showTrackOpenMessage = false
            self.showTrackCustomEventMessage = false
        }
    }
}


struct MobileEngageView_Previews: PreviewProvider {
    static var previews: some View {
        MobileEngageView()
    }
}
