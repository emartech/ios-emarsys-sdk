//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelper.h"


@interface FakeDbHelper : EMSSQLiteHelper

@property (nonatomic, strong) id insertedModel;
@property (nonatomic, strong) void (^closeOperationQueueBlock)(NSOperationQueue *operationQueue);

- (void)waitForInsert;

@end