//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "FakeRequestManager.h"

@interface FakeRequestManager ()

@property(nonatomic) EMSCompletion completionBlock;

@end

@implementation FakeRequestManager

- (instancetype)initWithSubmitNowCompletionBlock:(EMSCompletion)completionBlock {
    if (self = [super init]) {
        _completionBlock = completionBlock;
    }
    return self;
}

- (void)submitRequestModelNow:(EMSRequestModel *)model
                 successBlock:(CoreSuccessBlock)successBlock
                   errorBlock:(CoreErrorBlock)errorBlock {
    _submitNowRequestModel = model;
    _successBlock = successBlock;
    _errorBlock = errorBlock;
    self.completionBlock();
}

@end