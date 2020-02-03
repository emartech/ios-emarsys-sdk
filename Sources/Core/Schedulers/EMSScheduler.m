//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSScheduler.h"
#import "EMSAgenda.h"

@interface EMSScheduler ()

@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, assign) NSTimeInterval leeway;

@end

@implementation EMSScheduler

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue leeway:(NSTimeInterval)leeway {
    if (self = [super init]) {
        NSParameterAssert(operationQueue);
        NSParameterAssert(leeway > 0);
        _operationQueue = operationQueue;
        _leeway = leeway;
        _scheduledAgendas = @{};
    }
    return self;
}

- (void)scheduleTriggerWithTag:(NSString *)tag
                         delay:(NSTimeInterval)delay
                      interval:(NSNumber *)interval
                  triggerBlock:(EMSTriggerBlock)triggerBlock {
    NSParameterAssert(tag);
    NSParameterAssert(delay > 0);
    NSParameterAssert(!interval || [interval doubleValue] > 0);
    NSParameterAssert(triggerBlock);

    [self cancelTriggerWithTag:tag];

    const dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [self.operationQueue underlyingQueue]);
    const uint64_t timerInterval = interval ? (uint64_t) interval.doubleValue * NSEC_PER_SEC : DISPATCH_TIME_FOREVER;
    const uint64_t leeway = (uint64_t) (self.leeway * NSEC_PER_SEC);
    const dispatch_time_t timerDelay = dispatch_time(DISPATCH_TIME_NOW, (int64_t) delay * NSEC_PER_SEC);

    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf.operationQueue addOperationWithBlock:^{
            triggerBlock();
        }];
        if (timerInterval == DISPATCH_TIME_FOREVER) {
            dispatch_source_cancel(timer);
        }
    });
    dispatch_source_set_timer(timer, timerDelay, timerInterval, leeway);
    dispatch_resume(timer);
    NSMutableDictionary *agendas = [self.scheduledAgendas mutableCopy];
    agendas[tag] = [[EMSAgenda alloc] initWithTag:tag
                                            delay:delay
                                         interval:interval
                                    dispatchTimer:timer
                                     triggerBlock:triggerBlock];
    _scheduledAgendas = [NSDictionary dictionaryWithDictionary:agendas];
}

- (void)cancelTriggerWithTag:(NSString *)tag {
    if (self.scheduledAgendas[tag]) {
        dispatch_source_cancel(self.scheduledAgendas[tag].dispatchTimer);
        NSMutableDictionary *agendas = [self.scheduledAgendas mutableCopy];
        agendas[tag] = nil;
        _scheduledAgendas = [NSDictionary dictionaryWithDictionary:agendas];
    }
}

@end