//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSCrypto.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"

@interface EMSCrypto ()

@property(nonatomic, strong) NSString *derFileName;

@end

@implementation EMSCrypto

- (instancetype)initWithDerFileName:(NSString *)derFile {
    NSParameterAssert(derFile);
    if (self = [super init]) {
        _derFileName = derFile;
    }
    return self;
}

- (BOOL)verifyContent:(NSData *)content
        withSignature:(NSData *)signature {
    NSData *publicKeyData = [self dataForName:self.derFileName
                                    extension:@"der"];
    SecKeyRef publicKey = [self publicKeyReferenceFromData:publicKeyData];
    return [self verifyContent:content
                 withSignature:signature
                     publicKey:publicKey];
}

- (NSData *)dataForName:(NSString *)name
              extension:(NSString *)extension {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:name
                                                                      ofType:extension];
    return [NSData dataWithContentsOfFile:path];
}

- (SecKeyRef)publicKeyReferenceFromData:(NSData *)publicKeyData {
    SecCertificateRef certificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef) publicKeyData);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust;
    SecTrustCreateWithCertificates(certificate, policy, &trust);
    SecKeyRef securityKey = SecTrustCopyPublicKey(trust);
    CFRelease(certificate);
    CFRelease(policy);
    CFRelease(trust);

    return securityKey;
}

- (BOOL)verifyContent:(NSData *)content
        withSignature:(NSData *)signature
            publicKey:(SecKeyRef)publicKey {
    BOOL result = NO;
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmECDSASignatureMessageX962SHA256;
    BOOL canVerify = SecKeyIsAlgorithmSupported(publicKey, kSecKeyOperationTypeVerify, algorithm);
    if (canVerify) {
        CFErrorRef errorRef = NULL;
        result = SecKeyVerifySignature(publicKey, algorithm, (__bridge CFDataRef) content, (__bridge CFDataRef) signature, &errorRef);
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