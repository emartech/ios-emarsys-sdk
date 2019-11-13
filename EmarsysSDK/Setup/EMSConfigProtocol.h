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

- (NSString *)applicationCode;

- (void)changeMerchantId:(nullable NSString *)merchantId;

- (NSString *)merchantId;

- (NSNumber *)contactFieldId;

- (NSString *)hardwareId;

- (NSString *)languageCode;

- (NSDictionary *)pushSettings;

@end

NS_ASSUME_NONNULL_END