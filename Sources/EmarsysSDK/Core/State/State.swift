//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
protocol State {
    
    var context: StateContext? {
        set get
    }
    
    var name: String {
        get
    }
    
    func prepare()
    
    func activate() async
    
    func relax()
    
}

@SdkActor
protocol StateContext {
    
    func switchTo(stateName: String) async throws
    
}

@SdkActor
class StateMachine: StateContext {
    
    var states: [String: State]
    var currentState: State
    
    init(states: [State], currentState: State) {
        self.states = [String: State]()
        self.currentState = currentState
        self.currentState.context = self
        states.forEach() { self.states[$0.name] = $0 }
    }
    
    func switchTo(stateName: String) async throws {
        guard let state = states[stateName] else {
            throw Errors.switchToStateFailed("switchToStateFailed".localized(with: stateName))
        }
        var nextState = state
        nextState.context = self
        nextState.prepare()
        currentState.relax()
        currentState.context = nil
        currentState = nextState
        await currentState.activate()
    }
    
}
