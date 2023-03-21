//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct GenericAction: Codable {
    let type: String
    let url: String?
    let name: String?
    let payload: [String: String]?
    let method: String?
    let value: Int?
    let text: String?
}

extension GenericAction {
    
    func getSafeName() throws -> String {
        guard let name = self.name else {
            throw Errors.preconditionFailed(message: "Action name must not be nil")
        }
        return name
    }
    
    func getSafeURL() throws -> URL {
        guard let urlString = self.url else {
            throw Errors.preconditionFailed(message: "Action URL must not be nil")
        }
        guard let url = URL(string: urlString) else {
            throw Errors.preconditionFailed(message: "Action URL must be valid")
        }
        return url
    }
    
    func getSafeMethod() throws -> String {
        guard let method = self.method else {
            throw Errors.preconditionFailed(message: "Action method must not be nil")
        }
        return method
    }
    
    func getSafeValue() throws -> Int {
        guard let value = self.value else {
            throw Errors.preconditionFailed(message: "Action value must not be nil")
        }
        return value
    }
    
    func getSafeText() throws -> String {
        guard let text = self.text else {
            throw Errors.preconditionFailed(message: "Action text must not be nil")
        }
        return text
    }
}
