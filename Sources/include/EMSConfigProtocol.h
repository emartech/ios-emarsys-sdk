//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSConfigProtocol <NSObject>

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(changeApplicationCode(applicationCode:completionBlock:));

- (void)changeMerchantId:(nullable NSString *)merchantId
    NS_SWIFT_NAME(changeMerchantId(merchantId:));

- (void)changeMerchantId:(nullable NSString *)merchantId
        completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(changeMerchantId(merchantId:completionBlock:));

- (NSString *)applicationCode;

- (NSString *)merchantId;

- (NSNumber *)contactFieldId;

- (NSString *)hardwareId;

- (NSString *)languageCode;

- (NSDictionary *)pushSettings;

- (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
