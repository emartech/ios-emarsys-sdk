//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSOnEventActionProtocol.h"
#import "EMSActionFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMSOnEventActionInternal : NSObject <EMSOnEventActionProtocol>

- (instancetype)initWithActionFactory:(EMSActionFactory *)actionFactory;

@end

NS_ASSUME_NONNULL_END
