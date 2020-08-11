//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import "EMSInstanceRouter.h"

@interface EMSInstanceRouter()

@property(nonatomic, strong) id defaultInstance;
@property(nonatomic, strong) id loggingInstance;
@property(nonatomic, copy) RouterLogicBlock routerLogic;

@end

@implementation EMSInstanceRouter

- (instancetype)initWithDefaultInstance:(id)defaultInstance
                        loggingInstance:(id)loggingInstance
                            routerLogic:(RouterLogicBlock)routerLogic {
    NSParameterAssert(defaultInstance);
    NSParameterAssert(loggingInstance);
    NSParameterAssert(routerLogic);
    if (self = [super init]) {
        _defaultInstance = defaultInstance;
        _loggingInstance = loggingInstance;
        _routerLogic = routerLogic;
    }
    return self;
}

- (id)instance {
    id result = nil;
    if (self.routerLogic()) {
        result = self.defaultInstance;
    } else {
        result = self.loggingInstance;
    }
    return result;
}

@end
