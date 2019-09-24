//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSFlipperFeature;

NS_ASSUME_NONNULL_BEGIN

@protocol EMSConfigProtocol <NSObject>

- (void)changeApplicationCode:(NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionHandler;

- (NSString *) applicationCode;

- (void)changeMerchantId:(NSString *)merchantId;

- (NSString *)merchantId;

- (void)setContactFieldId:(NSNumber *)contactFieldId;

- (NSNumber *)contactFieldId;

@end

NS_ASSUME_NONNULL_END