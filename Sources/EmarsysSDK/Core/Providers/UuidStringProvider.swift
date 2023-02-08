
import Foundation

@SdkActor
struct UUIDProvider: StringProvider {
    
    func provide() async -> String {
        UUID().uuidString
    }
}
