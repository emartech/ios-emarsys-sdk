//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSCoreCompletionHandler.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "NSError+EMSCore.h"

@interface EMSCoreCompletionHandler ()

@property(nonatomic, readonly) CoreSuccessBlock successBlock;
@property(nonatomic, readonly) CoreErrorBlock errorBlock;

@end

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
        if (!error && [self isStatusCodeOK:responseModel.statusCode]) {
            weakSelf.successBlock(requestModel.requestId, responseModel);
        } else {
            NSError *responseError = error ? error : [weakSelf errorWithData:responseModel.body
                                                                  statusCode:responseModel.statusCode];
            weakSelf.errorBlock(requestModel.requestId, responseError);
        }
    };
}

- (BOOL)isStatusCodeOK:(NSInteger)statusCode {
    return statusCode >= 200 && statusCode <= 299;
}

- (NSError *)errorWithData:(NSData *)data
                statusCode:(NSInteger)statusCode {
    NSString *description =
        data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"Unknown error";
    return [NSError errorWithCode:@(statusCode).intValue
             localizedDescription:description];
}


@end