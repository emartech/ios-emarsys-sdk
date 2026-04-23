//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRequestModel.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"

@interface EMSRequestModelTests : XCTestCase

@end

@implementation EMSRequestModelTests

- (void)testBuilder_shouldThrowException_whenTimestampProviderIsNil {
    XCTAssertThrows([EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:nil
                                        uuidProvider:OCMClassMock([EMSUUIDProvider class])],
                    @"Expected exception when timestampProvider is nil");
}

- (void)testBuilder_shouldThrowException_whenUuidProviderIsNil {
    XCTAssertThrows([EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:nil],
                    @"Expected exception when uuidProvider is nil");
}

- (void)testBuilder_shouldUseTimestampProvider {
    NSDate *expectedDate = [NSDate date];
    EMSTimestampProvider *timestampProvider = OCMClassMock([EMSTimestampProvider class]);
    OCMStub([timestampProvider provideTimestamp]).andReturn(expectedDate);
    
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:timestampProvider
                                                        uuidProvider:[EMSUUIDProvider new]];
    XCTAssertEqualObjects([requestModel timestamp], expectedDate);
}

- (void)testBuilder_shouldUseUuidProvider {
    NSString *requestId = @"requestId";
    EMSUUIDProvider *uuidProvider = OCMClassMock([EMSUUIDProvider class]);
    OCMStub([uuidProvider provideUUIDString]).andReturn(requestId);
    
    EMSRequestModel *requestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                                        uuidProvider:uuidProvider];
    XCTAssertEqualObjects([requestModel requestId], requestId);
}

- (void)testBuilder_shouldCreateModelWithRequestIdAndTimestamp {
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertNotNil(model.timestamp);
    XCTAssertNotNil(model.requestId);
}

- (void)testBuilder_shouldCreateModelWhereDefaultRequestMethodIsPOST {
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertEqualObjects(model.method, @"POST");
}

- (void)testBuilder_shouldCreateModelWithSpecifiedRequestMethodWhenSetMethodIsCalledOnBuilder {
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setMethod:HTTPMethodGET];
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertEqualObjects(model.method, @"GET");
}

- (void)testBuilder_shouldCreateModelWithSpecifiedRequestUrlWhenSetUrlIsCalledOnBuilder {
    NSString *urlString = @"http://www.google.com";
    NSURL *url = [NSURL URLWithString:urlString];
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:urlString];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertNotNil(model.url);
    XCTAssertEqualObjects(model.url, url);
}

- (void)testBuilder_shouldCreateModelWithSpecifiedTtlWhenSetExpiryIsCalledOnBuilder {
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
        [builder setExpiry:3];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertEqual(model.ttl, 3);
}

- (void)testBuilder_shouldCreateModelWithSpecifiedBodyWhenSetBodyIsCalledOnBuilder {
    NSString *urlString = @"http://www.google.com";
    NSDictionary *payload = @{@"key": @"value"};
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setPayload:payload];
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertEqualObjects(model.payload, payload);
}

- (void)testBuilder_shouldCreateModelWithSpecifiedHeadersWhenSetHeadersIsCalledOnBuilder {
    NSDictionary<NSString *, NSString *> *headers = @{
        @"key": @"value",
        @"key2": @"value2"
    };
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setHeaders:headers];
        [builder setUrl:@"http://www.google.com"];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertEqualObjects(model.headers, headers);
}

- (void)testBuilder_shouldCreateModelWithSpecifiedExtrasWhenSetExtrasIsCalledOnBuilder {
    NSDictionary<NSString *, NSString *> *extras = @{
        @"extra1": @"value1",
        @"extra2": @"value2"
    };
    EMSRequestModel *model = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"http://www.google.com"];
        [builder setExtras:extras];
    } timestampProvider:[EMSTimestampProvider new]
                                                 uuidProvider:[EMSUUIDProvider new]];

    XCTAssertEqualObjects(model.extras, extras);
}

- (void)testBuilder_shouldThrowException_whenBuilderBlockIsNil {
    XCTAssertThrows([EMSRequestModel makeWithBuilder:nil
                                   timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:[EMSUUIDProvider new]],
                    @"Assertation doesn't called!");
}

- (void)testBuilder_shouldThrowException_whenRequestUrlIsInvalid {
    XCTAssertThrows([EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"fatal"];
    } timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:[EMSUUIDProvider new]],
                    @"Assertation doesn't called!");
}

- (void)testBuilder_shouldThrowException_whenRequestUrlIsNil {
    XCTAssertThrows([EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
    } timestampProvider:[EMSTimestampProvider new]
                                        uuidProvider:[EMSUUIDProvider new]],
                    @"Assertation doesn't called!");
}

- (void)testBuilder_shouldCreateRequestUrlWithQueryParameters {
    NSURLComponents *expectedComponents = [[NSURLComponents alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com?queryName1=queryValue1&queryName2=queryValue2"]
                                                       resolvingAgainstBaseURL:YES];
    EMSRequestModel *returnedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://www.emarsys.com"
        queryParameters:@{
            @"queryName1": @"queryValue1",
            @"queryName2": @"queryValue2"
        }];
    } timestampProvider:[EMSTimestampProvider new]
                                                                uuidProvider:[EMSUUIDProvider new]];

    NSURLComponents *componentsFromReturned = [[NSURLComponents alloc] initWithURL:returnedRequestModel.url
                                                           resolvingAgainstBaseURL:YES];
    XCTAssertEqualObjects(componentsFromReturned.host, expectedComponents.host);
    for (NSURLQueryItem *queryItem in expectedComponents.queryItems) {
        XCTAssertTrue([componentsFromReturned.queryItems containsObject:queryItem]);
    }
}

- (void)testBuilder_shouldNotCrashWhenQueryParametersContainsArray {
    NSURLComponents *expectedComponents = [[NSURLComponents alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com?queryName1=queryValue1"]
                                                       resolvingAgainstBaseURL:YES];
    EMSRequestModel *returnedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
        [builder setUrl:@"https://www.emarsys.com"
        queryParameters:@{
            @"queryName1": @"queryValue1",
            @"queryName2": @[@"1", @"2"]
        }];
    } timestampProvider:[EMSTimestampProvider new]
                                                                uuidProvider:[EMSUUIDProvider new]];

    NSURLComponents *componentsFromReturned = [[NSURLComponents alloc] initWithURL:returnedRequestModel.url
                                                           resolvingAgainstBaseURL:YES];
    XCTAssertEqualObjects(componentsFromReturned.host, expectedComponents.host);
    for (NSURLQueryItem *queryItem in expectedComponents.queryItems) {
        XCTAssertTrue([componentsFromReturned.queryItems containsObject:queryItem]);
    }
    XCTAssertEqual(componentsFromReturned.queryItems.count, 2);
}

@end
