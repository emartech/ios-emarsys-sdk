//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSDeviceEventStateResponseHandler.h"
#import "EMSStorage.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSEndpoint.h"
#import "EMSStorageProtocol.h"
#import "EMSStatusLog.h"
#import "EMSMacros.h"

@interface EMSDeviceEventStateResponseHandler ()

@property(nonatomic, strong) id<EMSStorageProtocol> storage;
@property(nonatomic, strong) EMSEndpoint *endpoint;

@end

@implementation EMSDeviceEventStateResponseHandler

- (instancetype)initWithStorage:(id<EMSStorageProtocol>)storage
                       endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(storage);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _storage = storage;
        _endpoint = endpoint;
    }
    return self;
}

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    NSString *url = response.requestModel.url.absoluteString;
    if ([MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] &&
            [response isSuccess] &&
            [self.endpoint isMobileEngageUrl:url] &&
            response.parsedBody[@"deviceEventState"]) {
        if (!([self.endpoint isCustomEventUrl:url] || [self.endpoint isInlineInAppUrl:url])) {
            NSMutableDictionary *parameterDictionary = [NSMutableDictionary new];
            parameterDictionary[@"response"] = [response description];
            NSMutableDictionary *statusDictionary = [NSMutableDictionary new];
            statusDictionary[@"responseBody"] = response.parsedBody;
            statusDictionary[@"responseHeaders"] = response.headers;
            statusDictionary[@"requestModel"] = response.requestModel.description;
            statusDictionary[@"requestId"] = response.requestModel.requestId;
            statusDictionary[@"requestBody"] = response.requestModel.payload;
            EMSStatusLog *log = [[EMSStatusLog alloc] initWithClass:self.class
                                                                sel:_cmd
                                                         parameters:parameterDictionary
                                                             status:statusDictionary];
            EMSLog(log, LogLevelDebug);
        }
    }
    return [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] &&
            [response isSuccess] &&
            ([self.endpoint isCustomEventUrl:url] || [self.endpoint isInlineInAppUrl:url]) &&
            response.parsedBody[@"deviceEventState"];
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.storage setDictionary:response.parsedBody[@"deviceEventState"]
                         forKey:kDeviceEventStateKey];
}

@end
