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
#import "EMSSdkStateLogger.h"
#import "EMSStatusLog.h"
#import "EMSSQLiteHelper.h"
#import "EMSCompletionBlockProvider.h"

@interface EMSAppStartBlockProvider ()

@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) id <EMSDeviceInfoClientProtocol> deviceInfoClient;
@property(nonatomic, strong) EMSConfigInternal *configInternal;
@property(nonatomic, strong) EMSGeofenceInternal *geofenceInternal;
@property(nonatomic, strong) EMSSdkStateLogger *sdkStateLogger;
@property(nonatomic, strong) EMSLogger *logger;
@property(nonatomic, strong) EMSSQLiteHelper *dbHelper;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;

@end

@implementation EMSAppStartBlockProvider

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        requestContext:(MERequestContext *)requestContext
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient
                        configInternal:(EMSConfigInternal *)configInternal
                      geofenceInternal:(EMSGeofenceInternal *)geofenceInternal
                        sdkStateLogger:(EMSSdkStateLogger *)sdkStateLogger
                                logger:(EMSLogger *)logger 
                              dbHelper:(EMSSQLiteHelper *)dbHelper
               completionBlockProvider:(EMSCompletionBlockProvider *)completionBlockProvider {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestContext);
    NSParameterAssert(deviceInfoClient);
    NSParameterAssert(configInternal);
    NSParameterAssert(geofenceInternal);
    NSParameterAssert(sdkStateLogger);
    NSParameterAssert(logger);
    NSParameterAssert(dbHelper);
    NSParameterAssert(completionBlockProvider);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _requestContext = requestContext;
        _deviceInfoClient = deviceInfoClient;
        _configInternal = configInternal;
        _geofenceInternal = geofenceInternal;
        _sdkStateLogger = sdkStateLogger;
        _logger = logger;
        _dbHelper = dbHelper;
        _completionBlockProvider = completionBlockProvider;
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
                                    withCompletionBlock:nil];
        }
    };
}

- (MEHandlerBlock)createDeviceInfoEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.deviceInfoClient trackDeviceInfoWithCompletionBlock:nil];
    };
}

- (MEHandlerBlock)createRemoteConfigEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        if (![@[@"", @"0", @"null", @"nil"] containsObject:[self.requestContext.applicationCode lowercaseString]]) {
            [weakSelf.configInternal refreshConfigFromRemoteConfigWithCompletionBlock:[weakSelf.completionBlockProvider provideCompletionBlock:^(NSError *error) {
                if ([weakSelf.logger logLevel] == LogLevelTrace) {
                    [weakSelf.sdkStateLogger log];
                }
            }]];
        } else {
            NSLog(@"ApplicationCode is incorrect: %@", self.requestContext.applicationCode);
            EMSStatusLog *logEntry = [[EMSStatusLog alloc] initWithClass:[self class]
                                                                sel:_cmd
                                                         parameters:@{@"applicationCode": self.requestContext.applicationCode}
                                                             status:nil];
            EMSLog(logEntry, LogLevelError);
        }
    };
}

- (MEHandlerBlock)createFetchGeofenceEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.geofenceInternal fetchGeofences];
    };
}

- (MEHandlerBlock)createDbCloseEventBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        [weakSelf.dbHelper close];
    };
}

@end
