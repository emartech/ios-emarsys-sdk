//
// Copyright (c) 2018 Emarsys. All rights reserved.
//

#import "FakeDbHelper.h"
#import "EMSWaiter.h"
#import <XCTest/XCTest.h>

@implementation FakeDbHelper {
    XCTestExpectation *_expectation;
}

- (id)init {
    self = [super init];
    if (self) {
        _expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForResult"];
    }
    return self;
}

- (int)version {
    return 0;
}

- (void)open {

}

- (void)registerTriggerWithTableName:(NSString *)tableName
                         triggerType:(EMSDBTriggerType *)triggerType
                        triggerEvent:(EMSDBTriggerEvent *)triggerEvent
                             trigger:(id)trigger {

}

- (BOOL)removeFromTable:(NSString *)tableName
              selection:(NSString *)where
          selectionArgs:(NSArray<NSString *> *)whereArgs {
    return NO;
}

- (NSArray *)queryWithTable:(NSString *)tableName
                  selection:(NSString *)selection
              selectionArgs:(NSArray<NSString *> *)selectionArgs
                    orderBy:(NSString *)orderBy
                      limit:(NSString *)limit
                     mapper:(id)mapper {
    return nil;
}

- (BOOL)insertModel:(id)model
             mapper:(id)mapper {
    return NO;
}

- (BOOL)executeCommand:(NSString *)command {
    return NO;
}

- (BOOL)execute:(NSString *)command
  withBindBlock:(BindBlock)bindBlock {
    return NO;
}

- (NSArray *)executeQuery:(NSString *)query
                   mapper:(id)mapper {
    return nil;
}

- (void)close {
    self.closeOperationQueueBlock([NSOperationQueue currentQueue]);
}

- (void)insertModel:(id)model withQuery:(NSString *)insertSQL mapper:(id <EMSModelMapperProtocol>)mapper {
    [_expectation fulfill];
}

@end