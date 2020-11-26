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

- (instancetype)initWithRequestManager:(EMSRequestManager *)requestManager
                        requestFactory:(EMSRequestFactory *)requestFactory
                        operationQueue:(NSOperationQueue *)operationQueue
                     timestampProvider:(EMSTimestampProvider *)timestampProvider {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(operationQueue);
    NSParameterAssert(timestampProvider);
    if (self = [super init]) {
        _requestManager = requestManager;
        _requestFactory = requestFactory;
        _timestampProvider = timestampProvider;
        __weak typeof(self) weakSelf = self;
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                        object:nil
                                                         queue:operationQueue
                                                    usingBlock:^(NSNotification *notification) {
                                                        [weakSelf startSession];
                                                    }];
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                        object:nil
                                                         queue:operationQueue
                                                    usingBlock:^(NSNotification *notification) {
                                                        [weakSelf stopSession];
                                                    }];
    }
    return self;
}

- (void)startSession {
    self.sessionId = [NSUUID UUID].UUIDString;
    self.sessionStartTime = [self.timestampProvider provideTimestamp];
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"session:start"
                                                                              eventAttributes:nil
                                                                                    eventType:EventTypeInternal];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:nil];
}

- (void)stopSession {
    NSDate *sessionStopTime = [self.timestampProvider provideTimestamp];
    NSString *elapsedTime = [[sessionStopTime numberValueInMillisFromDate:self.sessionStartTime] stringValue];
    NSMutableDictionary *eventAttributes = [NSMutableDictionary dictionary];
    eventAttributes[@"elapsedTime"] = elapsedTime;
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"session:end"
                                                                              eventAttributes:[NSDictionary dictionaryWithDictionary:eventAttributes]
                                                                                    eventType:EventTypeInternal];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:nil];
}

@end