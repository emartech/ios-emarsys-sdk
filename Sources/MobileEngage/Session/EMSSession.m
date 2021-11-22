//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSSession.h"
#import "EMSTimestampProvider.h"
#import "NSDate+EMSCore.h"

@interface EMSSession ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;

@end

@implementation EMSSession

- (instancetype)initWithSessionIdHolder:(EMSSessionIdHolder *)sessionIdHolder
                         requestManager:(EMSRequestManager *)requestManager
                         requestFactory:(EMSRequestFactory *)requestFactory
                         operationQueue:(NSOperationQueue *)operationQueue
                      timestampProvider:(EMSTimestampProvider *)timestampProvider {
    NSParameterAssert(sessionIdHolder);
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(operationQueue);
    NSParameterAssert(timestampProvider);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _timestampProvider = timestampProvider;
        _sessionIdHolder = sessionIdHolder;
        __weak typeof(self) weakSelf = self;
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                        object:nil
                                                         queue:operationQueue
                                                    usingBlock:^(NSNotification *notification) {
            [weakSelf startSessionWithCompletionBlock:nil];
        }];
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                        object:nil
                                                         queue:operationQueue
                                                    usingBlock:^(NSNotification *notification) {
            [weakSelf stopSessionWithCompletionBlock:nil];
        }];
    }
    return self;
}

- (void)startSessionWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    
    self.sessionIdHolder.sessionId = [NSUUID UUID].UUIDString;
    self.sessionStartTime = [self.timestampProvider provideTimestamp];
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"session:start"
                                                                              eventAttributes:nil
                                                                                    eventType:EventTypeInternal];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

- (void)stopSessionWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSDate *sessionStopTime = [self.timestampProvider provideTimestamp];
    NSString *elapsedTime = [[sessionStopTime numberValueInMillisFromDate:self.sessionStartTime] stringValue];
    NSMutableDictionary *eventAttributes = [NSMutableDictionary dictionary];
    eventAttributes[@"duration"] = elapsedTime;
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"session:end"
                                                                              eventAttributes:[NSDictionary dictionaryWithDictionary:eventAttributes]
                                                                                    eventType:EventTypeInternal];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
    self.sessionIdHolder.sessionId = nil;
}

@end
