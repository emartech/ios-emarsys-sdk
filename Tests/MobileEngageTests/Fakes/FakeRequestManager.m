//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeRequestManager.h"
#import "EMSResponseModel.h"
#import "EMSWaiter.h"
#import <XCTest/XCTest.h>

@interface FakeRequestManager()
@property (nonatomic, strong) NSMutableArray<XCTestExpectation *> *expectations;
@end

@implementation FakeRequestManager {
}


+ (instancetype)managerWithSuccessBlock:(nullable CoreSuccessBlock)successBlock
                             errorBlock:(nullable CoreErrorBlock)errorBlock {
    FakeRequestManager *manager = [FakeRequestManager new];
    manager.successBlock = successBlock;
    manager.errorBlock = errorBlock;
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _submittedModels = [NSMutableArray new];
        _expectations = [NSMutableArray new];
    }
    return self;
}

- (void)submitRequestModel:(EMSRequestModel *)model {
    [_submittedModels addObject:model];
    [_expectations addObject:[[XCTestExpectation alloc] initWithDescription:@"waitForResult"]];


    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        EMSResponseModel *nextResponse = [_responseModels firstObject];
        [_responseModels removeObject:nextResponse];
        if (nextResponse && weakSelf.successBlock) {
            weakSelf.successBlock(model.requestId, nextResponse);
        }

        XCTestExpectation *expectation = [weakSelf.expectations firstObject];
        [weakSelf.expectations removeObject:expectation];
        [expectation fulfill];
    });

}

- (void)waitForAllExpectations {
    [EMSWaiter waitForExpectations:[_expectations copy] timeout:30];
}

@end
