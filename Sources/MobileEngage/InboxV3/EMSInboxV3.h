//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSMessageInboxProtocol.h"

@class EMSRequestFactory;
@class EMSRequestManager;
@class EMSInboxResultParser;

NS_ASSUME_NONNULL_BEGIN

@interface EMSInboxV3 : NSObject <EMSMessageInboxProtocol>

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                     inboxResultParser:(EMSInboxResultParser *)inboxResultParser;

@end

NS_ASSUME_NONNULL_END