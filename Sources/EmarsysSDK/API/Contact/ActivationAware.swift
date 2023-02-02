

import Foundation

protocol ActivationAware {
    
    func activated() async throws
}

extension ActivationAware {
    func activated() async throws {
        
    }
}
