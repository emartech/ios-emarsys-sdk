//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSNotificationCenterManager.h"

@class EMSRequestManager;
@class MERequestContext;
@class EMSRequestFactory;
@protocol EMSDeviceInfoClientProtocol;
@class EMSConfigInternal;
@class EMSGeofenceInternal;

@interface EMSAppStartBlockProvider : NSObject

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        requestContext:(MERequestContext *)requestContext
                      deviceInfoClient:(id <EMSDeviceInfoClientProtocol>)deviceInfoClient
                        configInternal:(EMSConfigInternal *)configInternal
                      geofenceInternal:(EMSGeofenceInternal *)geofenceInternal;

- (MEHandlerBlock)createAppStartEventBlock;

- (MEHandlerBlock)createDeviceInfoEventBlock;

- (MEHandlerBlock)createRemoteConfigEventBlock;

- (MEHandlerBlock)createFetchGeofenceEventBlock;

@end