//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"
#import "EMSCoreCompletionHandler.h"
#import "EMSRESTClientCompletionProxyProtocol.h"

@class EMSTimestampProvider;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRESTClient : NSObject

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider;

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
            coreCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy;

@end

NS_ASSUME_NONNULL_END
