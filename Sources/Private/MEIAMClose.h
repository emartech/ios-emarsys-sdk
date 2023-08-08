//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEIAMJSCommandProtocol.h"

@protocol EMSIAMCloseProtocol;

@interface MEIAMClose : NSObject <MEIAMJSCommandProtocol>

- (instancetype)initWithEMSIAMCloseProtocol:(id <EMSIAMCloseProtocol>)closeProtocol;

@end