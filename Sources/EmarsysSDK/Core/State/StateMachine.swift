//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
class StateMachine: StateContext {
    
    @Published
    var stateLifecycle: (name: String, lifecycle: StateLifecycle)?
    
    private let states: [State]
    
    init(states: [State]) {
        self.states = states
    }
    
    func activate() async throws {
        for state in states {
            stateLifecycle = (state.name, .prepare)
            state.prepare()
            stateLifecycle = (state.name, .activate)
            try await state.active()
            state.relax()
            stateLifecycle = (state.name, .relaxed)
        }
    }
}
