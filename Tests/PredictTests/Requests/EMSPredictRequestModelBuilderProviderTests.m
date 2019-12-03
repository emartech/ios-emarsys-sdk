//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSPredictRequestModelBuilderProvider.h"
#import "PRERequestContext.h"
#import "EMSEndpoint.h"

@interface EMSPredictRequestModelBuilderProviderTests : XCTestCase

@end

@implementation EMSPredictRequestModelBuilderProviderTests

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:nil
                                                                     endpoint:OCMClassMock([EMSEndpoint class])];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:OCMClassMock([PRERequestContext class])
                                                                     endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testProvideBuilder {
    PRERequestContext *mockRequestContext = OCMClassMock([PRERequestContext class]);
    EMSPredictRequestModelBuilderProvider *provider = [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:mockRequestContext
                                                                                                                   endpoint:OCMClassMock([EMSEndpoint class])];

    EMSPredictRequestModelBuilder *returnedBuilder = [provider provideBuilder];

    XCTAssertNotNil(returnedBuilder);
}

@end
