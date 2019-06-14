//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSFlipperFeatures.h"
#import "EMSDependencyContainer.h"
#import "Emarsys.h"

@interface Emarsys ()

+ (EMSSQLiteHelper *)sqliteHelper;

@end

@interface EmarsysTestUtils : NSObject

+ (void)setupEmarsysWithFeatures:(NSArray<EMSFlipperFeature> *)features
         withDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer;

+ (void)setupEmarsysWithConfig:(EMSConfig *)config
           dependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer;

+ (void)tearDownEmarsys;

+ (void)waitForSetPushToken;
+ (void)waitForSetCustomer;

@end