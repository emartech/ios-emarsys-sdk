//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>


#define itShouldThrowException(reasonString, exceptionBlock) [TestUtils assertForException:exceptionBlock reason:reasonString]
#define xitShouldThrowException(reasonString, exceptionBlock)

@interface TestUtils : NSObject

+ (void)assertForException:(void (^)(void))exceptionBlock reason:(NSString *)reasonString;
@end
