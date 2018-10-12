//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSDependencyContainer.h"

@interface EMSDependencyInjection : NSObject

@property(class, nonatomic, readonly) EMSDependencyContainer *dependencyContainer;

+ (void)setupWithDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer;

+ (void)tearDown;

@end