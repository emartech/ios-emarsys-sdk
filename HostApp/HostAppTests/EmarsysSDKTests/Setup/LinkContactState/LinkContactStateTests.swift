//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//


import XCTest
@testable import EmarsysSDK
import mimic

final class LinkContactStateTests: EmarsysTestCase {
    
    @Inject(\.contactClient)
    var fakeContactClient: FakeContactClient
    
    @Inject(\.secureStorage)
    var fakeSecureStorage: FakeSecureStorage
    
    var linkContactState: LinkContactState!
    
    override func setUpWithError() throws {
        linkContactState = LinkContactState(contactClient: fakeContactClient, secureStorage: fakeSecureStorage)
        fakeContactClient.when(\.fnLinkContact).thenReturn(())
        fakeContactClient.when(\.fnUnlinkContact).thenReturn(())
    }
    
    func testActive_whenContactTokenIsNotNil() async throws {
        fakeSecureStorage.when(\.fnGet).thenReturn("testContactToken")
        
        try await linkContactState.active()
        
        _ = try fakeContactClient.verify(\.fnLinkContact).times(times: .eq(0))
        _ = try fakeContactClient.verify(\.fnUnlinkContact).times(times: .eq(0))
    }
    
    func testActive_whenContactCredentialsAreNil() async throws {
        fakeSecureStorage.when(\.fnGet).thenReturn(nil)
        
        try await linkContactState.active()
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .times(times: .eq(0))
        _ = try fakeContactClient
            .verify(\.fnUnlinkContact)
            .times(times: .eq(1))
    }
    
    func testActive_whenContactFieldIdAndContactFieldValueIsNotNil() async throws {
        fakeSecureStorage
            .when(\.fnGet)
            .replaceFunction { invocationCount, params in
                let key: String! = params[0]
                var result: Storable?
                switch key {
                case Constants.Contact.contactFieldId:
                    result = 123
                case Constants.Contact.contactFieldValue:
                    result = "testContactFieldValue"
                default:
                    result = nil
                }
                return result
            }
        
        try await linkContactState.active()
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(123), Arg.eq("testContactFieldValue"), Arg.nil)
    }
    
    func testActive_whenContactFieldIdAndOpenIdTokenValueIsNotNil() async throws {
        fakeSecureStorage
            .when(\.fnGet)
            .replaceFunction { invocationCount, params in
            let key: String! = params[0]
            var result: Storable?
            switch key {
            case Constants.Contact.contactFieldId:
                result = 123
            case Constants.Contact.openIdToken:
                result = "testOpenIdToken"
            default:
                result = nil
            }
            return result
        }

        try await linkContactState.active()
        
        _ = try fakeContactClient
            .verify(\.fnLinkContact)
            .wasCalled(Arg.eq(123), Arg.nil, Arg.eq("testOpenIdToken"))
    }
    
}
