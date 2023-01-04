//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol State {
        
    var name: String {
        get
    }
    
    var nextStateName: String? {
        set get
    }
    
    func prepare()
    
    func active() async throws
    
    func relax()
    
}

@SdkActor
protocol StateContext {
    
    var stateLifecycle: (name: String, lifecycle: StateLifecycle)? { get }
    
}

@SdkActor
class StateMachine: StateContext {
    
    @Published
    var stateLifecycle: (name: String, lifecycle: StateLifecycle)?
    
    private var currentState: State
    private var states: [String: State]
    
    init(states: [State], currentState: State) {
        self.states = [String: State]()
        self.currentState = currentState
        states.forEach() { self.states[$0.name] = $0 }
    }
    
    func activate() async throws {
        stateLifecycle = (currentState.name, .prepare)
        currentState.prepare()
        stateLifecycle = (currentState.name, .activate)
        try await currentState.active()
        currentState.relax()
        stateLifecycle = (currentState.name, .relaxed)
        
        guard let stateName = currentState.nextStateName else {
            return
        }
        guard let state = states[stateName] else {
            throw Errors.switchToStateFailed("switchToStateFailed".localized(with: stateName))
        }
        currentState = state
        try await activate()
    }
}

enum StateLifecycle {
    case prepare
    case activate
    case relaxed
}
