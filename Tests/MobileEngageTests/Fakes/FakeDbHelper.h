//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSSQLiteHelperProtocol.h"

@interface FakeDbHelper : NSObject <EMSSQLiteHelperProtocol>

@property (nonatomic, strong) void (^closeOperationQueueBlock)(NSOperationQueue *operationQueue);

@end