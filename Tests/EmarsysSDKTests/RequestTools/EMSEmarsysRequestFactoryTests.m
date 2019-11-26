//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSEmarsysRequestFactory.h"
#import "EMSUUIDProvider.h"
#import "EMSTimestampProvider.h"
#import "EMSRequestModel.h"

@interface EMSEmarsysRequestFactoryTests : XCTestCase

@property(nonatomic, strong) EMSUUIDProvider *mockUUIDProvider;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;

@end

@implementation EMSEmarsysRequestFactoryTests

- (void)setUp {
    _mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);

}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:nil
                                                       uuidProvider:self.mockUUIDProvider];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testInit_uuidProvider_mustNotBeNil {
    @try {
        [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:self.mockTimestampProvider
                                                       uuidProvider:nil];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: uuidProvider");
    }
}

- (void)testCreateRemoteConfigRequestModel {
    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setMethod:HTTPMethodGET];
            [builder setUrl:@"https://api.myjson.com/bins/1bk0ie"];
        }
                                                           timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUUIDProvider];

    EMSEmarsysRequestFactory *requestFactory = [[EMSEmarsysRequestFactory alloc] initWithTimestampProvider:self.mockTimestampProvider
                                                                                              uuidProvider:self.mockUUIDProvider];

    EMSRequestModel *returnedRequestModel = [requestFactory createRemoteConfigRequestModel];

    XCTAssertEqualObjects(returnedRequestModel, expectedRequestModel);
}

@end
