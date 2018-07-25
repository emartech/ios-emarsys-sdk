//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface MEInApp : NSObject

@property(nonatomic, weak, nullable) id <MEEventHandler> eventHandler;
@property(nonatomic, assign) BOOL paused;

@end

NS_ASSUME_NONNULL_END