
import Foundation

@SdkActor
class UUIDProvider: StringProvider {
    func provide() -> String {
        UUID().uuidString
    }
}
