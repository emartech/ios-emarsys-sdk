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
    return [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] &&
            [response isSuccess] &&
            [self.endpoint isMobileEngageUrl:response.requestModel.url.absoluteString] &&
            response.parsedBody[@"deviceEventState"];
}

- (void)handleResponse:(EMSResponseModel *)response {
    [self.storage setDictionary:response.parsedBody[@"deviceEventState"]
                         forKey:kDeviceEventStateKey];
}

@end
