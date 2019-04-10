//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSDeviceInfoV3ClientInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo+MEClientPayload.h"

@interface EMSDeviceInfoV3ClientInternal ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;

@end

@implementation EMSDeviceInfoV3ClientInternal

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                            deviceInfo:(EMSDeviceInfo *)deviceInfo {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(deviceInfo);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _deviceInfo = deviceInfo;
    }
    return self;
}

- (void)sendDeviceInfo {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
    if (![[userDefaults dictionaryForKey:kDEVICE_INFO] isEqualToDictionary:[self.deviceInfo clientPayload]]) {
        [userDefaults setObject:[self.deviceInfo clientPayload]
                         forKey:kDEVICE_INFO];
        EMSRequestModel *deviceInfoRequest = [self.requestFactory createDeviceInfoRequestModel];
        [self.requestManager submitRequestModel:deviceInfoRequest
                            withCompletionBlock:^(NSError *error) {
                            }];
    }
}

@end