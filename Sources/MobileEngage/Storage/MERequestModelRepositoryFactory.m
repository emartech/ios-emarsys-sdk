//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "EMSRequestModelRepository.h"
#import "MERequestModelRepositoryFactory.h"
#import "MEButtonClickRepository.h"
#import "MERequestRepositoryProxy.h"
#import "MEDisplayedIAMRepository.h"
#import "MEInApp.h"
#import "MERequestContext.h"
#import "EMSEndpoint.h"
#import "EMSStorage.h"

@implementation MERequestModelRepositoryFactory

- (instancetype)initWithInApp:(MEInApp *)inApp
               requestContext:(MERequestContext *)requestContext
                     dbHelper:(EMSSQLiteHelper *)dbHelper
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
       displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                     endpoint:(EMSEndpoint *)endpoint
               operationQueue:(NSOperationQueue *)operationQueue
                      storage:(EMSStorage *)storage {
    NSParameterAssert(inApp);
    NSParameterAssert(requestContext);
    NSParameterAssert(dbHelper);
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(displayedIAMRepository);
    NSParameterAssert(endpoint);
    NSParameterAssert(operationQueue);
    NSParameterAssert(storage);
    if (self = [super init]) {
        _inApp = inApp;
        _requestContext = requestContext;
        _dbHelper = dbHelper;
        _buttonClickRepository = buttonClickRepository;
        _displayedIAMRepository = displayedIAMRepository;
        _endpoint = endpoint;
        _operationQueue = operationQueue;
        _storage = storage;
    }
    return self;
}

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing {
    if (batchProcessing) {
        return [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper
                                                                                                                     operationQueue:self.operationQueue]
                                                          buttonClickRepository:self.buttonClickRepository
                                                         displayedIAMRepository:self.displayedIAMRepository
                                                                          inApp:self.inApp
                                                                 requestContext:self.requestContext
                                                                       endpoint:self.endpoint
                                                                        storage:self.storage];
    }
    return [[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper
                                                operationQueue:self.operationQueue];
}

@end