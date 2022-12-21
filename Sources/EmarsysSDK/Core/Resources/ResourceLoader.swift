//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

protocol ResourceLoader {
    
    associatedtype Content: Decodable
    
    func resourceUrl(name: String, ext: String) throws -> URL
    
    func loadPlist(name: String) throws -> Content
    
}

extension ResourceLoader {

    func resourceUrl(name: String, ext: String) throws -> URL {
        guard let result = Bundle.module.url(forResource: name, withExtension:ext) else {
            throw Errors.resourceNotAvailable("resourceLoadingFailed".localized(with: name))
        }
        return result
    }

    func loadPlist(name: String) throws -> Content {
        do {
            let url = try resourceUrl(name: name, ext: "plist")
            let data = try Data(contentsOf: url)
            let propertyListDecoder = PropertyListDecoder()
            return try propertyListDecoder.decode(Content.self, from: data)
        } catch {
            throw Errors.resourceNotAvailable("resourceLoadingFailed".localized(with: name))
        }
    }
    
}
