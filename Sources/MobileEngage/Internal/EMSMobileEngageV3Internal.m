//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "MERequestContext.h"
#import "EMSStorage.h"
#import "EMSSession.h"
#import "EMSStorageProtocol.h"
#import "EMSCompletionBlockProvider.h"
#import "EMSStatusLog.h"
#import "EMSLogLevel.h"
#import "EMSMacros.h"

#define kEMSPushTokenKey @"EMSPushTokenKey"

@interface EMSMobileEngageV3Internal ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) MERequestContext *requestContext;
@property(nonatomic, strong) id<EMSStorageProtocol> storage;
@property(nonatomic, strong) EMSSession *session;
@property(nonatomic, strong) EMSCompletionBlockProvider *completionBlockProvider;

@end

@implementation EMSMobileEngageV3Internal

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
    }
    return self;
}

- (void)callCompletionWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock
                                    error:(nullable NSError *)error {
    if (completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(error);
        });
    }
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    [self trackCustomEventWithName:eventName
                   eventAttributes:eventAttributes
                   completionBlock:nil];
}

- (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock {
    NSParameterAssert(eventName);
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:eventName
                                                                              eventAttributes:eventAttributes
                                                                                    eventType:EventTypeCustom];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

@end
