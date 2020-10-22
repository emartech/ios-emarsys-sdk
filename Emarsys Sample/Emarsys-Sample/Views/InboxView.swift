//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var deviceCentricManager: DeviceCentricManager = DeviceCentricManager(messages: [])
    @ObservedObject var userCentricManager: UserCentricManager = UserCentricManager(messages: [])
    
    @State private var inboxType = 0
    var inboxTypes = ["User Centric", "Device Centric"]
    
    var body: some View {
        VStack {
            Picker(selection: $inboxType, label: Text("Inbox type to view")) {
                ForEach(0..<inboxTypes.count) { index in
                    Text(self.inboxTypes[index]).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            GeometryReader { geometry in
                if(inboxType == 0) {
                    PullToRefreshView(width: geometry.size.width, height: geometry.size.height, manager: userCentricManager).onAppear(perform: {
                        userCentricManager.fetchMessages()
                    })
                } else {
                    PullToRefreshView(width: geometry.size.width, height: geometry.size.height, manager: deviceCentricManager).onAppear(perform: {
                        deviceCentricManager.fetchMessages()
                    })
                }
            }
            Spacer()
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
