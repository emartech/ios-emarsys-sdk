//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@class MEIAMViewController;
@protocol MEIAMProtocol;

@interface MEIAMClose : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithMEIAM:(id<MEIAMProtocol>)meiam;

@end