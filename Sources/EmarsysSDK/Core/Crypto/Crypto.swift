//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

@SdkActor
struct Crypto {
    
    let base64encodedPublicKey: String
    
    func verify(content: Data, signature: Data) -> Bool {
        guard let publicKey = try? createSecKey(base64EncodedKey: self.base64encodedPublicKey) else {
            return false
        }
        return verify(content: content, signature: signature, publicKey: publicKey)
    }
    
    private func createSecKey(base64EncodedKey: String) throws -> SecKey {
        let keyWithputHeader = self.base64encodedPublicKey.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
        let keyWithoutFooter = keyWithputHeader.replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
        let keyWithoutLines = keyWithoutFooter.replacingOccurrences(of: "\n", with: "")
        guard let publicKeyData = keyWithoutLines.data(using: .utf8) else {
            throw Errors.secKeyCreationFailed("secKeyCreationFailed".localized(with: keyWithoutLines))
        }
        guard let decodedDataBytes = Data(base64Encoded: publicKeyData, options: .ignoreUnknownCharacters) else {
            throw Errors.secKeyCreationFailed("secKeyCreationFailed".localized(with: "line: publicKeyData - base64EncodedKey\(base64EncodedKey)"))
        }
        let range = (decodedDataBytes.count - 65)..<decodedDataBytes.count
        let strippedData = decodedDataBytes.subdata(in: range)
        
        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 256,
            kSecAttrIsPermanent: false
        ] as CFDictionary
        
        var error: Unmanaged<CFError>?
        
        guard let publicKey = SecKeyCreateWithData(strippedData as CFData, attributes, &error) else {
            throw Errors.secKeyCreationFailed("secKeyCreationFailed".localized(with: "line: SecKeyCreateWithData - base64EncodedKey\(base64EncodedKey)"))
        }
        
        return publicKey
    }
    
    private func verify(content: Data, signature: Data, publicKey: SecKey) -> Bool {
        var result = false
        guard let decodedSignature = Data(base64Encoded: signature, options: .ignoreUnknownCharacters) else {
            return false
        }
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
        if (SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm)) {
            var error: Unmanaged<CFError>?
            result = SecKeyVerifySignature(publicKey, algorithm, content as CFData, decodedSignature as CFData, &error)
            
        }
        return result
    }
    
}
