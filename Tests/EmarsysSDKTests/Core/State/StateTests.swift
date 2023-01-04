//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        
import XCTest
@testable import EmarsysSDK

final class StateTests: XCTestCase {

    @SdkActor func testStateSwitching() async throws {
        let testState1 = TestState1()
        let testState2 = TestState2()
        let machine = StateMachine(states: [testState1, testState2], currentState: testState1)

        try await machine.activate()
        
        XCTAssertEqual(machine.stateLifecycle?.name, "testState2")
        XCTAssertEqual(machine.stateLifecycle?.lifecycle, .relaxed)
    }
}


fileprivate struct TestState1: State {
    
    func active() async throws {
        
    }
    
    var context: StateContext?
    
    var name = "testState1"
    
    var nextStateName: String? = "testState2"
    
    func prepare() {
        
    }
    
    func relax() {
        
    }
    
}


fileprivate struct TestState2: State {
    
    func active() async throws {
        
    }
    
    var context: StateContext?
    
    var name = "testState2"
    
    var nextStateName: String? = nil
    
    func prepare() {
        
    }
    
    func relax() {
        
    }
    
}
