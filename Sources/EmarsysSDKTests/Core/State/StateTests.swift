//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        
import XCTest
@testable import EmarsysSDK

@SdkActor
final class StateTests: EmarsysTestCase {

    func testSingleStateSwitching() async throws {
        let states:[State] = [TestState1()]
        let machine = StateMachine(states: states)

        try await machine.activate()
        
        XCTAssertEqual(machine.stateLifecycle?.name, "testState1")
        XCTAssertEqual(machine.stateLifecycle?.lifecycle, .relaxed)
    }
    
    func testMultipleStateSwitching() async throws {
        let states:[State] = [TestState1(),TestState2()]
        let machine = StateMachine(states: states)
        
        var sum = 0
        let cancellable = machine.$stateLifecycle.sink { stateLifecycle in
            guard let stateLifecycle = stateLifecycle else {
                return
            }
            print("stateLifecycle: \(stateLifecycle)")
            sum += 1
        }
        
        try await machine.activate()
        
        XCTAssertEqual(machine.stateLifecycle?.name, "testState2")
        XCTAssertEqual(machine.stateLifecycle?.lifecycle, .relaxed)
        XCTAssertEqual(sum, 6)
        
        cancellable.cancel()
    }
}


fileprivate struct TestState1: State {
    
    func active() async throws {
    }
    
    var name = "testState1"
    
    func prepare() {
    }
    
    func relax() {
    }
    
}


fileprivate struct TestState2: State {
    
    func active() async throws {
    }

    var name = "testState2"
    
    func prepare() {
    }
    
    func relax() {
    }
    
}
