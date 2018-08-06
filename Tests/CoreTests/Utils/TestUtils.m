//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "TestUtils.h"
#import "Kiwi.h"

@implementation TestUtils

+ (void)assertForException:(void (^)(void))exceptionBlock reason:(NSString *)reasonString {
    it(reasonString, ^{
        @try {
            exceptionBlock();
            fail(reasonString);
        }@catch (NSException *exception){
            [[theValue(exception) shouldNot] beNil];
        }
    });
}


@end