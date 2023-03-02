//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import SwiftUI

@main
struct HostAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
