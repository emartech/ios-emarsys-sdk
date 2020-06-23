//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^MEHandlerBlock)(void);

@interface EMSNotificationCenterManager : NSObject

@property(nonatomic, readonly) NSArray *observers;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)addHandlerBlock:(MEHandlerBlock)handlerBlock
        forNotification:(NSString *)notificationName;

- (void)removeHandlers;

@end
