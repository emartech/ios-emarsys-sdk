//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@interface EMSAbstractResponseHandler (Private)

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response;
- (void)handleResponse:(EMSResponseModel *)response;

@end