//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSConfig.h"

@class MobileEngageInternal;
@class MEInApp;
@class PredictInternal;
@class EMSSQLiteHelper;
@protocol EMSInboxProtocol;

@interface EMSDependencyContainer : NSObject

@property(nonatomic, readonly) EMSSQLiteHelper *dbHelper;

@property(nonatomic, readonly) MobileEngageInternal *mobileEngage;
@property(nonatomic, readonly) id<EMSInboxProtocol> inbox;
@property(nonatomic, readonly) MEInApp *iam;
@property(nonatomic, readonly) PredictInternal *predict;

- (instancetype)initWithConfig:(EMSConfig *)config;

@end