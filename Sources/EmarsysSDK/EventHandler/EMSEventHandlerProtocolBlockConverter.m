//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSEventHandlerProtocolBlockConverter.h"

@implementation EMSEventHandlerProtocolBlockConverter

- (instancetype)init {
    if (self = [super init]) {
        _eventHandler = [EMSEventHandlerProtocolImplementation new];
    }
    return self;
}

@end
