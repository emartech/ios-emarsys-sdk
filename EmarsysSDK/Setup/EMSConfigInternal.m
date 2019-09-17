//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSConfigInternal.h"

@interface EMSConfigInternal ()

@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) NSArray<id<EMSFlipperFeature>> *experimentalFeatures;
@end

@implementation EMSConfigInternal

- (instancetype)initWithConfig:(EMSConfig *)config {
    NSParameterAssert(config);
    if (self = [super init]) {
        _applicationCode = config.applicationCode;
        _merchantId = config.merchantId;
        _contactFieldId = config.contactFieldId;
        _experimentalFeatures = config.experimentalFeatures;
    }
    return self;
}

- (void)changeApplicationCode:(NSString *)applicationCode
            completionHandler:(EMSCompletionBlock)completionHandler {
    NSParameterAssert(completionHandler);
    self.applicationCode = applicationCode;
}

- (void)changeMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    NSParameterAssert(contactFieldId);
    _contactFieldId = contactFieldId;
}


@end