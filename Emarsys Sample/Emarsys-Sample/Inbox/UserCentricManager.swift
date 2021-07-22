//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDK

class UserCentricManager: ObservableObject, MessageManager {
    @Published var messages: [Message]
    var needsRefresh: Bool {
        messages.count == 0
    }
    var messagesPublished: Published<[Message]> { _messages }
    var messagesPublisher: Published<[Message]>.Publisher { $messages }
    
    required init(messages: [Message]) {
        self.messages = messages
    }
    
    func fetchMessages() {
        Emarsys.messageInbox.fetchMessages { status, error in
            if let error = error {
                print(error)
            } else if let status = status {
                self.messages = self.convertNotificationsToMessages(notifications: status.messages)
            }
        }
    }
    
    func convertNotificationsToMessages(notifications: [EMSMessage]) -> [Message] {
        var messages: [Message] = []
        for notification in notifications {
            let message = Message(title: notification.title, body: notification.body, imageUrl: notification.imageUrl)
            messages.append(message)
        }
        return messages
    }
}
