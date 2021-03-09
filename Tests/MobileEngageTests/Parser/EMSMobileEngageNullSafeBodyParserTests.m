//
//  Copyright © 2021 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"
#import "EMSMobileEngageNullSafeBodyParser.h"
#import "EMSRequestModel.h"

@interface EMSMobileEngageNullSafeBodyParserTests : XCTestCase

@property(nonatomic, strong) EMSEndpoint *mockEndpoint;
@property(nonatomic, strong) EMSRequestModel *mockRequestModel;
@property(nonatomic, strong) EMSMobileEngageNullSafeBodyParser *parser;

@end

@implementation EMSMobileEngageNullSafeBodyParserTests

- (void)setUp {
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);
    _mockRequestModel = OCMClassMock([EMSRequestModel class]);
    _parser = [[EMSMobileEngageNullSafeBodyParser alloc] initWithEndpoint:self.mockEndpoint];
}

- (void)testInit_endpointShouldNotBeNil {
    @try {
        [[EMSMobileEngageNullSafeBodyParser alloc] initWithEndpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testShouldParse_shouldReturnTrue_whenMobileEngageRequest {
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(YES);

    BOOL result = [self.parser shouldParse:self.mockRequestModel];

    XCTAssertTrue(result);
}

- (void)testShouldParse_shouldReturnFalse_whenNotMobileEngageRequest {
    OCMStub([self.mockEndpoint isMobileEngageUrl:[OCMArg any]]).andReturn(NO);

    BOOL result = [self.parser shouldParse:self.mockRequestModel];

    XCTAssertFalse(result);
}

- (void)testParse_shouldReturnParsedBodyFromResponseModel_whenNoNullObjectInBody {
    NSDictionary *dict = @{
            @"k1": @"v1",
            @"k2": @{
                    @"k3": @"v3"
            }
    };
    NSData *responseBody = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:0
                                                             error:nil];

    id result = [self.parser parseWithRequestModel:self.mockRequestModel
                                      responseBody:responseBody];

    XCTAssertEqualObjects(result, dict);
}

- (void)testParse_shouldReturnParsedBodyFromResponseModelWithoutNSNulls_whenBodyContainsNull {
    NSString *dataString = @"{\n"
                           "            \"k1\": \"v1\",\n"
                           "            \"k2\": null}";
    NSData *body = [dataString dataUsingEncoding:NSUTF8StringEncoding];


    NSDictionary *expected = @{
            @"k1": @"v1"
    };

    id result = [self.parser parseWithRequestModel:self.mockRequestModel
                                      responseBody:body];

    XCTAssertEqualObjects(result, expected);
}

- (void)testParse_shouldReturnParsedBodyFromResponseModelWithoutNSNulls_whenBodyContainsArrayNotDictionary {
    NSString *dataString = @"[\"v1\",\"v2\",null]";
    NSData *body = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *expected = @[@"v1", @"v2"];

    id result = [self.parser parseWithRequestModel:self.mockRequestModel
                                      responseBody:body];

    XCTAssertEqualObjects(result, expected);
}

- (void)testParse_shouldReturnParsedBodyFromResponseModelWithoutNSNulls_whenBodyContainsNullInChildDictionary {
    NSString *dataString = @"{\n"
                           "            \"k1\": \"v1\",\n"
                           "            \"k2\": null,\n"
                           "            \"k3\": {\n"
                           "                \"k4\": null,\n"
                           "                \"k5\": \"v5\"\n}"
                           "            }";

    NSData *body = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *expected = @{
            @"k1": @"v1",
            @"k3": @{
                    @"k5": @"v5"
            }
    };

    id result = [self.parser parseWithRequestModel:self.mockRequestModel
                                      responseBody:body];

    XCTAssertEqualObjects(result, expected);
}

- (void)testParse_shouldReturnParsedBodyFromResponseModelWithoutNSNulls_whenBodyContainsArrayInChild {
    NSString *dataString = @"{\n"
                           "            \"k1\": \"v1\",\n"
                           "            \"k2\": [\n"
                           "                    {\n"
                           "                            \"k3\": null,\n"
                           "                            \"k4\": \"v4\"\n"
                           "                    },\n"
                           "                    {\n"
                           "                            \"k5\": \"v5\",\n"
                           "                            \"k6\": null\n"
                           "                    }\n"
                           "            ]\n"
                           "    }";

    NSData *body = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *expected = @{
            @"k1": @"v1",
            @"k2": @[
                    @{
                            @"k4": @"v4"
                    },
                    @{
                            @"k5": @"v5",
                    }
            ]
    };

    id result = [self.parser parseWithRequestModel:self.mockRequestModel
                                      responseBody:body];

    XCTAssertEqualObjects(result, expected);
}

- (void)testParse_shouldReturnParsedBodyFromResponseModelWithoutNSNulls_whenBodyContainsNestedArraysInChild {
    NSString *dataString = @"{\n"
                           "   \"k1\":[\n"
                           "      [\n"
                           "         \"v1\",\n"
                           "         null,\n"
                           "         \"v3\"\n"
                           "      ]\n"
                           "   ]\n"
                           "}";


    NSData *body = [dataString dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *expected = @{
            @"k1": @[
                    @[@"v1",@"v3"]
            ]
    };

    id result = [self.parser parseWithRequestModel:self.mockRequestModel
                                      responseBody:body];

    XCTAssertEqualObjects(result, expected);
}

@end
