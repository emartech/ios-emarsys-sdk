//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractResponseHandler.h"

@interface AbstractResponseHandler (Private)

- (BOOL)shouldHandleResponse:(EMSResponseModel *)response;
- (void)handleResponse:(EMSResponseModel *)response;

@end