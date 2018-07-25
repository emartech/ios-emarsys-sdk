//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeResponseHandler.h"


@implementation FakeResponseHandler

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response {
    return _shouldHandle;
}

- (void)handleResponse:(EMSResponseModel *)response {
    _handledResponseModel = response;
}


@end