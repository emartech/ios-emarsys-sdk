
import Foundation


protocol SecureStorage {
    
    func put<T: Storable>(item: T?, key: String, accessGroup: String?) throws
    
    func get<T: Storable>(key: String, accessGroup: String?) throws -> T?
    
}
