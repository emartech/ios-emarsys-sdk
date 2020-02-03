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

@implementation MERequestModelRepositoryFactory

- (instancetype)initWithInApp:(MEInApp *)inApp
               requestContext:(MERequestContext *)requestContext
                     dbHelper:(EMSSQLiteHelper *)dbHelper
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
       displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                     endpoint:(EMSEndpoint *)endpoint {
    NSParameterAssert(inApp);
    NSParameterAssert(requestContext);
    NSParameterAssert(dbHelper);
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(displayedIAMRepository);
    NSParameterAssert(endpoint);
    if (self = [super init]) {
        _inApp = inApp;
        _requestContext = requestContext;
        _dbHelper = dbHelper;
        _buttonClickRepository = buttonClickRepository;
        _displayedIAMRepository = displayedIAMRepository;
        _endpoint = endpoint;
    }
    return self;
}

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing {
    if (batchProcessing) {
        return [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper]
                                                          buttonClickRepository:self.buttonClickRepository
                                                         displayedIAMRepository:self.displayedIAMRepository
                                                                          inApp:self.inApp
                                                                 requestContext:self.requestContext
                                                                       endpoint:self.endpoint];
    }
    return [[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper];
}

@end