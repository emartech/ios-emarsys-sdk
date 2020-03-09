//
//  Copyright © 2018 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "NSDate+EMSCore.h"

SPEC_BEGIN(NSDateEMSCoreTests)

        describe(@"numberValue", ^{
            it(@"should return the number value of the date", ^{
                NSDate *referenceDate = [NSDate dateWithTimeIntervalSince1970:4242.4242];
                [[[referenceDate numberValueInMillis] should] equal:@(4242424)];
            });
        });

        describe(@"numberValueInMillisFromDate:", ^{
            it(@"should return the difference in millis from the referenced date as a number", ^{
                NSDate *beforeDate = [NSDate date];
                NSDate *afterDate = [NSDate dateWithTimeInterval:4242.4242
                                                       sinceDate:beforeDate];
                [[[afterDate numberValueInMillisFromDate:beforeDate] should] equal:@(4242424)];
            });
        });

        describe(@"stringValueInUTC", ^{
            it(@"should return with the correct formatted dateString pm", ^{
                NSString *expected = @"2017-12-07T15:46:09.100Z";

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
                NSDate *date = [dateFormatter dateFromString:expected];

                [[[date stringValueInUTC] should] equal:expected];
            });

            it(@"should return with the correct formatted dateString am", ^{
                NSString *expected = @"2017-12-07T09:46:09.100Z";

                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
                NSDate *date = [dateFormatter dateFromString:expected];

                [[[date stringValueInUTC] should] equal:expected];
            });
        });

        describe(@"utcDateFormatter", ^{
            it(@"should use gregorian calendar", ^{
                [[theValue([NSDate utcDateFormatter].calendar.calendarIdentifier) should] equal:theValue(NSCalendarIdentifierGregorian)];
            });
        });

SPEC_END
