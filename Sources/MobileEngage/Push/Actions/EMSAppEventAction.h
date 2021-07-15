//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionProtocol.h"
#import "EMSBlocks.h"


@interface EMSAppEventAction : NSObject <EMSActionProtocol>

@property(nonatomic, strong) EMSEventHandlerBlock eventHandler;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                            eventHandler:(EMSEventHandlerBlock)eventHandler;
@end