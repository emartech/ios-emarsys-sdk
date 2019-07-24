//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSPredictRequestModelBuilder.h"
#import "PRERequestContext.h"
#import "EMSRequestModel.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "EMSDeviceInfo.h"

@interface EMSPredictRequestModelBuilderTests : XCTestCase

@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUuidProvider;
@property(nonatomic, strong) PRERequestContext *mockContext;

@end

@implementation EMSPredictRequestModelBuilderTests


- (void)setUp {
    [super setUp];
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockContext = OCMClassMock([PRERequestContext class]);

    OCMStub([self.mockDeviceInfo osVersion]).andReturn(@"testOSVersion");
    OCMStub([self.mockDeviceInfo systemName]).andReturn(@"testSystemName");
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn([NSDate date]);
    OCMStub([self.mockUuidProvider provideUUIDString]).andReturn(@"testUUUIDString");
    OCMStub([self.mockContext timestampProvider]).andReturn(self.mockTimestampProvider);
    OCMStub([self.mockContext uuidProvider]).andReturn(self.mockUuidProvider);
    OCMStub([self.mockContext deviceInfo]).andReturn(self.mockDeviceInfo);
}


- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilder alloc] initWithContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testBuild {
    OCMStub([self.mockContext merchantId]).andReturn(@"testMerchantId");

    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:@{@"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                                                self.mockContext.deviceInfo.osVersion,
                                                                                self.mockContext.deviceInfo.systemName]}];
            }
                                                           timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUuidProvider];

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext];

    EMSRequestModel *returnedRequestModel = [builder build];

    XCTAssertEqualObjects(returnedRequestModel, expectedRequestModel);
}

- (void)testBuild_requestModelUrlContainsCorrectMerchantId {
    OCMStub([self.mockContext merchantId]).andReturn(@"testMerchantId2");

    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId2/"];
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:@{@"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                                                self.mockContext.deviceInfo.osVersion,
                                                                                self.mockContext.deviceInfo.systemName]}];
            }                                              timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUuidProvider];

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext];

    EMSRequestModel *returnedRequestModel = [builder build];
    XCTAssertEqualObjects(returnedRequestModel, expectedRequestModel);
}



@end
