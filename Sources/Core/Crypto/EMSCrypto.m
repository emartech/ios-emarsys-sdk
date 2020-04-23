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

- (instancetype)initWithPemFileName:(NSString *)pemFile {
    NSParameterAssert(pemFile);
    if (self = [super init]) {
        _pemFileName = pemFile;
    }
    return self;
}

- (BOOL)verifyContent:(NSData *)content
        withSignature:(NSData *)signature {
    NSString *publicKeyString = [self stringContentOfFileName:self.pemFileName
                                                    extension:@"pem"];
    SecKeyRef publicKey = [self publicKeyReferenceFromString:publicKeyString];
    return [self verifyContent:content
                 withSignature:signature
                     publicKey:publicKey];
}

- (NSString *)stringContentOfFileName:(NSString *)name
                            extension:(NSString *)extension {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name
                                                                      ofType:extension];
    NSError *error = nil;
    return [NSString stringWithContentsOfFile:path
                                     encoding:NSUTF8StringEncoding
                                        error:&error];
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
    if (canVerify) {
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