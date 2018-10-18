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

@implementation MERequestModelRepositoryFactory

- (instancetype)initWithInApp:(MEInApp *)inApp
               requestContext:(MERequestContext *)requestContext
                     dbHelper:(EMSSQLiteHelper *)dbHelper
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
       displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository {
    NSParameterAssert(inApp);
    NSParameterAssert(requestContext);
    NSParameterAssert(dbHelper);
    NSParameterAssert(buttonClickRepository);
    NSParameterAssert(displayedIAMRepository);
    if (self = [super init]) {
        _inApp = inApp;
        _requestContext = requestContext;
        _dbHelper = dbHelper;
        _buttonClickRepository = buttonClickRepository;
        _displayedIAMRepository = displayedIAMRepository;
    }
    return self;
}

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing {
    if (batchProcessing) {
        return [[MERequestRepositoryProxy alloc] initWithRequestModelRepository:[[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper]
                                                          buttonClickRepository:self.buttonClickRepository
                                                         displayedIAMRepository:self.displayedIAMRepository
                                                                          inApp:self.inApp
                                                                 requestContext:self.requestContext];
    }
    return [[EMSRequestModelRepository alloc] initWithDbHelper:self.dbHelper];
}

@end