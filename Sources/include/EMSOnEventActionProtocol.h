//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSEventHandler.h"

@protocol EMSOnEventActionProtocol <NSObject>

@property(nonatomic, weak, nullable) id <EMSEventHandler> eventHandler;

@end
