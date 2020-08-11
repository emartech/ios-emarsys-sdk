//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^RouterLogicBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface EMSInstanceRouter: NSObject

- (instancetype)initWithDefaultInstance:(id)defaultInstance
                        loggingInstance:(id)loggingInstance
                            routerLogic:(RouterLogicBlock)routerLogic;

- (id)instance;

@end

NS_ASSUME_NONNULL_END
