//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSRequestModelRepositoryProtocol.h"

@protocol EMSSQLiteHelperProtocol;

@interface EMSRequestModelRepository : NSObject <EMSRequestModelRepositoryProtocol>

- (instancetype)initWithDbHelper:(id <EMSSQLiteHelperProtocol>)sqliteHelper
                  operationQueue:(NSOperationQueue *)operationQueue;

@end