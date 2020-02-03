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
#import "EMSRequestModel+RequestIds.h"

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
                [weakSelf.requestRepository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:requestModel.requestIds
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

- (BOOL)shouldContinueWorkerWithResponseModel:(EMSResponseModel *)responseModel
                                        error:(NSError *)error {
    return [self isNonRetriableStatus:responseModel.statusCode] || responseModel.isSuccess || [self isNonRetriableError:error.code];
}

- (BOOL)isNonRetriableError:(NSInteger)errorCode {
    return errorCode == NSURLErrorCannotFindHost || errorCode == NSURLErrorBadURL || errorCode == NSURLErrorUnsupportedURL;
}

- (BOOL)isNonRetriableStatus:(NSInteger)statusCode {
    return statusCode >= 400 && statusCode < 500 && statusCode != 408 && statusCode != 429;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToMiddleware:other];
}

- (BOOL)isEqualToMiddleware:(EMSCoreCompletionHandlerMiddleware *)middleware {
    if (self == middleware)
        return YES;
    if (middleware == nil)
        return NO;
    if (self.completionHandler != middleware.completionHandler && ![self.completionHandler isEqual:middleware.completionHandler])
        return NO;
    if (self.worker != middleware.worker && ![self.worker isEqual:middleware.worker])
        return NO;
    if (self.requestRepository != middleware.requestRepository && ![self.requestRepository isEqual:middleware.requestRepository])
        return NO;
    if (self.operationQueue != middleware.operationQueue && ![self.operationQueue isEqual:middleware.operationQueue])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.completionHandler hash];
    hash = hash * 31u + [self.worker hash];
    hash = hash * 31u + [self.requestRepository hash];
    hash = hash * 31u + [self.operationQueue hash];
    return hash;
}

@end