//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

import XCTest
import mimic
@testable import EmarsysSDK

@SdkActor
final class PersistentListTests: EmarsysTestCase {

    let testId = "test"
    let testElements = [1,2,3]
    
    @Inject(\.sdkLogger)
    var logger: SdkLogger
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    override func setUpWithError() throws {
        fakeSecureStorage.when(\.fnPut).thenReturn(())
    }
    
    func testInit_shouldCreateListWithEmptyElements_whenNoElementsStored_andPersist() async throws {
        fakeSecureStorage
            .when(\.fnGet)
            .thenReturn(nil)
        
        let _: PersistentList<Int> = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .wasCalled(Arg.eq([]), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
    }
    
    func testInit_shouldCreateListWithElementsFromStorage_andNotPersist() throws {
        let testElementsFromStorage = [5,6,7]
        
        fakeSecureStorage
            .when(\.fnGet)
            .thenReturn(testElementsFromStorage)
        
        let _: PersistentList<Int> = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger)
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .times(times: .eq(0))
    }

    func testInitWithInitialElements_shouldCreateListWithElements_andPersist() async throws {
        let _ = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
    }
    
    func testInitWithInitialElements_shouldCreateListWithElements_EvenIfElementsAlreadyStored_andPersist() async throws {
        let testElementsFromStorage = [5,6,7]
        fakeSecureStorage.when(\.fnGet).thenReturn(testElementsFromStorage)
        
        let _ = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
    }
    
    func testStartIndexAndEndIndex() throws {
        let list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        XCTAssertEqual(list.startIndex, 0)
        XCTAssertEqual(list.endIndex, 3)
    }

    func testSubscript_shouldReturnElementAtIndex() throws {
        let list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        let elementAtIndex1 = list[1]
        
        XCTAssertEqual(elementAtIndex1, 2)
    }
    
    func testSubscript_shouldSetElementAtIndex_andPersist() async throws {
        let list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        
        let expectedArray = [5,2,3]
        
        list[0] = 5
        
        XCTAssertEqual(list[0], 5)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(expectedArray), Arg.eq(testId), Arg.nil)
            .times(times: .eq(2))
    }
    
    func testSubscript_shouldNotSetElementAtIndex_whenPersistFails() async throws {
        let list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        
        fakeSecureStorage
            .when(\.fnPut)
            .thenThrow(error: Errors.StorageError.savingItemFailed(item: "test", error: "testError"))
        
        list[0] = 5
        
        XCTAssertEqual(list[0], 1)
    }
    
    func testAppend_shouldAppendElementToTheEndOfArray_andPersist() async throws {
        var list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        
        let expectedArray = [1,2,3,4]
        
        list.append(4)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(expectedArray), Arg.eq(testId), Arg.nil)
            .times(times: .eq(2))
        
        XCTAssertEqual(list.count, 4)
        XCTAssertEqual(list[3], 4)
    }
    
    func testAppend_shouldNotModifyElements_whenPersistFails() async throws {
        var list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        try await Task.sleep(nanoseconds: 5000000)
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        
        fakeSecureStorage
            .when(\.fnPut)
            .thenThrow(error: Errors.StorageError.savingItemFailed(item: "test", error: "testError"))
        
        list.append(4)
        
        XCTAssertEqual(list.count, 3)
        XCTAssertEqual(testElements.last, 3)
    }
    
    func testRemoveAll() async throws {
        let list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        list.removeAll(keepingCapacity: false)
        
        XCTAssertEqual(list.count, 0)
    }
    
    func testRemoveAll_where() async throws {
        var list = PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger, elements: testElements)
        
        list.removeAll { index in
            true
        }
        
        XCTAssertEqual(list.count, 0)
    }

}
