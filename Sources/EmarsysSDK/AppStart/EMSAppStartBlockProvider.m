//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSAppStartBlockProvider.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSRequestFactory.h"
#import "EMSDeviceInfoClientProtocol.h"
#import "EMSConfigInternal.h"
#import "EMSMacros.h"
#import "EMSAppEventLog.h"
#import "EMSGeofenceInternal.h"

@interface EMSAppStartBlockProvider ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) id <EMSDeviceInfoClientProtocol> deviceInfoClient;
@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) EMSGeofenceInternal *geofenceInternal;

@end

@implementation EMSAppStartBlockProvider

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        requestContext:(MERequestContext *)requestContext
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient
                        configInternal:(EMSConfigInternal *)configInternal
                      geofenceInternal:(EMSGeofenceInternal *)geofenceInternal {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestContext);
    NSParameterAssert(deviceInfoClient);
    NSParameterAssert(configInternal);
    NSParameterAssert(geofenceInternal);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _requestContext = requestContext;
        _deviceInfoClient = deviceInfoClient;
        _configInternal = configInternal;
        _geofenceInternal = geofenceInternal;
    }
    return self;
}

- (MEHandlerBlock)createAppStartEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        EMSLog([[EMSAppEventLog alloc] initWithEventName:@"app:start"
                                              attributes:nil], LogLevelInfo);
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
        [weakSelf.configInternal refreshConfigFromRemoteConfigWithCompletionBlock:nil];
    };
}

- (MEHandlerBlock)createFetchGeofenceEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.geofenceInternal fetchGeofences];
    };
}


@end