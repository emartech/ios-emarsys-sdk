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

- (EMSRequestModel *)createPushTokenRequestModelWithPushToken:(NSString *)pushToken {
    __weak typeof(self) weakSelf = self;
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:PUSH_TOKEN_URL(weakSelf.applicationCode)];
            [builder setMethod:HTTPMethodPUT];
            [builder setPayload:@{@"pushToken": pushToken}];
        }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}

- (EMSRequestModel *)createContactRequestModel {
    __weak typeof(self) weakSelf = self;
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodPOST];
            BOOL anonymousLogin = NO;
            NSDictionary *payload = @{};
            if (weakSelf.requestContext.appLoginParameters.contactFieldId && weakSelf.requestContext.appLoginParameters.contactFieldValue) {
                payload = @{
                    @"contactFieldId": weakSelf.requestContext.appLoginParameters.contactFieldId,
                    @"contactFieldValue": weakSelf.requestContext.appLoginParameters.contactFieldValue
                };
            } else {
                anonymousLogin = YES;
            }
            [builder setUrl:CONTACT_URL(weakSelf.applicationCode)
            queryParameters:@{@"anonymous": anonymousLogin ? @"true" : @"false"}];
            [builder setPayload:payload];
        }
                          timestampProvider:self.requestContext.timestampProvider
                               uuidProvider:self.requestContext.uuidProvider];
}


@end