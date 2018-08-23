//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEEventHandler.h"

@protocol EMAInAppProtocol <NSObject>

@property(nonatomic, weak) id <MEEventHandler> eventHandler;
@property(nonatomic, assign) BOOL paused;

@end