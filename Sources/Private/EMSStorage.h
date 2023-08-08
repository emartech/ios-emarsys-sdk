//
// Copyright (c) 2020 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSStorageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSStorage : NSObject <EMSStorageProtocol>

@property(nonatomic, readonly) NSString *accessGroup;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithSuiteNames:(NSArray<NSString *> *)suiteNames
                       accessGroup:(nullable NSString *)accessGroup;

- (void)setSharedData:(nullable NSData *)data
               forKey:(NSString *)key;

- (nullable NSData *)sharedDataForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END