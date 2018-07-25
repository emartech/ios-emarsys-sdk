//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"


@interface FakeDbHelper : EMSSQLiteHelper

@property (nonatomic, strong) id insertedModel;

- (void)waitForInsert;

@end