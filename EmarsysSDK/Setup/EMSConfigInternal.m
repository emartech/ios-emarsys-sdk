//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSConfigInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "MERequestContext.h"
#import "EMSPushV3Internal.h"

@interface EMSConfigInternal ()

@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSArray<id <EMSFlipperFeature>> *experimentalFeatures;
@property(nonatomic, strong) EMSMobileEngageV3Internal *mobileEngage;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSPushV3Internal *pushInternal;
@property(nonatomic, strong) NSString *contactFieldValue;

@end

@implementation EMSConfigInternal

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                  mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage
                  pushInternal:(EMSPushV3Internal *)pushInternal {
    NSParameterAssert(config);
    NSParameterAssert(requestContext);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(pushInternal);

    if (self = [super init]) {
        _merchantId = config.merchantId;
        _experimentalFeatures = config.experimentalFeatures;
        _mobileEngage = mobileEngage;
        _requestContext = requestContext;
        _pushInternal = pushInternal;
    }
    return self;
}

- (void)changeApplicationCode:(nullable NSString *)applicationCode
              completionBlock:(_Nullable EMSCompletionBlock)completionBlock; {
    _contactFieldValue = [self.requestContext contactFieldValue];

    __weak typeof(self) weakSelf = self;
    [self.mobileEngage clearContactWithCompletionBlock:^(NSError *error) {
        if (error) {
            weakSelf.requestContext.applicationCode = nil;
            [weakSelf callCompletionBlock:completionBlock
                                withError:error];
        } else {
            weakSelf.requestContext.applicationCode = applicationCode;
            [weakSelf setPushTokenWithCompletionBlock:completionBlock];
        }
    }];
}

- (NSString *)applicationCode {
    return self.requestContext.applicationCode;
}

- (void)callCompletionBlock:(EMSCompletionBlock)completionBlock
                  withError:(NSError *)error {
    if (completionBlock) {
        completionBlock(error);
    }
}

- (void)changeMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    NSParameterAssert(contactFieldId);
    self.requestContext.contactFieldId = contactFieldId;
}

- (void)setPushTokenWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    if (self.pushInternal.deviceToken) {
        [self.pushInternal setPushToken:self.pushInternal.deviceToken
                        completionBlock:^(NSError *error) {
                            if (error) {
                                weakSelf.requestContext.applicationCode = nil;
                                [weakSelf callCompletionBlock:completionBlock
                                                    withError:error];
                            } else {
                                [weakSelf setContactWithCompletionBlock:completionBlock];
                            }
                        }];
    } else {
        [self setContactWithCompletionBlock:completionBlock];
    }
}

- (void)setContactWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.mobileEngage setContactWithContactFieldValue:self.contactFieldValue
                                       completionBlock:^(NSError *error) {
                                           if (error) {
                                               weakSelf.requestContext.applicationCode = nil;
                                           }
                                           [weakSelf callCompletionBlock:completionBlock
                                                               withError:error];
                                       }];
}

@end
