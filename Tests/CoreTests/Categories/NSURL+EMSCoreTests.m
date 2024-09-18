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
                                          @"<>,": @"\"`;/?:^%#@&=$+{}<>,|\\ !'()*[]"
                                      }];
                [[result.absoluteString should] equal:@"http://myurl.com?1=a&%3C%3E%2C=%22%60%3B%2F%3F%3A%5E%25%23%40%26%3D%24%2B%7B%7D%3C%3E%2C%7C%5C%20%21%27%28%29%2A%5B%5D"];
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

    describe(@"isEqualIgnoringQueryParamOrderTo:", ^{
        
        it(@"should should return NO when host is different", ^{
            NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com"];
            NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.notemarsys.com"];
            BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
            [[theValue(result) should] beNo];
        });
        
        it(@"should should return NO when path is different", ^{
            NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path"];
            NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/differentPath"];
            BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
            [[theValue(result) should] beNo];
        });
        
        it(@"should should return NO when queryParams are different", ^{
            NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=original"];
            NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=different"];
            BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
            [[theValue(result) should] beNo];
        });
        
        it(@"should should return YES when the urls are the same", ^{
            NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=same"];
            NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=same"];
            BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
            [[theValue(result) should] beYes];
        });
        
        it(@"should should return NO when queryParams are the same but the order is different", ^{
            NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=same"];
            NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param2=same&param1=same"];
            BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
            [[theValue(result) should] beYes];
        });
    });


SPEC_END
