//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSDeepLinkProtocol <NSObject>

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(_Nullable EMSSourceHandler)sourceHandler;

- (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(_Nullable EMSSourceHandler)sourceHandler
      withCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
