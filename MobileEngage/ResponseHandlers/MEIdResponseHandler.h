//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"


@class MERequestContext;
@interface MEIdResponseHandler : EMSAbstractResponseHandler

- (instancetype)initWithRequestContext:(MERequestContext *)requestContext;

@end
