//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMSCrypto : NSObject

- (instancetype)initWithDerFileName:(NSString *)derFile;

- (BOOL)verifyContent:(NSData *)content
        withSignature:(NSData *)signature;

@end