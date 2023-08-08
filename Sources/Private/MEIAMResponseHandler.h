//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSAbstractResponseHandler.h"

@protocol  EMSInAppProtocol;
@protocol MEIAMProtocol;
@class MEInApp;

@interface MEIAMResponseHandler : EMSAbstractResponseHandler

- (instancetype)initWithInApp:(id<EMSInAppProtocol, MEIAMProtocol>)inApp;

@end