//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSGeofenceResponseMapper.h"

@interface EMSGeofenceInternal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSGeofenceResponseMapper *responseMapper;

@end

@implementation EMSGeofenceInternal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        responseMapper:(EMSGeofenceResponseMapper *)responseMapper {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(responseMapper);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _responseMapper = responseMapper;
    }
    return self;
}

- (void)fetchGeofences {
    EMSRequestModel *requestModel = [self.requestFactory createGeofenceRequestModel];
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      [self.responseMapper mapFromResponseModel:response];
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {

                                    }];
}

@end