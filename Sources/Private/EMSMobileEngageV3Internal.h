//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSMobileEngageProtocol.h"

@protocol EMSStorageProtocol;
@class EMSRequestFactory;
@class EMSRequestManager;
@class MERequestContext;
@class EMSSession;
@class EMSCompletionBlockProvider;

@interface EMSMobileEngageV3Internal : NSObject <EMSMobileEngageProtocol>

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                        requestContext:(MERequestContext *)requestContext
                               storage:(id<EMSStorageProtocol>)storage
                               session:(EMSSession *)session
               completionBlockProvider:(EMSCompletionBlockProvider *)completionBlockProvider;

@end
