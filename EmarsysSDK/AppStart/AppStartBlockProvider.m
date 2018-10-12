//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "AppStartBlockProvider.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "MERequestFactory.h"


@implementation AppStartBlockProvider

- (MEHandlerBlock)createAppStartBlockWithRequestManager:(EMSRequestManager *)requestManager
                                         requestContext:(MERequestContext *)requestContext {
    return ^{
        if (requestContext.meId) {
            [requestManager submitRequestModel:[MERequestFactory createCustomEventModelWithEventName:@"app:start"
                                                                                     eventAttributes:nil
                                                                                                type:@"internal"
                                                                                      requestContext:requestContext]
                           withCompletionBlock:^(NSError *error) {
                           }];
        }
    };
};


@end