//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension URL {
    
    mutating func add(queryParameters: [String: String]) {
        let allowedCharacters = CharacterSet(charactersIn: "\"`;/?:^%#@&=$+{}<>,|\\ !'()*[]").inverted
        let queryItems = queryParameters.map { name, value in
            URLQueryItem(name: name.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!, value: value.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!)
        }
        self.append(queryItems: queryItems)
    }
    
}
