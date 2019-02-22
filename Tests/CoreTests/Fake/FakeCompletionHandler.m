//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "FakeCompletionHandler.h"

@implementation FakeCompletionHandler

- (instancetype)init {
    if (self = [super init]) {
        _successCount = @0;
        _errorCount = @0;
        _successBlock = ^(NSString *requestId, EMSResponseModel *response) {
            _successCount = @([_successCount intValue] + 1);
        };
        _errorBlock = ^(NSString *requestId, NSError *error) {
            _errorCount = @([_errorCount intValue] + 1);
        };
    }
    return self;
}

@end