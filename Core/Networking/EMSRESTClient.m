//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSRESTClient.h"
#import "NSURLRequest+EMSCore.h"
#import "NSError+EMSCore.h"
#import "EMSResponseModel.h"
#import "EMSTimestampProvider.h"
#import "EMSMacros.h"
#import "EMSInDatabaseTime.h"
#import "EMSNetworkingTime.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSRequestModelMapperProtocol.h"
#import "EMSAbstractResponseHandler.h"

@interface EMSRESTClient () <NSURLSessionDelegate>

@property(nonatomic, strong) CoreSuccessBlock successBlock;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) NSArray<id <EMSRequestModelMapperProtocol>> *requestModelMappers;
@property(nonatomic, strong) NSArray<EMSAbstractResponseHandler *> *responseHandlers;

@end

@implementation EMSRESTClient

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider
              additionalHeaders:(nullable NSDictionary<NSString *, NSString *> *)additionalHeaders
            requestModelMappers:(nullable NSArray<id <EMSRequestModelMapperProtocol>> *)requestModelMappers
               responseHandlers:(nullable NSArray<EMSAbstractResponseHandler *> *)responseHandlers {
    NSParameterAssert(session);
    NSParameterAssert(queue);
    NSParameterAssert(timestampProvider);
    if (self = [super init]) {
        _session = session;
        _queue = queue;
        _timestampProvider = timestampProvider;
        _additionalHeaders = additionalHeaders;
        _requestModelMappers = requestModelMappers;
        _responseHandlers = responseHandlers;
    }
    return self;
}

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
            coreCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy {
    NSParameterAssert(requestModel);
    NSParameterAssert((NSObject *) completionProxy);

    NSDate *networkingStartTime = [self.timestampProvider provideTimestamp];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:[self createURLRequestFromRequestModel:requestModel]
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     [weakSelf.queue addOperationWithBlock:^{
                                                         NSError *runtimeError = [weakSelf errorWithData:data
                                                                                                response:response
                                                                                                   error:error];
                                                         EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:(NSHTTPURLResponse *) response
                                                                                                                                        data:data
                                                                                                                                requestModel:requestModel
                                                                                                                                   timestamp:[weakSelf.timestampProvider provideTimestamp]];
                                                         [weakSelf handleResponse:responseModel];
                                                         if (!error && [responseModel isSuccess]) {
                                                             EMSLog([[EMSInDatabaseTime alloc] initWithRequestModel:requestModel
                                                                                                            endDate:networkingStartTime]);
                                                         }
                                                         EMSLog([[EMSNetworkingTime alloc] initWithResponseModel:responseModel
                                                                                                       startDate:networkingStartTime]);
                                                         if (completionProxy.completionBlock) {
                                                             completionProxy.completionBlock(requestModel, responseModel, runtimeError);
                                                         }
                                                     }];
                                                 }];
    [task resume];
}

- (NSError *)errorWithData:(NSData *)data
                  response:(NSURLResponse *)response
                     error:(NSError *)error {
    NSError *runtimeError = error;
    if (!error) {
        if (!data) {
            runtimeError = [NSError errorWithCode:1500
                             localizedDescription:@"Missing data"];
        }
        if (!response) {
            runtimeError = [NSError errorWithCode:1500
                             localizedDescription:@"Missing response"];
        }
    }
    return runtimeError;
}

- (NSURLRequest *)createURLRequestFromRequestModel:(EMSRequestModel *)requestModel {
    return [NSURLRequest requestWithRequestModel:[self finalizeRequestModel:requestModel]];
}

- (EMSRequestModel *)finalizeRequestModel:(EMSRequestModel *)requestModel {
    EMSRequestModel *resultModel = [self extendRequestModelWithAdditionalHeaders:requestModel];
    for (id modelMapper in self.requestModelMappers) {
        if ([modelMapper shouldHandleWithRequestModel:resultModel]) {
            resultModel = [modelMapper modelFromModel:resultModel];
        }
    }
    return resultModel;
}

- (EMSRequestModel *)extendRequestModelWithAdditionalHeaders:(EMSRequestModel *)requestModel {
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:requestModel.headers];
    [headers addEntriesFromDictionary:self.additionalHeaders];
    return [[EMSRequestModel alloc] initWithRequestId:requestModel.requestId
                                            timestamp:requestModel.timestamp
                                               expiry:requestModel.ttl
                                                  url:requestModel.url
                                               method:requestModel.method
                                              payload:requestModel.payload
                                              headers:[NSDictionary dictionaryWithDictionary:headers]
                                               extras:requestModel.extras];
}

- (void)handleResponse:(EMSResponseModel *)responseModel {
    for (EMSAbstractResponseHandler *handler in self.responseHandlers) {
        [handler processResponse:responseModel];
    }
}

@end

