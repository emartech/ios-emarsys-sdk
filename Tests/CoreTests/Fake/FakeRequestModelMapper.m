//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "FakeRequestModelMapper.h"

@implementation FakeRequestModelMapper

- (instancetype)initWithShouldHandle:(BOOL)shouldHandle
                      returningValue:(EMSRequestModel *)returningValue {
    if (self = [super init]) {
        _returningValue = returningValue;
        _shouldHandle = shouldHandle;
    }
    return self;
}

- (BOOL)shouldHandleWithRequestModel:(EMSRequestModel *)requestModel {
    return self.shouldHandle;
}

- (EMSRequestModel *)modelFromModel:(EMSRequestModel *)requestModel {
    _inputValue = requestModel;
    return self.returningValue;
}

@end