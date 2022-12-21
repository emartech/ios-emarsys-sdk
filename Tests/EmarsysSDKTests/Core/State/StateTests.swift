//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        
import XCTest
@testable import EmarsysSDK

final class StateTests: XCTestCase {

    @SdkActor func testStateSwitching() throws {
        let testState1 = TestState1()
        let testState2 = TestState2()
        let machine = StateMachine(states: [testState1, testState2], currentState: testState1)

        XCTAssertEqual(machine.currentState.name, "testState1")
        
        try machine.currentState.context?.switchTo(stateName: "testState2")
        
        XCTAssertEqual(machine.currentState.name, "testState2")
    }
}


fileprivate struct TestState1: State {

    
    var context: StateContext?
    
    var name = "testState1"
    
    func prepare() {
        
    }
    
    func relax() {
        
    }
    
}


fileprivate struct TestState2: State {
    var context: StateContext?
    
    var name = "testState2"
    
    func prepare() {
        
    }
    
    func relax() {
        
    }
    
}
