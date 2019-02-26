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

@interface EMSRESTClient () <NSURLSessionDelegate>

@property(nonatomic, strong) CoreSuccessBlock successBlock;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSURLSession *session;
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;

@end

@implementation EMSRESTClient

- (instancetype)initWithSession:(NSURLSession *)session
                          queue:(NSOperationQueue *)queue
              timestampProvider:(EMSTimestampProvider *)timestampProvider {
    NSParameterAssert(session);
    NSParameterAssert(queue);
    NSParameterAssert(timestampProvider);
    if (self = [super init]) {
        _session = session;
        _queue = queue;
        _timestampProvider = timestampProvider;
    }
    return self;
}

- (void)executeWithRequestModel:(EMSRequestModel *)requestModel
            coreCompletionProxy:(id <EMSRESTClientCompletionProxyProtocol>)completionProxy {
    NSParameterAssert(requestModel);
    NSParameterAssert((NSObject *) completionProxy);
    __weak typeof(self) weakSelf = self;
    NSDate *networkingStartTime = [self.timestampProvider provideTimestamp];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:[NSURLRequest requestWithRequestModel:requestModel]
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     [weakSelf.queue addOperationWithBlock:^{
                                                         NSError *runtimeError = [weakSelf errorWithData:data
                                                                                                response:response
                                                                                                   error:error];
                                                         EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithHttpUrlResponse:(NSHTTPURLResponse *) response
                                                                                                                                        data:data
                                                                                                                                requestModel:requestModel
                                                                                                                                   timestamp:[weakSelf.timestampProvider provideTimestamp]];
                                                         if (!error && [responseModel isSuccess]) {
                                                             EMSLog([[EMSInDatabaseTime alloc] initWithRequestModel:requestModel
                                                                                                            endDate:networkingStartTime]);
                                                             EMSLog([[EMSNetworkingTime alloc] initWithResponseModel:responseModel
                                                                                                           startDate:networkingStartTime]);
                                                         }
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

@end

