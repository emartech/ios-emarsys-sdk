//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSCoreCompletion.h"
#import "EMSRequestModel.h"
#import "EMSCoreCompletionHandler.h"
#import "EMSRESTClientCompletionProxyProtocol.h"

@class EMSTimestampProvider;
@class EMSAbstractResponseHandler;
@protocol EMSRequestModelMapperProtocol;
@protocol EMSResponseBodyParserProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface EMSRESTClient : NSObject

@property(nonatomic, readonly) NSDictionary<NSString *, NSString *> *additionalHeaders;
@property(nonatomic, strong) NSArray<id <EMSRequestModelMapperProtocol>> *requestModelMappers;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) id <EMSResponseBodyParserProtocol>mobileEngageBodyParser;

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider
              additionalHeaders:(nullable NSDictionary<NSString *, NSString *> *)additionalHeaders
            requestModelMappers:(nullable NSArray<id <EMSRequestModelMapperProtocol>> *)requestModelMappers
               responseHandlers:(nullable NSArray<EMSAbstractResponseHandler *> *)responseHandlers
         mobileEngageBodyParser:(nullable id <EMSResponseBodyParserProtocol>)mobileEngageBodyParser;

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
            coreCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy;

@end

NS_ASSUME_NONNULL_END
