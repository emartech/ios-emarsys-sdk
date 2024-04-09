
import Foundation
@testable import EmarsysSDK
import mimic

struct FakeSecureStorage: SecureStorage, Mimic {

    let fnPut = Fn<()>()
    let fnGet = Fn<Storable?>()
    
    func put<T>(item: T?, key: String, accessGroup: String? = nil) throws where T : Storable {
        return try fnPut.invoke(params: item, key, accessGroup)
    }
    
    func get<T>(key: String, accessGroup: String? = nil) throws -> T? where T : Storable {
        return try fnGet.invoke(params: key, accessGroup) as! T?
    }
    
    subscript<T>(key: String) -> T? where T: Storable {
        get {
            return try? get(key: key, accessGroup: nil)
        }
        set {
            try? put(item: newValue, key: key, accessGroup: nil)
        }
    }
    
}
