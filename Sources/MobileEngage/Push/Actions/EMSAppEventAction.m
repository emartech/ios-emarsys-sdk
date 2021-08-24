//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSAppEventAction.h"
#import "EMSDispatchWaiter.h"

@interface EMSAppEventAction ()

@property(nonatomic, strong) NSDictionary *action;

@end

@implementation EMSAppEventAction

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                            eventHandler:(EMSEventHandlerBlock)eventHandler {
    NSParameterAssert(action);
    NSParameterAssert(eventHandler);

    if (self = [super init]) {
        _action = action;
        _eventHandler = eventHandler;
    }
    return self;
}

- (void)execute {
    EMSDispatchWaiter *waiter = [[EMSDispatchWaiter alloc] init];
    [waiter enter];
    if (self.eventHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.eventHandler(self.action[@"name"],
                    self.action[@"payload"]);
            [waiter exit];
        });
    }

    [waiter waitWithInterval:2];
}

@end