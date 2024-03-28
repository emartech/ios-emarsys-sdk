//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

protocol ActionModellable: Codable {
    var type: String { get }
}

enum ActionModel: Codable {
    case appEvent(AppEventActionModel)
    case badgeCount(BadgeCountActionModel)
    case copyToClipboard(CopyToClipboardActionModel)
    case customEvent(CustomEventActionModel)
    case dismiss(DismissActionModel)
    case openExternalUrl(OpenExternalURLActionModel)
    case requestPushPermission(RequestPushPermissionActionModel)
    
    enum CodingKeys: CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case Constants.ActionTypes.appEvent:
            self = .appEvent(try AppEventActionModel(from: decoder))
        case Constants.ActionTypes.badgeCount:
            self = .badgeCount(try BadgeCountActionModel(from: decoder))
        case Constants.ActionTypes.copyToClipboard:
            self = .copyToClipboard(try CopyToClipboardActionModel(from: decoder))
        case Constants.ActionTypes.customEvent:
            self = .customEvent(try CustomEventActionModel(from: decoder))
        case Constants.ActionTypes.dismiss:
            self = .dismiss(try DismissActionModel(from: decoder))
        case Constants.ActionTypes.openExternalURL:
            self = .openExternalUrl(try OpenExternalURLActionModel(from: decoder))
        case Constants.ActionTypes.requestPushPermission:
            self = .requestPushPermission(try RequestPushPermissionActionModel(from: decoder))
        default:
            throw Errors.TypeError.decodingFailed(type: type)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        let _ = encoder.singleValueContainer()
        switch self {
        case .appEvent(let model):
            try model.encode(to: encoder)
        case .badgeCount(let model):
            try model.encode(to: encoder)
        case .copyToClipboard(let model):
            try model.encode(to: encoder)
        case .customEvent(let model):
            try model.encode(to: encoder)
        case .dismiss(let model):
            try model.encode(to: encoder)
        case .openExternalUrl(let model):
            try model.encode(to: encoder)
        case .requestPushPermission(let model):
            try model.encode(to: encoder)
        }
    }
    
}
