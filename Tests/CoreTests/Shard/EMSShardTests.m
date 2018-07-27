//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSShard.h"

SPEC_BEGIN(EMSShardTests)

        describe(@"EMSShard init", ^{

            it(@"should not accept nil for category", ^{
                @try {
                    [[EMSShard alloc] initWithCategory:nil timestamp:[NSDate date] ttl:1.0 data:[NSDictionary new]];
                    fail(@"Expected exception when category is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should not accept nil for timestamp", ^{
                @try {
                    [[EMSShard alloc] initWithCategory:@"category" timestamp:nil ttl:1.0 data:[NSDictionary new]];
                    fail(@"Expected exception when timestamp is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should not accept nil for data", ^{
                @try {
                    [[EMSShard alloc] initWithCategory:@"category" timestamp:[NSDate date] ttl:1.0 data:nil];
                    fail(@"Expected exception when data is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

        });

SPEC_END
