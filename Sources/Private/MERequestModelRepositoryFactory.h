//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"

@protocol EMSRequestModelRepositoryProtocol;
@protocol MEIAMProtocol;
@protocol EMSInAppProtocol;
@class MEInApp;
@class MERequestContext;
@class MEButtonClickRepository;
@class MEDisplayedIAMRepository;
@class EMSEndpoint;
@class EMSStorage;
@protocol EMSStorageProtocol;

@interface MERequestModelRepositoryFactory : NSObject

@property(nonatomic, readonly) id<EMSInAppProtocol, MEIAMProtocol> inApp;
@property(nonatomic, readonly) MERequestContext *requestContext;
@property(nonatomic, readonly) MEButtonClickRepository *buttonClickRepository;
@property(nonatomic, readonly) MEDisplayedIAMRepository *displayedIAMRepository;
@property(nonatomic, readonly) EMSSQLiteHelper *dbHelper;
@property(nonatomic, readonly) EMSEndpoint *endpoint;
@property(nonatomic, readonly) NSOperationQueue *operationQueue;
@property(nonatomic, readonly) id<EMSStorageProtocol> storage;

- (instancetype)initWithInApp:(id<EMSInAppProtocol, MEIAMProtocol>) inApp
               requestContext:(MERequestContext *)requestContext
                     dbHelper:(EMSSQLiteHelper *)dbHelper
        buttonClickRepository:(MEButtonClickRepository *)buttonClickRepository
       displayedIAMRepository:(MEDisplayedIAMRepository *)displayedIAMRepository
                     endpoint:(EMSEndpoint *)endpoint
               operationQueue:(NSOperationQueue *)operationQueue
                      storage:(id<EMSStorageProtocol>)storage;

- (id <EMSRequestModelRepositoryProtocol>)createWithBatchCustomEventProcessing:(BOOL)batchProcessing;

@end