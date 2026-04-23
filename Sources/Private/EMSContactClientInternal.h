//
//
// Copyright © 2024 Emarsys-Technologies Kft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSContactClientProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EMSStorageProtocol;
@class EMSRequestFactory;
@class EMSRequestManager;
@class MERequestContext;
@class EMSSession;
@class PRERequestContext;
@class EMSCompletionBlockProvider;

@interface EMSContactClientInternal: NSObject <EMSContactClientProtocol>

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                 predictRequestContext:(PRERequestContext *)predictRequestContext
                               storage:(id<EMSStorageProtocol>)storage
                               session:(EMSSession *)session
               completionBlockProvider:(EMSCompletionBlockProvider *)completionBlockProvider;

@end

NS_ASSUME_NONNULL_END

