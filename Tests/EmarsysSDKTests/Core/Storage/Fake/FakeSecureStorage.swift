
import Foundation
@testable import EmarsysSDK

struct FakeSecureStorage: SecureStorage, Faked {

    var faker = Faker()
    
    let put = "put"
    let get = "get"
    
    func put<T>(item: T?, key: String, accessGroup: String?) throws where T : Storable {
        return try handleCall(\.put, params: item, key, accessGroup)
    }
    
    func get<T>(key: String, accessGroup: String?) throws -> T? where T : Storable {
        return try handleCall(\.get, params: key, accessGroup)
    }
    
    subscript<T>(key: String, accessGroup: String? = nil) -> T? where T: Storable {
        get {
            return try? get(key: key, accessGroup: accessGroup)
        }
        set {
            try? put(item: newValue, key: key, accessGroup: accessGroup)
        }
    }
    
}
