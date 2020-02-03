//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCoreCompletionHandler.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "NSError+EMSCore.h"
#import "EMSResponseModel+EMSCore.h"
#import "EMSRequestModel+RequestIds.h"

@implementation EMSCoreCompletionHandler

- (instancetype)initWithSuccessBlock:(CoreSuccessBlock)successBlock
                          errorBlock:(CoreErrorBlock)errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    if (self = [super init]) {
        _successBlock = successBlock;
        _errorBlock = errorBlock;
    }
    return self;
}

- (EMSRESTClientCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;
    return ^(EMSRequestModel *requestModel, EMSResponseModel *responseModel, NSError *error) {
        NSParameterAssert(requestModel);
        NSParameterAssert(responseModel);
        if (!error && [responseModel isSuccess]) {
            for (NSString *requestId in requestModel.requestIds) {
                weakSelf.successBlock(requestId, responseModel);
            }
        } else {
            NSError *responseError = error ? error : [weakSelf errorWithData:responseModel.body
                                                                  statusCode:responseModel.statusCode];
            for (NSString *requestId in requestModel.requestIds) {
                weakSelf.errorBlock(requestId, responseError);
            }
        }
    };
}

- (NSError *)errorWithData:(NSData *)data
                statusCode:(NSInteger)statusCode {
    NSString *description =
        data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"Unknown error";
    return [NSError errorWithCode:@(statusCode).intValue
             localizedDescription:description];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToHandler:other];
}

- (BOOL)isEqualToHandler:(EMSCoreCompletionHandler *)handler {
    if (self == handler)
        return YES;
    if (handler == nil)
        return NO;
    if (self.successBlock != handler.successBlock)
        return NO;
    if (self.errorBlock != handler.errorBlock)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) self.successBlock;
    hash = hash * 31u + (NSUInteger) self.errorBlock;
    return hash;
}

@end