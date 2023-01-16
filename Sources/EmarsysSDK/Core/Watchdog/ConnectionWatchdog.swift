//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import Network

@SdkActor
class ConnectionWatchdog {
    
    @Published
    var connectionStatus: ConnectionStatus = .noConnection
    
    let pathMonitor = NWPathMonitor()
    
    func start() {
        pathMonitor.pathUpdateHandler = { [unowned self] path in
            if path.status == .satisfied && path.usesInterfaceType(.wifi) {
                connectionStatus = .wifi
            } else if path.status == .satisfied && path.usesInterfaceType(.cellular) {
                connectionStatus = .cellular
            } else {
                connectionStatus = .noConnection
            }
        }
        
        pathMonitor.start(queue: DispatchQueue(label: "EmarsysSdk - Watchdog"))
    }
    
}
