//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MobileEngageInternal.h"
#import "EMSBlocks.h"

@protocol EMSDeepLinkProtocol <NSObject>

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable EMSSourceHandler)sourceHandler;

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable EMSSourceHandler)sourceHandler
      withCompletionBlock:(EMSCompletionBlock)completionBlock;

@end