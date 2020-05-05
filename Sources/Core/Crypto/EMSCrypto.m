//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSCrypto.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"

@interface EMSCrypto ()

@property(nonatomic, strong) NSString *pemFileName;

@end

@implementation EMSCrypto

- (BOOL)verifyContent:(NSData *)content
        withSignature:(NSData *)signature {
    NSString *publicKeyString = @"-----BEGIN PUBLIC KEY-----\n"
                                "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELjWEUIBX9zlm1OI4gF1hMCBLzpaB\n"
                                "wgs9HlmSIBAqP4MDGy4ibOOV3FVDrnAY0Q34LZTbPBlp3gRNZJ19UoSy2Q==\n"
                                "-----END PUBLIC KEY-----";
    SecKeyRef publicKey = [self publicKeyReferenceFromString:publicKeyString];
    return [self verifyContent:content
                 withSignature:signature
                     publicKey:publicKey];
}

- (SecKeyRef)publicKeyReferenceFromString:(NSString *)publicKeyString {
    NSString *keyWithoutHeader = [publicKeyString stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----"
                                                                            withString:@""];
    NSString *keyWithoutFooter = [keyWithoutHeader stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----"
                                                                             withString:@""];
    NSString *keyWithoutLines = [keyWithoutFooter stringByReplacingOccurrencesOfString:@"\n"
                                                                            withString:@""];
    NSData *publicKeyData = [keyWithoutLines dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *decodedDataBytes = [[NSData alloc] initWithBase64EncodedData:publicKeyData
                                                                 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSData *strippedData = [decodedDataBytes subdataWithRange:NSMakeRange(decodedDataBytes.length - 65, 65)];
    
    NSDictionary *attributes = @{
        (NSString *) kSecAttrKeyType: (NSString *) kSecAttrKeyTypeEC,
        (NSString *) kSecAttrKeyClass: (NSString *) kSecAttrKeyClassPublic,
        (NSString *) kSecAttrKeySizeInBits: @256,
        (NSString *) kSecAttrIsPermanent: @(NO)
    };
    
    CFErrorRef *error = NULL;
    SecKeyRef publicKey = SecKeyCreateWithData((__bridge CFDataRef) strippedData, (__bridge CFDictionaryRef) attributes, error);
    
    return publicKey;
}

- (BOOL)verifyContent:(NSData *)content
        withSignature:(NSData *)signature
            publicKey:(SecKeyRef)publicKey {
    NSData *decodedSignature = [[NSData alloc] initWithBase64EncodedData:signature
                                                                 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    BOOL result = NO;
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmECDSASignatureMessageX962SHA256;
    BOOL canVerify = SecKeyIsAlgorithmSupported(publicKey, kSecKeyOperationTypeVerify, algorithm);
    if (canVerify && decodedSignature && content) {
        CFErrorRef errorRef = NULL;
        result = SecKeyVerifySignature(publicKey, algorithm, (__bridge CFDataRef) content, (__bridge CFDataRef) decodedSignature, &errorRef);
        if (!result) {
            NSError *error = CFBridgingRelease(errorRef);
            NSMutableDictionary *statusDict = [NSMutableDictionary dictionary];
            statusDict[@"error"] = error.localizedDescription;
            NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
            EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                     sel:_cmd
                                                              parameters:[NSDictionary dictionaryWithDictionary:parametersDict]
                                                                  status:[NSDictionary dictionaryWithDictionary:statusDict]];
            EMSLog(logEntry, LogLevelDebug);
        }
    }
    return result;
}

@end
