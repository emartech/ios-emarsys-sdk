//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"

@class EMSMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol EMSMessageInboxProtocol <NSObject>

- (void)fetchMessagesWithResultBlock:(EMSInboxMessageResultBlock)resultBlock;

- (void)addTag:(NSString *)tag
    forMessage:(NSString *)messageId;

- (void) addTag:(NSString *)tag
     forMessage:(NSString *)messageId
completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId;

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId
  completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END