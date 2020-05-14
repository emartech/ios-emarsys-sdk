//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSFlipperFeature;

NS_ASSUME_NONNULL_BEGIN

@protocol EMSConfigProtocol <NSObject>

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionHandler;

- (void)changeApplicationCode:(nullable NSString *)applicationCode
               contactFieldId:(NSNumber *)contactFieldId
              completionBlock:(_Nullable EMSCompletionBlock)completionHandler;

- (void)changeMerchantId:(nullable NSString *)merchantId;

- (void)changeMerchantId:(nullable NSString *)merchantId
        completionBlock:(_Nullable EMSCompletionBlock)completionHandler;

- (NSString *)applicationCode;

- (NSString *)merchantId;

- (NSNumber *)contactFieldId;

- (NSString *)hardwareId;

- (NSString *)languageCode;

- (NSDictionary *)pushSettings;

@end

NS_ASSUME_NONNULL_END