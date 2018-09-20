//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSConfig.h"

@class MobileEngageInternal;
@class MEInApp;
@class PredictInternal;
@class EMSSQLiteHelper;

@interface EMSDependencyContainer : NSObject

@property(nonatomic, readonly) EMSSQLiteHelper *dbHelper;

@property(nonatomic, readonly) MobileEngageInternal *mobileEngage;
@property(nonatomic, readonly) MEInApp *iam;
@property(nonatomic, readonly) PredictInternal *predict;

- (instancetype)initWithConfig:(EMSConfig *)config;

@end