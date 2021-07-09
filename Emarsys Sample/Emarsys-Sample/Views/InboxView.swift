//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var userCentricManager: UserCentricManager = UserCentricManager(messages: [])
    
    @State private var inboxType = 0
    var inboxTypes = ["User Centric", "Device Centric"]
    
    var body: some View {
        VStack {
            if userCentricManager.needsRefresh {
                Text("Pull down to refresh")
            }
            GeometryReader { geometry in
                PullToRefreshView(width: geometry.size.width, height: geometry.size.height, manager: userCentricManager).onAppear(perform: {
                    userCentricManager.fetchMessages()
                })
                Spacer()
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
