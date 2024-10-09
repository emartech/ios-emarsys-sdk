//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSSession.h"
#import "EMSTimestampProvider.h"
#import "NSDate+EMSCore.h"
#import "MEExperimental.h"
#import "EMSInnerFeature.h"

@interface EMSSession ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong) NSMutableArray *observers;

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
        _operationQueue = operationQueue;
        _observers = [NSMutableArray array];
        __weak typeof(self) weakSelf = self;
        
        id becomeActiveObserver = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification *notification) {
            if([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
                [weakSelf startSessionWithCompletionBlock:nil];
            }
        }];
        id enterBackgroundObserver = [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                     object:nil
                                                                                      queue:nil
                                                                                 usingBlock:^(NSNotification *notification) {
            if([MEExperimental isFeatureEnabled:EMSInnerFeature.mobileEngage]) {
                [weakSelf stopSessionWithCompletionBlock:nil];
            }
        }];
        [_observers addObject:becomeActiveObserver];
        [_observers addObject:enterBackgroundObserver];
    }
    return self;
}

- (void)startSessionWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        weakSelf.sessionIdHolder.sessionId = [NSUUID UUID].UUIDString;
        weakSelf.sessionStartTime = [weakSelf.timestampProvider provideTimestamp];
        EMSRequestModel *requestModel = [weakSelf.requestFactory createEventRequestModelWithEventName:@"session:start"
                                                                                      eventAttributes:nil
                                                                                            eventType:EventTypeInternal];
        [weakSelf.requestManager submitRequestModel:requestModel
                                withCompletionBlock:completionBlock];
    }];
}

- (void)stopSessionWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    [self.operationQueue addOperationWithBlock:^{
        NSDate *sessionStopTime = [weakSelf.timestampProvider provideTimestamp];
        NSString *elapsedTime = [[sessionStopTime numberValueInMillisFromDate:self.sessionStartTime] stringValue];
        NSMutableDictionary *eventAttributes = [NSMutableDictionary dictionary];
        eventAttributes[@"duration"] = elapsedTime;
        EMSRequestModel *requestModel = [weakSelf.requestFactory createEventRequestModelWithEventName:@"session:end"
                                                                                      eventAttributes:[NSDictionary dictionaryWithDictionary:eventAttributes]
                                                                                            eventType:EventTypeInternal];
        [weakSelf.requestManager submitRequestModel:requestModel
                                withCompletionBlock:completionBlock];
        weakSelf.sessionIdHolder.sessionId = nil;
    }];
}

@end
