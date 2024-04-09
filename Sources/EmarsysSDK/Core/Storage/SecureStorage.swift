
import Foundation


protocol SecureStorage {
    
    func put<T: Codable>(item: T?, key: String, accessGroup: String?) throws
    
    func get<T: Codable>(key: String, accessGroup: String?) throws -> T?
    
    subscript<T: Codable>(key: String) -> T? {
        get set
    }
    
}
