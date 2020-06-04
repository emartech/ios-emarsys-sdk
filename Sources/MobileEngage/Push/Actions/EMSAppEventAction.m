//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSAppEventAction.h"

@interface EMSAppEventAction ()

@property(nonatomic, strong) NSDictionary *action;

@end

@implementation EMSAppEventAction

@synthesize eventHandler = _eventHandler;

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                            eventHandler:(id <EMSEventHandler>)eventHandler {
    NSParameterAssert(action);
    NSParameterAssert(eventHandler);

    if (self = [super init]) {
        _action = action;
        _eventHandler = eventHandler;
    }
    return self;
}

- (void)execute {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.eventHandler handleEvent:self.action[@"name"]
                               payload:self.action[@"payload"]];
    });
}

@end