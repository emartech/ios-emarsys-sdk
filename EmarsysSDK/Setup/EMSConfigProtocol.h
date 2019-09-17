//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSFlipperFeature;

@protocol EMSConfigProtocol <NSObject>

- (void)changeApplicationCode:(NSString *)applicationCode
            completionHandler:(EMSCompletionBlock)completionHandler;

- (NSString *) applicationCode;

- (void)changeMerchantId:(NSString *)merchantId;

- (NSString *)merchantId;

- (NSArray<id <EMSFlipperFeature>> *)experimentalFeatures;

- (void)setContactFieldId:(NSNumber *)contactFieldId;

- (NSNumber *)contactFieldId;

@end