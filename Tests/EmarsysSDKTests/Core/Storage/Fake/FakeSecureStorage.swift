
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
    
}
