//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"
#import "EMSCoreCompletionHandler.h"
#import "EMSCoreCompletionHandlerProtocol.h"

@class EMSTimestampProvider;

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSRestClientCompletionBlock)(BOOL shouldContinue);

@interface EMSRESTClient : NSObject

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock;

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
          coreCompletionHandler:(id <EMSCoreCompletionHandlerProtocol>)completionHandler;

- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel
                       successBlock:(CoreSuccessBlock)successBlock
                         errorBlock:(CoreErrorBlock)errorBlock;

- (void)executeTaskWithOfflineCallbackStrategyWithRequestModel:(EMSRequestModel *)requestModel
                                                    onComplete:(EMSRestClientCompletionBlock)onComplete;


@end

NS_ASSUME_NONNULL_END
