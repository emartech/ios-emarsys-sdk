//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "AppStartBlockProvider.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "MERequestFactory_old.h"
#import "EMSRequestFactory.h"
#import "EMSDeviceInfo.h"
#import "EMSDeviceInfo+MEClientPayload.h"

@implementation AppStartBlockProvider

- (MEHandlerBlock)createAppStartBlockWithRequestManager:(EMSRequestManager *)requestManager
                                         requestContext:(MERequestContext *)requestContext {
    return ^{
        if (requestContext.meId) {
            [requestManager submitRequestModel:[MERequestFactory_old createCustomEventModelWithEventName:@"app:start"
                                                                                         eventAttributes:nil
                                                                                                    type:@"internal"
                                                                                          requestContext:requestContext]
                           withCompletionBlock:^(NSError *error) {
                           }];
        }
    };
};

- (MEHandlerBlock)createAppStartBlockWithRequestManager:(EMSRequestManager *)requestManager
                                         requestFactory:(EMSRequestFactory *)requestFactory
                                             deviceInfo:(EMSDeviceInfo *)deviceInfo {
    NSParameterAssert(requestManager);
    NSParameterAssert(requestFactory);
    NSParameterAssert(deviceInfo);
    return ^{
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kEMSSuiteName];
        if (![[userDefaults dictionaryForKey:kDEVICE_INFO] isEqualToDictionary:[deviceInfo clientPayload]]) {
            EMSRequestModel *deviceInfoRequest = [requestFactory createDeviceInfoRequestModel];
            [requestManager submitRequestModel:deviceInfoRequest
                           withCompletionBlock:^(NSError *error) {
                           }];
        }
    };
}


@end