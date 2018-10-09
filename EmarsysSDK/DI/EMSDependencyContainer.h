//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSConfig.h"

@class MobileEngageInternal;
@class MEInApp;
@class PredictInternal;
@class EMSSQLiteHelper;
@class EMSNotificationCache;
@protocol EMSInboxProtocol;
@protocol EMSRequestModelRepositoryProtocol;
@class EMSAbstractResponseHandler;

@interface EMSDependencyContainer : NSObject

@property(nonatomic, readonly) EMSSQLiteHelper *dbHelper;

@property(nonatomic, readonly) MobileEngageInternal *mobileEngage;
@property(nonatomic, readonly) id<EMSInboxProtocol> inbox;
@property(nonatomic, readonly) MEInApp *iam;
@property(nonatomic, readonly) PredictInternal *predict;
@property(nonatomic, readonly) id <EMSRequestModelRepositoryProtocol> requestRepository;
@property(nonatomic, readonly) EMSNotificationCache *notificationCache;
@property(nonatomic, readonly) NSArray<EMSAbstractResponseHandler *> *responseHandlers;
@property(nonatomic, strong) NSOperationQueue *operationQueue;

- (instancetype)initWithConfig:(EMSConfig *)config;

@end