//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEJSBridge.h"

typedef void (^FakeMessageBlock)(WKScriptMessage *result);

@interface FakeJSBridge : MEJSBridge

- (instancetype)initWithMessageBlock:(FakeMessageBlock)messageBlock;

@end