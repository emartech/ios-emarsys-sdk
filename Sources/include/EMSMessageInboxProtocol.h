//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@class EMSMessage;

@protocol EMSMessageInboxProtocol <NSObject>

- (void)fetchMessagesWithResultBlock:(EMSInboxMessageResultBlock)resultBlock;

- (void)trackMessageOpenWithMessage:(EMSMessage *)message;

- (void)trackMessageOpenWithMessage:(EMSMessage *)message
                    completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end