//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "NSError+EMSCore.h"
#import "EMSQueryOldestRowSpecification.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSRequestModel+RequestIds.h"
#import "EMSSchemaContract.h"
#import "EMSMacros.h"
#import "EMSOfflineQueueSize.h"
#import "EMSFilterByNothingSpecification.h"
#import "EMSRESTClientCompletionProxyFactory.h"

@interface EMSDefaultWorker ()

@property(nonatomic, assign) BOOL locked;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> repository;
@property(nonatomic, strong) EMSRESTClient *client;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSOperationQueue *coreQueue;
@property(nonatomic, strong) id <EMSRESTClientCompletionProxyProtocol> completionMiddleware;

- (EMSRequestModel *)nextNonExpiredModel;

- (BOOL)isExpired:(EMSRequestModel *)model;

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                    connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                            restClient:(EMSRESTClient *)client
                            errorBlock:(CoreErrorBlock)errorBlock
                          proxyFactory:(EMSRESTClientCompletionProxyFactory *)proxyFactory {
    if (self = [super init]) {
        NSParameterAssert(operationQueue);
        NSParameterAssert(repository);
        NSParameterAssert(connectionWatchdog);
        NSParameterAssert(client);
        NSParameterAssert(errorBlock);
        NSParameterAssert(proxyFactory);
        _coreQueue = operationQueue;
        _repository = repository;
        _connectionWatchdog = connectionWatchdog;
        [_connectionWatchdog setConnectionChangeListener:self];
        _client = client;
        _errorBlock = errorBlock;
        _completionMiddleware = [proxyFactory createWithWorker:self
                                                  successBlock:nil
                                                    errorBlock:nil];
    }
    return self;
}

#pragma mark - WorkerProtocol

- (void)run {
    if (![self isLocked] && [self.connectionWatchdog isConnected] && ![self.repository isEmpty]) {
        [self lock];
        EMSRequestModel *model = [self nextNonExpiredModel];
        if (model) {
            [self.client executeWithRequestModel:model
                             coreCompletionProxy:self.completionMiddleware];
        } else {
            [self unlock];
        }
    }
}

#pragma mark - LockableProtocol

- (void)lock {
    _locked = YES;
}

- (void)unlock {
    _locked = NO;
}

- (BOOL)isLocked {
    return _locked;
}

#pragma mark - EMSConnectionChangeListener

- (void)connectionChangedToNetworkStatus:(EMSNetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected {
    if (connected) {
        NSUInteger queueSize = [[self.repository query:[[EMSFilterByNothingSpecification alloc] init]] count];
        EMSLog([[EMSOfflineQueueSize alloc] initWithQueueSize:queueSize]);
        [self run];
    }
}

#pragma mark - Private methods

- (EMSRequestModel *)nextNonExpiredModel {
    EMSRequestModel *model;
    while ((model = [self.repository query:[EMSQueryOldestRowSpecification new]].firstObject) && [self isExpired:model]) {
        [self.repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:model.requestIds
                                                                                column:REQUEST_COLUMN_NAME_REQUEST_ID]];
        self.errorBlock(model.requestId, [NSError errorWithCode:408
                                           localizedDescription:@"Request expired"]);
    }
    return model;
}

- (BOOL)isExpired:(EMSRequestModel *)model {
    return [[NSDate date] timeIntervalSince1970] - [[model timestamp] timeIntervalSince1970] > [model ttl];
}

@end
