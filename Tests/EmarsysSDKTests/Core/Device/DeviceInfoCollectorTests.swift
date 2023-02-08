
import XCTest
@testable import EmarsysSDK

@SdkActor
final class DeviceInfoCollectorTests: XCTestCase {
    
    @Inject(\.uuidProvider)
    var fakeUuidProvider: FakeUuidProvider
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    @Inject(\.notificationCenterWrapper)
    var fakeNotificationCenterWrapper: FakeNotificationCenterWrapper
    
    @Inject(\.sdkLogger)
    var logger: SdkLogger
    
    var deviceInfoCollector: DefaultDeviceInfoCollector!
    
    let testUuid = "testUuid"
    
    override func setUpWithError() throws {
        logger = SdkLogger()
        
        fakeUuidProvider.when(\.provide) { [unowned self] invocationCount, params in
            return self.testUuid
        }
        
        deviceInfoCollector = DefaultDeviceInfoCollector(notificationCenterWrapper: fakeNotificationCenterWrapper,
                                                         secureStorage: fakeSecureStorage,
                                                         uuidProvider: fakeUuidProvider,
                                                         logger: logger
        )
    }
    
    override func tearDownWithError() throws {
        tearDownFakes()
    }
    
    func testHardwareId_shouldReturnStoredValue() async throws {
        let storedHardwareId: String = "stored hardware ID"
        
        fakeSecureStorage.when(\.get) { invocationCount, params in
            return storedHardwareId
        }
        
        let result = await deviceInfoCollector.hardwareId
        
        XCTAssertEqual(storedHardwareId, result)
        
    }
    
    func testHardwareId_shouldReturnGeneratedValue() async throws {
        
        let result = await deviceInfoCollector.hardwareId
        
        XCTAssertEqual(result, testUuid)
    }
    
    func testHardwareId_shouldStoreGeneratedValue_inSecureStorage() async throws {
        let hardwareIdKey = "kHardwareIdKey"
        
        fakeSecureStorage.when(\.get) { invocationCount, params in
            return nil
        }
        
        var savedHardwareIdKey: String! = ""
        var savedValue: String! = ""
        var invocations: Int = 0
        
        fakeSecureStorage.when(\.put) { invocationCount, params in
            invocations = invocationCount
            savedValue =  try! params[0].unwrap()
            savedHardwareIdKey = try! params[1].unwrap()
            return
        }
        
        let result = await deviceInfoCollector.hardwareId
        
        XCTAssertEqual(savedHardwareIdKey, hardwareIdKey)
        XCTAssertEqual(savedValue, testUuid)
        XCTAssertEqual(result, testUuid)
        XCTAssertEqual(invocations, 1)
    }
}
