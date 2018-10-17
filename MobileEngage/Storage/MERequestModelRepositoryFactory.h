//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EMSRequestModelRepositoryProtocol;
@class MEInApp;
@class MERequestContext;
@class MEButtonClickRepository;
@class MEDisplayedIAMRepository;

@interface MERequestModelRepositoryFactory : NSObject

@property (nonatomic, readonly) MEInApp *inApp;
@property (nonatomic, readonly) MERequestContext *requestContext;
@property(nonatomic, readonly) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, readonly) MEDisplayedIAMRepository *displayedIAMRepository;

- (instancetype)initWithInApp:(MEInApp *)inApp
               requestContext:(MERequestContext *)requestContext
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
       displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository;

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing;

@end