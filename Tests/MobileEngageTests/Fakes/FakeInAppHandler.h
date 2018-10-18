//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSEventHandler.h"

typedef void (^MainThreadCheckerBlock)(BOOL mainThread);
typedef void (^FakeInAppHandlerBlock)(NSString *eventName, NSDictionary<NSString *, NSObject *> *payload);

@interface FakeInAppHandler : NSObject <EMSEventHandler>

@property(nonatomic, strong) MainThreadCheckerBlock mainThreadCheckerBlock;
@property(nonatomic, strong) FakeInAppHandlerBlock handlerBlock;
@property(nonatomic, strong) NSString *eventName;
@property(nonatomic, strong) NSDictionary<NSString *, NSObject *> *payload;

- (instancetype)initWithMainThreadCheckerBlock:(MainThreadCheckerBlock)mainThreadCheckerBlock;
- (instancetype)initWithHandlerBlock:(FakeInAppHandlerBlock)fakeInAppHandlerBlock;

@end