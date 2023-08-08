//
// Copyright (c) 2022 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSStorageProtocol.h"

@interface EMSInMemoryStorage: NSObject <EMSStorageProtocol>

@property(nonatomic, readonly) NSDictionary<NSString *, id> *inMemoryStore;

- (instancetype)initWithStorage:(id<EMSStorageProtocol>)storage;

@end