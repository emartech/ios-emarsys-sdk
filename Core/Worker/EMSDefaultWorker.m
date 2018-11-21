//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSDefaultWorker.h"
#import "NSError+EMSCore.h"
#import "EMSRequestModelSelectFirstSpecification.h"
#import "EMSFilterByValuesSpecification.h"
#import "EMSLogger.h"
#import "EMSCoreTopic.h"
#import "EMSRequestModel+RequestIds.h"
#import "EMSSchemaContract.h"

@interface EMSDefaultWorker ()

@property(nonatomic, assign) BOOL locked;
@property(nonatomic, strong) EMSConnectionWatchdog *connectionWatchdog;
@property(nonatomic, strong) id <EMSRequestModelRepositoryProtocol> repository;
@property(nonatomic, strong) EMSRESTClient *client;
@property(nonatomic, strong) CoreErrorBlock errorBlock;
@property(nonatomic, strong) NSOperationQueue *coreQueue;

- (EMSRequestModel *)nextNonExpiredModel;

- (BOOL)isExpired:(EMSRequestModel *)model;

@end

@implementation EMSDefaultWorker

#pragma mark - Init

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
                     requestRepository:(id <EMSRequestModelRepositoryProtocol>)repository
                    connectionWatchdog:(EMSConnectionWatchdog *)connectionWatchdog
                            restClient:(EMSRESTClient *)client
                            errorBlock:(CoreErrorBlock)errorBlock {
    if (self = [super init]) {
        NSParameterAssert(operationQueue);
        NSParameterAssert(repository);
        NSParameterAssert(connectionWatchdog);
        NSParameterAssert(client);
        NSParameterAssert(errorBlock);
        _coreQueue = operationQueue;
        _repository = repository;
        _connectionWatchdog = connectionWatchdog;
        [_connectionWatchdog setConnectionChangeListener:self];
        _client = client;
        _errorBlock = errorBlock;
    }
    return self;
}

#pragma mark - WorkerProtocol

- (void)run {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:@"Entered run"];
    if (![self isLocked] && [self.connectionWatchdog isConnected] && ![self.repository isEmpty]) {
        [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                        message:@"Connection is OK and requestModelRepository is not empty"];
        [self lock];
        EMSRequestModel *model = [self nextNonExpiredModel];
        [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                        message:[NSString stringWithFormat:@"First non expired model: %@", model]];
        __weak typeof(self) weakSelf = self;
        if (model) {
            [self.client executeTaskWithOfflineCallbackStrategyWithRequestModel:model
                                                                     onComplete:^(BOOL shouldContinue) {
                                                                         [weakSelf unlock];
                                                                         if (shouldContinue) {
                                                                             [weakSelf.repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:model.requestIds
                                                                                                                                                         column:REQUEST_COLUMN_NAME_REQUEST_ID]];
                                                                             [weakSelf.coreQueue addOperationWithBlock:^{
                                                                                 [weakSelf run];
                                                                             }];
                                                                         }
                                                                     }];
        } else {
            [self unlock];
        }
    }
}

#pragma mark - LockableProtocol

- (void)lock {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:[NSString stringWithFormat:@"Lock status change from: %@, to: Locked", _locked ? @"Locked" : @"Not locked"]];
    _locked = YES;
}

- (void)unlock {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:[NSString stringWithFormat:@"Lock status change from: %@, to: Not locked", _locked ? @"Locked" : @"Not locked"]];

    _locked = NO;
}

- (BOOL)isLocked {
    [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                    message:[NSString stringWithFormat:@"Current locked status: %@", _locked ? @"Locked" : @"Not locked"]];
    return _locked;
}

#pragma mark - EMSConnectionChangeListener

- (void)connectionChangedToNetworkStatus:(EMSNetworkStatus)networkStatus
                        connectionStatus:(BOOL)connected {
    if (connected) {
        [self run];
    }
}

#pragma mark - Private methods

- (EMSRequestModel *)nextNonExpiredModel {
    EMSRequestModel *model;
    while ((model = [self.repository query:[EMSRequestModelSelectFirstSpecification new]].firstObject) && [self isExpired:model]) {
        [self.repository remove:[[EMSFilterByValuesSpecification alloc] initWithValues:model.requestIds
                                                                                column:REQUEST_COLUMN_NAME_REQUEST_ID]];
        self.errorBlock(model.requestId, [NSError errorWithCode:408
                                                      localizedDescription:@"Request expired"]);
    }
    return model;
}

- (BOOL)isExpired:(EMSRequestModel *)model {
    BOOL expired = [[NSDate date] timeIntervalSince1970] - [[model timestamp] timeIntervalSince1970] > [model ttl];
    if (expired) {
        [EMSLogger logWithTopic:EMSCoreTopic.offlineTopic
                        message:[NSString stringWithFormat:@"Model expired: %@", model]];
    }
    return expired;
}

@end
