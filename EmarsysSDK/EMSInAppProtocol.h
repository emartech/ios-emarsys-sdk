//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSEventHandler.h"

@protocol EMSInAppProtocol <NSObject>

@property(nonatomic, weak) id <EMSEventHandler> eventHandler;

- (void)pause;
- (void)resume;
- (BOOL)isPaused;

@end