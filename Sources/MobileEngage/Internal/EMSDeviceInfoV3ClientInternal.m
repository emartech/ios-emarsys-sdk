//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@interface EMSDeviceInfoV3ClientInternal ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;
@property(nonatomic, strong) MERequestContext *requestContext;

@end

@implementation EMSDeviceInfoV3ClientInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                            deviceInfo:(EMSDeviceInfo *)deviceInfo
                        requestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(deviceInfo);
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _deviceInfo = deviceInfo;
        _requestContext = requestContext;
    }
    return self;
}

- (void)trackDeviceInfoWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    if (self.requestContext.clientState && [[userDefaults dictionaryForKey:kDEVICE_INFO] isEqualToDictionary:[self.deviceInfo clientPayload]]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    } else {
        [userDefaults setObject:[self.deviceInfo clientPayload]
                         forKey:kDEVICE_INFO];
        [self sendDeviceInfoWithCompletionBlock:completionBlock];
    }
}

- (void)sendDeviceInfoWithCompletionBlock:(EMSCompletionBlock)completionBlock {
    if([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
        EMSRequestModel *deviceInfoRequest = [self.requestFactory createDeviceInfoRequestModel];
        [self.requestManager submitRequestModel:deviceInfoRequest
                            withCompletionBlock:completionBlock];
    } else {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    
}

@end
