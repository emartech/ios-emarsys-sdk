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
    
    func start() async {
        await pathMonitor.updateHandler(SdkActor.shared) { [unowned self] path in
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

extension NWPathMonitor {
    
    func updateHandler(_ act: isolated Actor, _ operation: @escaping (_ newPath: NWPath) -> () ) async {
        pathUpdateHandler = { path in
            operation(path)
        }
    }
    
}
