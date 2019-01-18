//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import "Kiwi.h"
#import "NSURL+EMSCore.h"

SPEC_BEGIN(NSURLEMSCoreTests)

        describe(@"urlWithBaseUrl:queryParameters", ^{

            it(@"should throw exception when baseURL is nil", ^{
                @try {
                    [NSURL urlWithBaseUrl:nil
                          queryParameters:@{@"1": @"a"}];
                    fail(@"Expected Exception when baseURL is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: urlString"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when baseURL exists but there is no scheme", ^{
                @try {
                    [NSURL urlWithBaseUrl:@"url.com"
                          queryParameters:@{@"1": @"a"}];
                    fail(@"Expected Exception when there is no scheme!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: url.scheme"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when baseURL exists but there is no host", ^{
                @try {
                    [NSURL urlWithBaseUrl:@"https://"
                          queryParameters:@{@"1": @"a"}];
                    fail(@"Expected Exception when there is no host!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: url.host"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should throw exception when queryParameters is nil", ^{
                @try {
                    [NSURL urlWithBaseUrl:@"URL"
                          queryParameters:nil];
                    fail(@"Expected Exception when queryParameters is nil!");
                } @catch (NSException *exception) {
                    [[exception.reason should] equal:@"Invalid parameter not satisfying: queryParameters"];
                    [[theValue(exception) shouldNot] beNil];
                }
            });

            it(@"should build URL with queryParameters when fields are set", ^{
                NSURL *result = [NSURL urlWithBaseUrl:@"http://myurl.com"
                                      queryParameters:@{
                                          @"1": @"a",
                                          @"2": @"b"
                                      }];
                [[result.absoluteString should] equal:@"http://myurl.com?1=a&2=b"];
            });

            it(@"should build URL with queryParameters when fields are set and has special characters", ^{
                NSURL *result = [NSURL urlWithBaseUrl:@"http://myurl.com"
                                      queryParameters:@{
                                          @"1": @"a",
                                          @"<>,": @"\"`;/?:^%#@&=$+{}<>,| "
                                      }];
                [[result.absoluteString should] equal:@"http://myurl.com?1=a&%3C%3E%2C=%22%60%3B%2F%3F%3A%5E%25%23%40%26%3D%24%2B%7B%7D%3C%3E%2C%7C%20"];
            });

            it(@"should build URL with queryParameters when fields are set and value has not String characters", ^{
                NSURL *result = [NSURL urlWithBaseUrl:@"http://myurl.com"
                                      queryParameters:@{
                                          @"1": @"a",
                                          @"2": @2
                                      }];
                [[result.absoluteString should] equal:@"http://myurl.com?1=a&2=2"];
            });

            it(@"should build URL with queryParameters when fields are set and key has not String characters", ^{
                NSURL *result = [NSURL urlWithBaseUrl:@"http://myurl.com"
                                      queryParameters:@{
                                          @"1": @"a",
                                          @3: @"3"
                                      }];
                [[result.absoluteString should] equal:@"http://myurl.com?1=a&3=3"];
            });

        });


SPEC_END
