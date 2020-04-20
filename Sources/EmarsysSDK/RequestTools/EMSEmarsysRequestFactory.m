//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSEmarsysRequestFactory.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSRequestModel.h"
#import "EMSEndpoint.h"
#import "MERequestContext.h"

@interface EMSEmarsysRequestFactory ()

@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSEndpoint *endpoint;
@property(nonatomic, strong) MERequestContext *requestContext;

@end

@implementation EMSEmarsysRequestFactory

- (instancetype)initWithTimestampProvider:(EMSTimestampProvider *)timestampProvider
                             uuidProvider:(EMSUUIDProvider *)uuidProvider
                                 endpoint:(EMSEndpoint *)endpoint
                           requestContext:(MERequestContext *)requestContext {
    NSParameterAssert(timestampProvider);
    NSParameterAssert(uuidProvider);
    NSParameterAssert(endpoint);
    NSParameterAssert(requestContext);
    if (self = [super init]) {
        _timestampProvider = timestampProvider;
        _uuidProvider = uuidProvider;
        _endpoint = endpoint;
        _requestContext = requestContext;
    }
    return self;
}

- (EMSRequestModel *)createRemoteConfigRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:[self.endpoint remoteConfigUrl:self.requestContext.applicationCode]];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

- (EMSRequestModel *)createRemoteConfigSignatureRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setMethod:HTTPMethodGET];
                [builder setUrl:[self.endpoint remoteConfigSignatureUrl:self.requestContext.applicationCode]];
            }
                          timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end