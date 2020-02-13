//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSCustomEventAction.h"
#import "EMSMobileEngageProtocol.h"

@interface EMSCustomEventAction ()

@property(nonatomic, strong) NSDictionary *action;
@property(nonatomic, weak) id <EMSMobileEngageProtocol> mobileEngage;

@end

@implementation EMSCustomEventAction

- (instancetype)initWithAction:(NSDictionary *)action
                  mobileEngage:(id <EMSMobileEngageProtocol>)mobileEngage {
    NSParameterAssert(action);
    NSParameterAssert(mobileEngage);

    if (self = [super init]) {
        _action = action;
        _mobileEngage = mobileEngage;
    }
    return self;
}

- (void)execute {
    [self.mobileEngage trackCustomEventWithName:self.action[@"name"]
                                eventAttributes:self.action[@"payload"]
                                completionBlock:nil];
}

@end