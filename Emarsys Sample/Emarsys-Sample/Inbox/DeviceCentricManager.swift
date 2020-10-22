//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import EmarsysSDK

class DeviceCentricManager: ObservableObject, MessageManager {
    @Published var messages: [Message]
    var messagesPublished: Published<[Message]> { _messages }
    var messagesPublisher: Published<[Message]>.Publisher { $messages }
    
    required init(messages: [Message]) {
        self.messages = messages
    }
    
    func fetchMessages() {
        Emarsys.inbox.fetchNotifications { status, error in
            if let error = error {
                print(error)
            } else if let status = status {
                self.messages = self.convertNotificationsToMessages(notifications: status.notifications)
            }
        }
    }
    
    func convertNotificationsToMessages(notifications: [EMSNotification]) -> [Message] {
        var messages: [Message] = []
        for notification in notifications {
            let message = Message(title: notification.title, body: notification.body)
            messages.append(message)
        }
        return messages
    }
}
