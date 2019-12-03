//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"

@protocol EMSRequestModelRepositoryProtocol;
@class MEInApp;
@class MERequestContext;
@class MEButtonClickRepository;
@class MEDisplayedIAMRepository;
@class EMSEndpoint;

@interface MERequestModelRepositoryFactory : NSObject

@property(nonatomic, readonly) MEInApp *inApp;
@property(nonatomic, readonly) MERequestContext *requestContext;
@property(nonatomic, readonly) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, readonly) MEDisplayedIAMRepository *displayedIAMRepository;
@property(nonatomic, readonly) EMSSQLiteHelper *dbHelper;
@property(nonatomic, readonly) EMSEndpoint *endpoint;

- (instancetype)initWithInApp:(MEInApp *)inApp
               requestContext:(MERequestContext *)requestContext
                     dbHelper:(EMSSQLiteHelper *)dbHelper
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
       displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                     endpoint:(EMSEndpoint *)endpoint;

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing;

@end