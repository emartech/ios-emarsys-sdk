//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

protocol ResourceLoader {
    
    func resourceUrl(name: String, ext: String) throws -> URL
    
    func loadPlist<T>(name: String) throws -> T where T: Decodable
    
}

extension ResourceLoader {

    func resourceUrl(name: String, ext: String) throws -> URL {
        guard let result = Bundle.module.url(forResource: name, withExtension:ext) else {
            throw Errors.resourceLoadingFailed(resource: name)
        }
        return result
    }

    func loadPlist<T>(name: String) throws -> T where T: Decodable {
        do {
            let url = try resourceUrl(name: name, ext: "plist")
            let data = try Data(contentsOf: url)
            let propertyListDecoder = PropertyListDecoder()
            return try propertyListDecoder.decode(T.self, from: data)
        } catch {
            throw Errors.resourceLoadingFailed(resource: name)
        }
    }
    
}
