//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSNotificationCenterManager.h"

@interface EMSNotificationCenterManager ()

@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

@end

@implementation EMSNotificationCenterManager

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter {
    NSParameterAssert(notificationCenter);
    if (self = [super init]) {
        _notificationCenter = notificationCenter;
        _observers = [NSArray new];
    }
    return self;
}

- (void)addHandlerBlock:(MEHandlerBlock)handlerBlock
        forNotification:(NSString *)notificationName {
    id observer = [self.notificationCenter addObserverForName:notificationName
                                                       object:nil
                                                        queue:nil
                                                   usingBlock:^(NSNotification *note) {
                                                       if (handlerBlock) {
                                                           handlerBlock();
                                                       }
                                                   }];
    NSMutableArray *mutableObservers = [self.observers mutableCopy];
    [mutableObservers addObject:observer];
    _observers = [NSArray arrayWithArray:mutableObservers];
}

- (void)removeHandlers {
    for (id observer in self.observers) {
        [self.notificationCenter removeObserver:observer];
    }
    _observers = @[];
}

@end