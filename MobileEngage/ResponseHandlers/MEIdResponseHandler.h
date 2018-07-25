//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractResponseHandler.h"


@class MERequestContext;
@interface MEIdResponseHandler : AbstractResponseHandler

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end
