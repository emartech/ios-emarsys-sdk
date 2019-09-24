//
// Copyright (c) 2019 Emarsys. All rights reserved.
//

#import "EMSConfigInternal.h"
#import "EMSMobileEngageV3Internal.h"
#import "MERequestContext.h"
#import "EMSPushV3Internal.h"
#import "NSError+EMSCore.h"

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

- (instancetype)initWithConfig:(EMSConfig *)config
                requestContext:(MERequestContext *)requestContext
                  mobileEngage:(EMSMobileEngageV3Internal *)mobileEngage
                  pushInternal:(EMSPushV3Internal *)pushInternal {
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
              completionBlock:(_Nullable EMSCompletionBlock)completionBlock; {
    NSError *resultError = nil;
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    
    resultError = [self clearContactWithTimeout:timeout
                                completionBlock:completionBlock];

    if(resultError) {
        return;
    } else {
        _applicationCode = applicationCode;
    }

    resultError = [self setPushTokenWithTimeout:timeout
                                completionBlock:completionBlock];
    
    if(resultError){
        return;
    }
    
    resultError = [self setContactWithTimeout:timeout
                              completionBlock:completionBlock];
    
    [self callCompletionBlock:completionBlock
                    withError:resultError];

}

- (void)callCompletionBlock:(EMSCompletionBlock)completionBlock
                  withError:(NSError *)error{
    if (completionBlock) {
        completionBlock(error);
    }
}

- (void)changeMerchantId:(NSString *)merchantId {
    _merchantId = merchantId;
}

- (void)setContactFieldId:(NSNumber *)contactFieldId {
    NSParameterAssert(contactFieldId);
    _contactFieldId = contactFieldId;
}

- (NSError *)clearContactWithTimeout:(dispatch_time_t)timeout
                     completionBlock:(EMSCompletionBlock)completionBlock {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    __block NSError *resultError = nil;
    
    dispatch_group_enter(dispatchGroup);
    [self.mobileEngage clearContactWithCompletionBlock:^(NSError *error) {
        resultError = error;
        dispatch_group_leave(dispatchGroup);
    }];
    
    long waiterResult = dispatch_group_wait(dispatchGroup, timeout);

    if (waiterResult != 0) {
        resultError = [NSError errorWithCode:1408
                        localizedDescription:@"Waiter timeout error."];
    }
    
    if (resultError) {
        [self callCompletionBlock:completionBlock
                        withError:resultError];
    }
    
    return resultError;
}

- (NSError *)setPushTokenWithTimeout:(dispatch_time_t)timeout
                     completionBlock:(EMSCompletionBlock)completionBlock {
    __block NSError *resultError = nil;
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    dispatch_group_enter(dispatchGroup);
    [self.pushInternal setPushToken:self.pushInternal.deviceToken
                    completionBlock:^(NSError *error) {
                        resultError = error;
                        dispatch_group_leave(dispatchGroup);
                    }];
    
    long waiterResult = dispatch_group_wait(dispatchGroup, timeout);

    if (waiterResult != 0) {
        resultError = [NSError errorWithCode:1408
                        localizedDescription:@"Waiter timeout error."];
    }
    
    if (resultError) {
        [self callCompletionBlock:completionBlock
                        withError:resultError];
    }
    
    return resultError;
}

- (NSError *)setContactWithTimeout:(dispatch_time_t)timeout completionBlock:(EMSCompletionBlock)completionBlock {
    __block NSError * resultError = nil;
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    dispatch_group_enter(dispatchGroup);
    [self.mobileEngage setContactWithContactFieldValue:[self.requestContext contactFieldValue]
                                       completionBlock:^(NSError *error) {
                                           resultError = error;
                                           dispatch_group_leave(dispatchGroup);
                                       }];

    long waiterResult = dispatch_group_wait(dispatchGroup, timeout);

    if (waiterResult != 0) {
        resultError = [NSError errorWithCode:1408
                        localizedDescription:@"Waiter timeout error."];
    }
    
    if (resultError) {
        [self callCompletionBlock:completionBlock
                        withError:resultError];
    }
    
    return resultError;
}


@end
