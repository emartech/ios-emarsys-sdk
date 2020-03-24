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
    EMSRequestModel *requestModel = [self.requestFactory createMessageInboxRequestModel];
    [self.requestManager submitRequestModelNow:requestModel
                                  successBlock:^(NSString *requestId, EMSResponseModel *response) {
                                      EMSInboxResult *result = [self.inboxResultParser parseFromResponse:response];
                                      resultBlock(result, nil);
                                  }
                                    errorBlock:^(NSString *requestId, NSError *error) {
                                        resultBlock(nil, error);
                                    }];

}

- (void)trackMessageOpenWithMessage:(EMSMessage *)message {

}

- (void)trackMessageOpenWithMessage:(EMSMessage *)message
                    completionBlock:(_Nullable EMSCompletionBlock)completionBlock {

}

@end