//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@protocol EMSInAppProtocol <NSObject>

@property(nonatomic, strong) EMSEventHandlerBlock eventHandler;

- (void)pause;

- (void)resume;

- (BOOL)isPaused;

@end