#import "Kiwi.h"
#import "EMSTimestampProvider.h"

SPEC_BEGIN(EMSTimestampProviderTests)

        describe(@"TimestampProvider:provideTimestamp", ^{

            it(@"should return the current timestamp", ^{
                NSDate *before = [NSDate date];
                NSDate *timestamp = [[EMSTimestampProvider new] provideTimestamp];
                NSDate *after = [NSDate date];
                [[timestamp should] beBetween:before and:after];
            });

        });

SPEC_END