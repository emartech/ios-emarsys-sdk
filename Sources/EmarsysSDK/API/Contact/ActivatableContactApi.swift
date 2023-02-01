

import Foundation

protocol ActivatableContactApi: ContactApi {
    
    func activated() async throws
}

extension ActivatableContactApi {
    func activated() async throws {
        
    }
}
