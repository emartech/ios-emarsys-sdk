//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRequestFactory.h"
#import "EMSRequestModel.h"
#import "MERequestContext.h"
#import "MEEndpoints.h"
#import "EMSDeviceInfo+MEClientPayload.h"

@interface EMSRequestFactory ()

@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) EMSDeviceInfo *deviceInfo;

@end

@implementation EMSRequestFactory

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext {
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _requestContext = requestContext;
        _applicationCode = requestContext.config.applicationCode;
        _deviceInfo = requestContext.deviceInfo;
    }
    return self;
}

- (EMSRequestModel *)createDeviceInfoRequestModel {
    __weak typeof(self) weakSelf = self;
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:CLIENT_URL(weakSelf.applicationCode)];
            [builder setMethod:HTTPMethodPOST];
            [builder setPayload:[weakSelf.deviceInfo clientPayload]];
        }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}

@end