//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class CryptoTests: EmarsysTestCase {
    let publicKey = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELjWEUIBX9zlm1OI4gF1hMCBLzpaB
wgs9HlmSIBAqP4MDGy4ibOOV3FVDrnAY0Q34LZTbPBlp3gRNZJ19UoSy2Q==
-----END PUBLIC KEY-----
"""
    
    var remoteConfigString = """
{"serviceUrls":{"eventService":"https://integration.mobile-events.eservice.emarsys.net","clientService":"https://integration.me-client.eservice.emarsys.net"},"logLevel":"ERROR","luckyLogger":{"logLevel":"DEBUG","threshold":0.2},"features":{"mobileEngage":true,"experimentalFeature1":false}}
"""
    let signature = "MEYCIQDUi8+EW3gMkxqBtU3zMuI+lgZ3PfqHOb9Y+ASr9aw+sQIhAK1X6MbBDukxcYuNG3zRURi3jnI6YAguelcePFUEd8tj"
    var configData: Data!
    var crypto: Crypto!
    
    @Inject(\.defaultUrls)
    var defaultUrls: DefaultUrls!
    
    @Inject(\.sdkLogger)
    var logger: SdkLogger
    
    override func setUpWithError() throws {
        configData = Data(remoteConfigString.utf8)
        crypto = DefaultCrypto(base64encodedPublicKey: publicKey, sdkLogger: logger)
    }

    func testVerify() throws {
        let signatureData = Data(signature.utf8)
        
        XCTAssertTrue(crypto.verify(content: configData, signature: signatureData))
    }
    
    func testVerify_withInvalidSignature() throws {
        let invalidSignature = Data("asd;voliasdvnefilnva".utf8)
        
        XCTAssertFalse(crypto.verify(content: configData, signature: invalidSignature))
    }

}
