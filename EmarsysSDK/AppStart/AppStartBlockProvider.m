//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "AppStartBlockProvider.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSRequestFactory.h"
#import "EMSDeviceInfo.h"
#import "EMSDeviceInfo+MEClientPayload.h"

@interface AppStartBlockProvider ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;

@end

@implementation AppStartBlockProvider

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        requestContext:(MERequestContext *)requestContext
                            deviceInfo:(EMSDeviceInfo *)deviceInfo {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestContext);
    NSParameterAssert(deviceInfo);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _requestContext = requestContext;
        _deviceInfo = deviceInfo;
    }
    return self;
}


- (MEHandlerBlock)createAppStartEventBlock {
    return ^{
        if (self.requestContext.contactToken) {
            EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"app:start"
                                                                                      eventAttributes:nil
                                                                                            eventType:EventTypeInternal];
            [self.requestManager submitRequestModel:requestModel
                                withCompletionBlock:^(NSError *error) {
                                }];
        }
    };
}

- (MEHandlerBlock)createDeviceInfoEventBlock {
    return ^{
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
        if (![[userDefaults dictionaryForKey:kDEVICE_INFO] isEqualToDictionary:[self.deviceInfo clientPayload]]) {
            [userDefaults setObject:[self.deviceInfo clientPayload]
                             forKey:kDEVICE_INFO];
            EMSRequestModel *deviceInfoRequest = [self.requestFactory createDeviceInfoRequestModel];
            [self.requestManager submitRequestModel:deviceInfoRequest
                                withCompletionBlock:^(NSError *error) {
                                }];
        }
    };
}


@end