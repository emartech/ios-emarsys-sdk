//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@class MEInApp;

@interface MEIAMResponseHandler : EMSAbstractResponseHandler

- (instancetype)initWithInApp:(MEInApp *)inApp;

@end