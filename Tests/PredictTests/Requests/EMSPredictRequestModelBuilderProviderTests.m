//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSPredictRequestModelBuilderProvider.h"
#import "PRERequestContext.h"

@interface EMSPredictRequestModelBuilderProviderTests : XCTestCase

@end

@implementation EMSPredictRequestModelBuilderProviderTests

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testProvideBuilder {
    PRERequestContext *mockRequestContext = OCMClassMock([PRERequestContext class]);
    EMSPredictRequestModelBuilderProvider *provider = [[EMSPredictRequestModelBuilderProvider alloc] initWithRequestContext:mockRequestContext];

    EMSPredictRequestModelBuilder *returnedBuilder = [provider provideBuilder];

    XCTAssertNotNil(returnedBuilder);
}

@end
