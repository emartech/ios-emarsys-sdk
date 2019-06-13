//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "EMSAuthentication.h"

SPEC_BEGIN(AuthenticationTests)

        __block NSTimeZone *cachedTimeZone;

        beforeAll(^{
            cachedTimeZone = [NSTimeZone defaultTimeZone];
            [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Budapest"]];
        });

        afterAll(^{
            [NSTimeZone setDefaultTimeZone:cachedTimeZone];
        });

        describe(@"NSString+CoreTests createBasicAuthWith:(NSString *)username", ^{
            it(@"should throw exception when username is nil", ^{
                @try {
                    IGNORE_NONNULL_BEGIN
                    [EMSAuthentication createBasicAuthWithUsername:nil];
                    IGNORE_NONNULL_END
                    fail(@"Expected exception when username is nil");
                } @catch (NSException *exception) {
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should create the correct basicAuth when username set", ^{
                NSString *basicAuth1 = [EMSAuthentication createBasicAuthWithUsername:@"user"];
                [[basicAuth1 should] equal:@"Basic dXNlcjo="];

                NSString *basicAuth2 = [EMSAuthentication createBasicAuthWithUsername:@"user2"];
                [[basicAuth2 should] equal:@"Basic dXNlcjI6"];
            });
        });

SPEC_END
