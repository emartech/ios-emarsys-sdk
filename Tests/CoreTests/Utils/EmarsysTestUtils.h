//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"
#import "EMSDependencyContainer.h"
#import "Emarsys.h"

@interface Emarsys ()

+ (EMSSQLiteHelper *)sqliteHelper;

@end

@interface EmarsysTestUtils : NSObject

+ (void)setupEmarsysWithFeatures:(NSArray<MEFlipperFeature> *)features
         withDependencyContainer:(id <EMSDependencyContainerProtocol>)dependencyContainer;
+ (void)tearDownEmarsys;
+ (void)waitForSetCustomer;

@end