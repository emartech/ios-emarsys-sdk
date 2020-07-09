//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSEventHandler.h"

@protocol EMSIAMAppEventProtocol <NSObject>
- (_Nullable id <EMSEventHandler>)eventHandler;
@end