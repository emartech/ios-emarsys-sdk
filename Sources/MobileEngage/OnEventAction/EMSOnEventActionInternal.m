//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSOnEventActionInternal.h"

@interface EMSOnEventActionInternal()

@property(nonatomic, strong) EMSActionFactory *actionFactory;

@end

@implementation EMSOnEventActionInternal

@synthesize eventHandler = _eventHandler;

- (instancetype)initWithActionFactory:(EMSActionFactory *)actionFactory {
    if (self = [super init]) {
        _actionFactory = actionFactory;
    }
    return self;
}

- (void)setEventHandler:(id<EMSEventHandler>)eventHandler {
    _eventHandler = eventHandler;
    self.actionFactory.eventHandler = eventHandler;
}

@end
