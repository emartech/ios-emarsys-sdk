//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@class EMSMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol EMSMessageInboxProtocol <NSObject>

- (void)fetchMessagesWithResultBlock:(EMSInboxMessageResultBlock)resultBlock
    NS_SWIFT_NAME(fetchMessages(resultBlock:));

- (void)addTag:(NSString *)tag
    forMessage:(NSString *)messageId
    NS_SWIFT_NAME(addTag(tag:messageId:));

- (void) addTag:(NSString *)tag
     forMessage:(NSString *)messageId
completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(addTag(tag:messageId:completionBlock:));

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId
    NS_SWIFT_NAME(removeTag(tag:messageId:));

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId
  completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(removeTag(tag:messageId:completionBlock:));

@end

NS_ASSUME_NONNULL_END
