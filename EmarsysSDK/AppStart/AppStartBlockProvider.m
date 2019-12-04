//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "AppStartBlockProvider.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSRequestFactory.h"
#import "EMSDeviceInfoClientProtocol.h"
#import "EMSConfigInternal.h"

@interface AppStartBlockProvider ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) id <EMSDeviceInfoClientProtocol> deviceInfoClient;
@property(nonatomic, strong) EMSConfigInternal *configInternal;

@end

@implementation AppStartBlockProvider

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        requestContext:(MERequestContext *)requestContext
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient
                        configInternal:(EMSConfigInternal *)configInternal {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestContext);
    NSParameterAssert(deviceInfoClient);
    NSParameterAssert(configInternal);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _requestContext = requestContext;
        _deviceInfoClient = deviceInfoClient;
        _configInternal = configInternal;
    }
    return self;
}

- (MEHandlerBlock)createAppStartEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        if (weakSelf.requestContext.contactToken) {
            EMSRequestModel *requestModel = [weakSelf.requestFactory createEventRequestModelWithEventName:@"app:start"
                                                                                          eventAttributes:nil
                                                                                                eventType:EventTypeInternal];
            [weakSelf.requestManager submitRequestModel:requestModel
                                    withCompletionBlock:^(NSError *error) {
                                    }];
        }
    };
}

- (MEHandlerBlock)createDeviceInfoEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.deviceInfoClient sendDeviceInfoWithCompletionBlock:nil];
    };
}

- (MEHandlerBlock)createRemoteConfigEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.configInternal refreshConfigFromRemoteConfig];
    };
}

@end