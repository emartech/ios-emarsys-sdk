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

- (void)insertModel:(id)model withQuery:(NSString *)insertSQL mapper:(id <EMSModelMapperProtocol>)mapper {
    _insertedModel = model;
    [_expectation fulfill];
}

- (void)waitForInsert {
    [EMSWaiter waitForExpectations:@[_expectation] timeout:30];
}

@end