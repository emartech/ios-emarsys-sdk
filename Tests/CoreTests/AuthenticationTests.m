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

    describe(@"NSString+CoreTests createBasicAuthWith:(NSString *)username password:(NSString *)password", ^{
        it(@"should throw exception when username is nil", ^{
            @try {
                [EMSAuthentication createBasicAuthWithUsername:nil
                                                      password:@"pass"];
                fail(@"Expected exception when username is nil");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should throw exception when password is nil", ^{
            @try {
                [EMSAuthentication createBasicAuthWithUsername:@"valami"
                                                      password:nil];
                fail(@"Expected exception when password is nil");
            } @catch (NSException *exception) {
                [[theValue(exception) shouldNot] beNil];
            }
        });

        it(@"should create the correct basicAuth when username and password set", ^{
            NSString *basicAuth1 = [EMSAuthentication createBasicAuthWithUsername:@"user"
                                                                         password:@"pass"];
            [[basicAuth1 should] equal:@"Basic dXNlcjpwYXNz"];

            NSString *basicAuth2 = [EMSAuthentication createBasicAuthWithUsername:@"user2"
                                                                         password:@"pass2"];
            [[basicAuth2 should] equal:@"Basic dXNlcjI6cGFzczI="];
        });
    });

SPEC_END
