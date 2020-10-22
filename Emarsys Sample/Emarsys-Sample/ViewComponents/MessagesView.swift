//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import SwiftUI

struct MessagesView<Manager>: View  where Manager: MessageManager {
    @ObservedObject var manager: Manager
    
    var body: some View {
        List(manager.messages) { message in
            HStack {
                if (message.imageUrl != nil) {
                    ImageView(withURL: message.imageUrl!)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(message.title)
                    }
                    HStack {
                        Text(message.body)
                        Spacer()
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .shadow(radius: 1)
            .padding([.horizontal, .vertical], 5)
        }
    }
}

