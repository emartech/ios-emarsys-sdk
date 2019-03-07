//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSPushV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "NSData+MobileEngine.h"

@interface EMSPushV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;

@end

@implementation EMSPushV3Internal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
    }
    return self;
}

- (void)setPushToken:(NSData *)pushToken {
    [self setPushToken:pushToken
       completionBlock:nil];
}

- (void)setPushToken:(NSData *)pushToken
     completionBlock:(EMSCompletionBlock)completionBlock {
    NSString *deviceToken = [pushToken deviceTokenString];
    EMSRequestModel *requestModel;
    if (deviceToken && [deviceToken length] > 0) {
        requestModel = [self.requestFactory createPushTokenRequestModelWithPushToken:deviceToken];
        [self.requestManager submitRequestModel:requestModel
                            withCompletionBlock:completionBlock];
    }
}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {

}

- (void)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo completionBlock:(EMSCompletionBlock)completionBlock {

}

@end