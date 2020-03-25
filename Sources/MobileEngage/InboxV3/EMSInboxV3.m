//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInboxV3.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSInboxResult.h"
#import "EMSInboxResultParser.h"

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
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          EMSInboxResult *result = [self.inboxResultParser parseFromResponse:response];
                                          if (resultBlock) {
                                              resultBlock(result, nil);
                                          }
                                      });
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {
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
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inbox:tag:add"
                                                                              eventAttributes:@{
                                                                                      @"messageId": messageId,
                                                                                      @"tag": tag
                                                                              }
                                                                                    eventType:EventTypeInternal];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
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
    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"inbox:tag:remove"
                                                                              eventAttributes:@{
                                                                                      @"messageId": messageId,
                                                                                      @"tag": tag
                                                                              }
                                                                                    eventType:EventTypeInternal];
    [self.requestManager submitRequestModel:requestModel
                        withCompletionBlock:completionBlock];
}

@end