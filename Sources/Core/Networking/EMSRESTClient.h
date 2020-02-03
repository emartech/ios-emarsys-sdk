//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"
#import "EMSCoreCompletionHandler.h"
#import "EMSRESTClientCompletionProxyProtocol.h"

@class EMSTimestampProvider;
@protocol EMSRequestModelMapperProtocol;
@class EMSAbstractResponseHandler;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRESTClient : NSObject

@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *additionalHeaders;

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider
              additionalHeaders:(nullable NSDictionary<NSString *, NSString *> *)additionalHeaders
            requestModelMappers:(nullable NSArray<id <EMSRequestModelMapperProtocol>> *)requestModelMappers
               responseHandlers:(nullable NSArray<EMSAbstractResponseHandler *> *)responseHandlers;

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
            coreCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy;

@end

NS_ASSUME_NONNULL_END
