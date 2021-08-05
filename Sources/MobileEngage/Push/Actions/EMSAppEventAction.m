//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSAppEventAction.h"

@interface EMSAppEventAction ()

@property(nonatomic, strong) NSDictionary *action;

@end

@implementation EMSAppEventAction

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                            eventHandler:(EMSEventHandlerBlock) eventHandler {
    NSParameterAssert(action);
    NSParameterAssert(eventHandler);

    if (self = [super init]) {
        _action = action;
        _eventHandler = eventHandler;
    }
    return self;
}

- (void)execute {
    __weak typeof(self) weakSelf = self;
    if (self.eventHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.eventHandler(weakSelf.action[@"name"],
                    weakSelf.action[@"payload"]);
        });
    }
}

@end