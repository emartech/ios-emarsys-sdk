//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSURL+EMSCore.h"

@interface NSURLEMSCoreTests : XCTestCase

@end

@implementation NSURLEMSCoreTests

- (void)testUrlWithBaseUrl_shouldThrowExceptionWhenBaseURLIsNil {
    @try {
        [NSURL urlWithBaseUrl:nil
                  queryParameters:@{@"1": @"a"}];
        XCTFail(@"Expected Exception when baseURL is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: urlString");
        XCTAssertNotNil(exception);
    }
}

- (void)testUrlWithBaseUrl_shouldThrowExceptionWhenBaseURLExistsButThereIsNoScheme {
    @try {
        [NSURL urlWithBaseUrl:@"url.com"
                  queryParameters:@{@"1": @"a"}];
        XCTFail(@"Expected Exception when there is no scheme!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: url.com");
        XCTAssertNotNil(exception);
    }
}

- (void)testUrlWithBaseUrl_shouldThrowExceptionWhenBaseURLExistsButThereIsNoHost {
    @try {
        [NSURL urlWithBaseUrl:@"https://"
                  queryParameters:@{@"1": @"a"}];
        XCTFail(@"Expected Exception when there is no host!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: https://");
        XCTAssertNotNil(exception);
    }
}

- (void)testUrlWithBaseUrl_shouldBuildURLWithQueryParametersWhenFieldsAreSet {
    NSURL *result = [NSURL urlWithBaseUrl:@"https://myurl.com"
                          queryParameters:@{
                              @"1": @"a",
                              @"2": @"b"
                          }];
    XCTAssertEqualObjects(result.absoluteString, @"https://myurl.com?1=a&2=b");
}

- (void)testUrlWithBaseUrl_shouldBuildURLWithQueryParametersWhenFieldsAreSetAndHasSpecialCharacters {
    NSURL *result = [NSURL urlWithBaseUrl:@"https://myurl.com"
                          queryParameters:@{
                              @"1": @"a",
                              @"<>,": @"\"`;/?:^%#@&=$+{}<>,|\\ !'()*[]"
                          }];
    XCTAssertEqualObjects(result.absoluteString, @"https://myurl.com?1=a&%3C%3E%2C=%22%60%3B%2F%3F%3A%5E%25%23%40%26%3D%24%2B%7B%7D%3C%3E%2C%7C%5C%20%21%27%28%29%2A%5B%5D");
}

- (void)testUrlWithBaseUrl_shouldBuildURLWithQueryParametersWhenFieldsAreSetAndValueHasNotStringCharacters {
    NSURL *result = [NSURL urlWithBaseUrl:@"https://myurl.com"
                          queryParameters:@{
                              @"1": @"a",
                              @"2": @2
                          }];
    XCTAssertEqualObjects(result.absoluteString, @"https://myurl.com?1=a&2=2");
}

- (void)testUrlWithBaseUrl_shouldBuildURLWithQueryParametersWhenFieldsAreSetAndKeyHasNotStringCharacters {
    NSURL *result = [NSURL urlWithBaseUrl:@"https://myurl.com"
                          queryParameters:@{
                              @"1": @"a",
                              @3: @"3"
                          }];
    XCTAssertEqualObjects(result.absoluteString, @"https://myurl.com?1=a&3=3");
}

- (void)testIsEqualIgnoringQueryParamOrderTo_shouldReturnNO_whenHostIsDifferent {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com"];
    NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.notemarsys.com"];
    BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
    XCTAssertFalse(result);
}

- (void)testIsEqualIgnoringQueryParamOrderTo_shouldReturnNO_whenPathIsDifferent {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path"];
    NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/differentPath"];
    BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
    XCTAssertFalse(result);
}

- (void)testIsEqualIgnoringQueryParamOrderTo_shouldReturnNO_whenQueryParamsAreDifferent {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=original"];
    NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=different"];
    BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
    XCTAssertFalse(result);
}

- (void)testIsEqualIgnoringQueryParamOrderTo_shouldReturnYES_whenUrlsAreTheSame {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=same"];
    NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=same"];
    BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
    XCTAssertTrue(result);
}

- (void)testIsEqualIgnoringQueryParamOrderTo_shouldReturnYES_whenQueryParamsAreTheSameButOrderIsDifferent {
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param1=same&param2=same"];
    NSURL *otherUrl = [[NSURL alloc] initWithString:@"https://www.emarsys.com/path?param2=same&param1=same"];
    BOOL result = [url isEqualIgnoringQueryParamOrderTo:otherUrl];
    XCTAssertTrue(result);
}

@end
