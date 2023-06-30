//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK
import mimic

@SdkActor
final class RegisterPushTokenStateTests: EmarsysTestCase {

    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    @Inject(\.pushClient)
    var fakePushClient: FakePushClient
    
    var registerPushTokenState: RegisterPushTokenState!
    
    override func setUpWithError() throws {
        registerPushTokenState = RegisterPushTokenState(pushClient: fakePushClient, secureStorage: fakeSecureStorage)
        fakePushClient
            .when(\.fnRegisterPushToken)
            .thenReturn(())
        fakeSecureStorage
            .when(\.fnPut)
            .thenReturn(())
    }

    func testActive_whenLastSentPushTokenIsMissing_pushTokenIsAvailable() async throws {
        let expectedPushToken = "testPushToken"
        
        fakeSecureStorage
            .when(\.fnGet)
            .calledWith(Arg.eq(Constants.Push.pushToken), Arg.nil)
            .thenReturn(expectedPushToken)
        
        _ = try await registerPushTokenState.active()
        
        _ = try fakePushClient
            .verify(\.fnRegisterPushToken)
            .wasCalled(Arg.eq(expectedPushToken))
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .wasCalled(Arg.eq(expectedPushToken), Arg.eq(Constants.Push.lastSentPushToken), Arg.nil)
    }
    
    func testActive_whenBothAvailable_butNotTheSame() async throws {
        let expectedPushToken = "testPushToken"
        
        fakeSecureStorage
            .when(\.fnGet)
            .replaceFunction { invocationCount, params in
            let key: String = params[0]
            var result: String? = nil
            if key == "pushToken" {
                result = expectedPushToken
            } else if key == "lastSentPushToken" {
                result = "testLastSentPushToken"
            }
            return result
        }
        
        _ = try await registerPushTokenState.active()
        
        _ = try fakePushClient
            .verify(\.fnRegisterPushToken)
            .wasCalled(Arg.eq(expectedPushToken))
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .wasCalled(Arg.eq(expectedPushToken), Arg.eq(Constants.Push.lastSentPushToken), Arg.nil)
    }

    
    func testActive_whenBothAvailable_andTheSame() async throws {
        let expectedPushToken = "testPushToken"
        
        fakeSecureStorage
            .when(\.fnGet)
            .replaceFunction { invocationCount, params in
            let key: String = params[0]
            var result: String? = nil
            if key == "pushToken" {
                result = expectedPushToken
            } else if key == "lastSentPushToken" {
                result = expectedPushToken
            }
            return result
        }
        
        _ = try await registerPushTokenState.active()
        
        _ = try fakePushClient
            .verify(\.fnRegisterPushToken)
            .times(times: .zero)
        
        _ = try fakeSecureStorage
            .verify(\.fnPut)
            .times(times: .zero)
    }
    
}
