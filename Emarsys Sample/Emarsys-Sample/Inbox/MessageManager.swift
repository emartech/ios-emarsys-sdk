//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import EmarsysSDK

import Foundation

protocol MessageManager : ObservableObject {
    var messages: [Message] { get }
    var messagesPublished: Published<[Message]> { get }
    var messagesPublisher: Published<[Message]>.Publisher { get }
    
    func fetchMessages()
    init(messages: [Message])
}
