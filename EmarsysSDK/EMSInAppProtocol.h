//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEEventHandler.h"

@protocol EMAInAppProtocol <NSObject>

@property(nonatomic, weak) id <MEEventHandler> eventHandler;

- (void)pause;
- (void)resume;
- (BOOL)isPaused;

@end