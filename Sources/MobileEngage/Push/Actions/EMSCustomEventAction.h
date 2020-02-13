//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSActionProtocol.h"

@protocol EMSMobileEngageProtocol;


@interface EMSCustomEventAction : NSObject <EMSActionProtocol>

- (instancetype)init NS_UNAVAILABLE;

-(instancetype) initWithAction:(NSDictionary *)action
                  mobileEngage:(id<EMSMobileEngageProtocol>)mobileEngage;

@end