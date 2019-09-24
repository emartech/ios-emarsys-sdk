//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSConfigInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "MERequestContext.h"
#import "EMSPushV3Internal.h"

@interface EMSConfigInternal ()

@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) NSArray<id <EMSFlipperFeature>> *experimentalFeatures;
@property(nonatomic, strong) EMSMobileEngageV3Internal *mobileEngage;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSPushV3Internal *pushInternal;

@end

@implementation EMSConfigInternal

- (instancetype)initWithConfig:(EMSConfig *)config requestContext:(MERequestContext *)requestContext mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage pushInternal:(EMSPushV3Internal *)pushInternal {
    NSParameterAssert(config);
    NSParameterAssert(requestContext);
    NSParameterAssert(mobileEngage);
    NSParameterAssert(pushInternal);

    if (self = [super init]) {
        _applicationCode = config.applicationCode;
        _merchantId = config.merchantId;
        _contactFieldId = config.contactFieldId;
        _experimentalFeatures = config.experimentalFeatures;
        _mobileEngage = mobileEngage;
        _requestContext = requestContext;
        _pushInternal = pushInternal;
    }
    return self;
}

- (void)changeApplicationCode:(NSString *)applicationCode
            completionHandler:(EMSCompletionBlock)completionHandler {
    NSParameterAssert(completionHandler);

    [self.mobileEngage clearContactWithCompletionBlock:^(NSError *error) {
        completionHandler(error);
    }];

    _applicationCode = applicationCode;

    [self.pushInternal setPushToken:self.pushInternal.deviceToken
                    completionBlock:^(NSError *error) {
                        completionHandler(error);
                    }];

    [self.mobileEngage setContactWithContactFieldValue:[self.requestContext contactFieldValue]
                                       completionBlock:^(NSError *error) {
                                           completionHandler(error);
                                       }];
}

- (void)changeMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    NSParameterAssert(contactFieldId);
    _contactFieldId = contactFieldId;
}


@end