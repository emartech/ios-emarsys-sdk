//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSTrigger.h"

@class EMSAgenda;

@interface EMSScheduler : NSObject

@property(nonatomic, readonly) NSDictionary<NSString *, EMSAgenda *> *scheduledAgendas;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                                leeway:(NSTimeInterval)leeway;

- (void)scheduleTriggerWithTag:(NSString *)tag
                         delay:(NSTimeInterval)delay
                      interval:(NSNumber *)interval
                  triggerBlock:(EMSTriggerBlock)trigger;

- (void)cancelTriggerWithTag:(NSString *)tag;

@end