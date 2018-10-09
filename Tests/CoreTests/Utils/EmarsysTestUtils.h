//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MEFlipperFeatures.h"
#import "EMSDependencyContainer.h"
#import "Emarsys.h"

@interface Emarsys ()

+ (void)setDependencyContainer:(EMSDependencyContainer *)dependencyContainer;

+ (EMSSQLiteHelper *)sqliteHelper;

+ (EMSDependencyContainer *)dependencyContainer;

@end

@interface EmarsysTestUtils : NSObject

+ (void)setUpEmarsysWithFeatures:(NSArray<MEFlipperFeature> *)features;
+ (void)tearDownEmarsys;

@end