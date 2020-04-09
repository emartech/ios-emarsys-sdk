//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRemoteConfigResponseMapper.h"
#import "EMSRemoteConfig.h"
#import "EMSResponseModel.h"

@implementation EMSRemoteConfigResponseMapper

- (EMSRemoteConfig *)map:(EMSResponseModel *)responseModel {
    NSDictionary *parsedBody = [responseModel parsedBody];
    NSDictionary *serviceUrls = parsedBody[@"serviceUrls"];

    return [[EMSRemoteConfig alloc] initWithEventService:serviceUrls[@"eventService"]
                                           clientService:serviceUrls[@"clientService"]
                                          predictService:serviceUrls[@"predictService"]
                                   mobileEngageV2Service:serviceUrls[@"mobileEngageV2Service"]
                                         deepLinkService:serviceUrls[@"deepLinkService"]
                                            inboxService:serviceUrls[@"inboxService"]
                                   v3MessageInboxService:serviceUrls[@"v3MessageInboxService"]
                                                logLevel:parsedBody[@"logLevel"]];
}

@end
