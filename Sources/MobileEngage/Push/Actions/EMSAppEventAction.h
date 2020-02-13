//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionProtocol.h"
#import "EMSEventHandler.h"


@interface EMSAppEventAction : NSObject <EMSActionProtocol>

@property(nonatomic, weak) id <EMSEventHandler> eventHandler;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithActionDictionary:(NSDictionary<NSString *, id> *)action
                            eventHandler:(id <EMSEventHandler>)eventHandler;
@end