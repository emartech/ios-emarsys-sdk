//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"

@class EMSTimestampProvider;

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSRestClientCompletionBlock)(BOOL shouldContinue);

@interface EMSRESTClient : NSObject

+ (EMSRESTClient *)clientWithSession:(NSURLSession *)session;

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock;

+ (EMSRESTClient *)clientWithSuccessBlock:(CoreSuccessBlock)successBlock
                               errorBlock:(CoreErrorBlock)errorBlock
                                  session:(nullable NSURLSession *)session
                        timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (void)executeTaskWithRequestModel:(EMSRequestModel *)requestModel
                       successBlock:(CoreSuccessBlock)successBlock
                         errorBlock:(CoreErrorBlock)errorBlock;

- (void)executeTaskWithOfflineCallbackStrategyWithRequestModel:(EMSRequestModel *)requestModel
                                                    onComplete:(EMSRestClientCompletionBlock)onComplete;


@end

NS_ASSUME_NONNULL_END
