//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInboxV3.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSInboxResultParser.h"

typedef BOOL (^EMSMessageConditionBlock)(EMSMessage *message);

typedef void (^EMSRunnerBlock)(void);

typedef void (^EMSRequestUnnecessaryBlock)(void);

@interface EMSInboxV3 ()

@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSInboxResultParser *inboxResultParser;

@end

@implementation EMSInboxV3

- (instancetype)initWithRequestFactory:(EMSRequestFactory *)requestFactory
                        requestManager:(EMSRequestManager *)requestManager
                     inboxResultParser:(EMSInboxResultParser *)inboxResultParser {
    NSParameterAssert(requestFactory);
    NSParameterAssert(requestManager);
    NSParameterAssert(inboxResultParser);
    if (self = [super init]) {
        _requestFactory = requestFactory;
        _requestManager = requestManager;
        _inboxResultParser = inboxResultParser;
    }
    return self;
}

- (void)fetchMessagesWithResultBlock:(EMSInboxMessageResultBlock)resultBlock {
    NSParameterAssert(resultBlock);
    EMSRequestModel *requestModel = [self.requestFactory createMessageInboxRequestModel];
    __weak typeof(self) weakSelf = self;
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            EMSInboxResult *result = [weakSelf.inboxResultParser parseFromResponse:response];
            weakSelf.messages = result.messages;
            if (resultBlock) {
                resultBlock(result, nil);
            }
        });
    }
                                    errorBlock:^(NSString *requestId, NSError *error) {
        weakSelf.messages = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultBlock) {
                resultBlock(nil, error);
            }
        });
    }];
}

- (void)addTag:(NSString *)tag
    forMessage:(NSString *)messageId {
    [self addTag:tag
      forMessage:messageId
 completionBlock:nil];
}

- (void) addTag:(NSString *)tag
     forMessage:(NSString *)messageId
completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSParameterAssert(tag);
    NSParameterAssert(messageId);
    __weak typeof(self) weakSelf = self;
    [self updateTagWithConditionBlock:^BOOL(EMSMessage *message) {
        return [message.id isEqualToString:messageId] && ![message.tags containsObject:[tag lowercaseString]];
    }             runnerBlock:^{
        EMSRequestModel *requestModel = [weakSelf.requestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                                                      eventAttributes:@{
            @"messageId": messageId,
            @"tag": [tag lowercaseString]
        }
                                                                                            eventType:EventTypeInternal];
        [weakSelf.requestManager submitRequestModel:requestModel
                                withCompletionBlock:completionBlock];
    }
              requestUnnecessaryBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }];
}

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId {
    [self removeTag:tag
        fromMessage:messageId
    completionBlock:nil];
}

- (void)removeTag:(NSString *)tag
      fromMessage:(NSString *)messageId
  completionBlock:(_Nullable EMSCompletionBlock)completionBlock {
    NSParameterAssert(tag);
    NSParameterAssert(messageId);
    __weak typeof(self) weakSelf = self;
    [self updateTagWithConditionBlock:^BOOL(EMSMessage *message) {
        return [message.id isEqualToString:messageId] && [message.tags containsObject:[tag lowercaseString]];
    }             runnerBlock:^{
        EMSRequestModel *requestModel = [weakSelf.requestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                                                      eventAttributes:@{
            @"messageId": messageId,
            @"tag": [tag lowercaseString]
        }
                                                                                            eventType:EventTypeInternal];
        [weakSelf.requestManager submitRequestModel:requestModel
                                withCompletionBlock:completionBlock];
    }
              requestUnnecessaryBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }];
}

- (void)updateTagWithConditionBlock:(EMSMessageConditionBlock)conditionBlock
                        runnerBlock:(EMSRunnerBlock)runnerBlock
            requestUnnecessaryBlock:(EMSRequestUnnecessaryBlock)requestUnnecessaryBlock {
    if (self.messages) {
        BOOL isRunnerBlockWasExecuted = NO;
        for (EMSMessage *message in self.messages) {
            if (conditionBlock(message)) {
                runnerBlock();
                isRunnerBlockWasExecuted = YES;
                break;
            }
        }
        if (!isRunnerBlockWasExecuted) {
            requestUnnecessaryBlock();
        }
    } else {
        runnerBlock();
    }
}


@end
