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
    
    func testInit_shouldCreateListWithEmptyElements_whenNoElementsStored_andPersist() throws {
        fakeSecureStorage.when(\.fnGet).thenReturn(nil)
        let list: PersistentList<Int> = try PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq([]), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        XCTAssertEqual(testId, list.id)
        XCTAssertEqual([], list.elements)
    }
    
    func testInit_shouldCreateListWithElementsFromStorage_andNotPersist() throws {
        let testElementsFromStorage = [5,6,7]
        fakeSecureStorage.when(\.fnGet).thenReturn(testElementsFromStorage)
        let list: PersistentList<Int> = try PersistentList(id: testId, storage: fakeSecureStorage, sdkLogger: logger)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .times(times: .eq(0))
        XCTAssertEqual(testId, list.id)
        XCTAssertEqual(testElementsFromStorage, list.elements)
    }

    func testInitWithInitialElements_shouldCreateListWithElements_andPersist() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        XCTAssertEqual(testId, list.id)
        XCTAssertEqual(testElements, list.elements)
    }
    
    func testInitWithInitialElements_shouldCreateListWithElements_EvenIfElementsAlreadyStored_andPersist() throws {
        let testElementsFromStorage = [5,6,7]
        fakeSecureStorage.when(\.fnGet).thenReturn(testElementsFromStorage)
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        XCTAssertEqual(testId, list.id)
        XCTAssertEqual(testElements, list.elements)
    }
    
    func testStartIndexAndEndIndex() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        
        XCTAssertEqual(0, list.startIndex)
        XCTAssertEqual(3, list.endIndex)
    }

    func testSubscript_shouldReturnElementAtIndex() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        
        let elementAtIndex1 = list[1]
        
        XCTAssertEqual(2, elementAtIndex1)
    }
    
    func testSubscript_shouldSetElementAtIndex_andPersist() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        let expectedArray = [5,2,3]
        
        list[0] = 5
        
        XCTAssertEqual(5, list[0])
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(expectedArray), Arg.eq(testId), Arg.nil)
            .times(times: .eq(2))
    }
    
    func testSubscript_shouldNotSetElementAtIndex_whenPersistFails() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        fakeSecureStorage.when(\.fnPut).thenThrow(error: Errors.StorageError.savingItemFailed(item: "test", error: "testError"))
        
        list[0] = 5
        
        XCTAssertEqual(testElements, list.elements)
    }
    
    func testAppend_shouldAppendElementToTheEndOfArray_andPersist() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        let expectedArray = [1,2,3,4]
        
        list.append(4)
        
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(expectedArray), Arg.eq(testId), Arg.nil)
            .times(times: .eq(2))
        XCTAssertEqual(4, list.count)
        XCTAssertEqual(4, list[3])
    }
    
    func testAppend_shouldNotModifyElements_whenPersistFails() throws {
        let list = try PersistentList(id: testId, storage: fakeSecureStorage, elements: testElements, sdkLogger: logger)
        _ = try fakeSecureStorage.verify(\.fnPut)
            .wasCalled(Arg.eq(testElements), Arg.eq(testId), Arg.nil)
            .times(times: .eq(1))
        fakeSecureStorage.when(\.fnPut).thenThrow(error: Errors.StorageError.savingItemFailed(item: "test", error: "testError"))
        
        list.append(4)
        
        XCTAssertEqual(3, list.count)
        XCTAssertEqual(testElements, list.elements)
    }
}
