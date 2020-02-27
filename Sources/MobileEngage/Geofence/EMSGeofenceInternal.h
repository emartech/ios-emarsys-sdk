//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMSRequestManager;
@class EMSRequestFactory;
@class EMSGeofenceResponseMapper;

@interface EMSGeofenceInternal : NSObject

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper;

- (void)fetchGeofences;

@end