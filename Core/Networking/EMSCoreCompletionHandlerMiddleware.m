//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCoreCompletionHandlerMiddleware.h"
#import "EMSWorkerProtocol.h"
#import "EMSRequestModelRepositoryProtocol.h"
#import "EMSResponseModel.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSSchemaContract.h"
#import "EMSResponseModel+EMSCore.h"

@interface EMSCoreCompletionHandlerMiddleware ()

@property(nonatomic, assign) id <EMSRESTClientCompletionProxyProtocol> completionHandler;
@property(nonatomic, assign) id <EMSWorkerProtocol> worker;
@property(nonatomic, assign) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, assign) NSOperationQueue *operationQueue;

@end

@implementation EMSCoreCompletionHandlerMiddleware

- (instancetype)initWithCoreCompletionHandler:(id <EMSRESTClientCompletionProxyProtocol>)completionHandler
                                       worker:(id <EMSWorkerProtocol>)worker
                            requestRepository:(id <EMSRequestModelRepositoryProtocol>)requestRepository
                               operationQueue:(NSOperationQueue *)operationQueue {
    NSParameterAssert(completionHandler);
    NSParameterAssert(worker);
    NSParameterAssert(requestRepository);
    NSParameterAssert(operationQueue);
    if (self = [super init]) {
        _completionHandler = completionHandler;
        _worker = worker;
        _requestRepository = requestRepository;
        _operationQueue = operationQueue;
    }
    return self;
}

- (EMSRESTClientCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;

    return ^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        [weakSelf.operationQueue addOperationWithBlock:^{
            if ([weakSelf shouldContinueWorkerWithResponseModel:responseModel
                                                          error:error]) {
                [weakSelf.requestRepository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:@[requestModel.requestId]
                                                                                                   column:REQUEST_COLUMN_NAME_REQUEST_ID]];
            }
            [weakSelf.worker unlock];
            if ([weakSelf shouldContinueWorkerWithResponseModel:responseModel
                                                          error:error]) {
                [weakSelf.worker run];
                weakSelf.completionHandler.completionBlock(requestModel, responseModel, error);
            }
        }];
    };
}

- (BOOL)shouldContinueWorkerWithResponseModel:(EMSResponseModel *)responseModel error:(NSError *)error {
    return [self isNonRetriableStatus:responseModel.statusCode] || responseModel.isSuccess || [self isNonRetriableError:error.code];
}

- (BOOL)isNonRetriableError:(NSInteger)errorCode {
    return errorCode == NSURLErrorCannotFindHost || errorCode == NSURLErrorBadURL || errorCode == NSURLErrorUnsupportedURL;
}

- (BOOL)isNonRetriableStatus:(NSInteger)statusCode {
    return statusCode >= 400 && statusCode < 500 && statusCode != 408;
}


@end