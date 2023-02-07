
import Foundation

@SdkActor
struct UuidStringProvider: UuidProvider {
    
    func provide() async -> String {
        UUID().uuidString
    }
}
