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
#import "EMSLogic.h"
#import "EMSCartItem.h"

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
    OCMStub([self.mockContext merchantId]).andReturn(@"testMerchantId");
}


- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilder alloc] initWithContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testBuild_requestModelUrlContainsCorrectMerchantId {
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:nil
          builderBlock:nil];
}

- (void)testAddSearchTerm {
    NSString *searchTerm = @"jeans";
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:@{
               @"f": @"f:SEARCH,l:2,o:0",
               @"q": searchTerm
       }
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder addLogic:[EMSLogic searchWithSearchTerm:searchTerm]];
          }];
}

- (void)testAddCart {
    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];
    EMSLogic *logic = [EMSLogic cartWithCartItems:@[cartItem1, cartItem2]];

    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:@{
               @"f": @"f:CART,l:2,o:0",
               @"cv": @"1",
               @"ca": @"i:cartItemId1,p:123.0,q:1.0|i:cartItemId2,p:456.0,q:2.0"
       }
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder addLogic:logic];
          }];
}

- (void)assertForUrl:(NSString *)urlString
     queryParameters:(NSDictionary *)queryParameters
        builderBlock:(void (^)(EMSPredictRequestModelBuilder *builder))builderBlock {
    EMSRequestModel *expectedRequestModel = [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                if (queryParameters) {
                    [builder setUrl:urlString
                    queryParameters:queryParameters];
                } else {
                    [builder setUrl:urlString];
                }
                [builder setMethod:HTTPMethodGET];
                [builder setHeaders:@{@"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                                                self.mockContext.deviceInfo.osVersion,
                                                                                self.mockContext.deviceInfo.systemName]}];
            }
                                                           timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUuidProvider];

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext];
    if (builderBlock) {
        builderBlock(builder);
    }
    EMSRequestModel *returnedRequestModel = [builder build];

    XCTAssertEqualObjects(returnedRequestModel.requestId, expectedRequestModel.requestId);
    XCTAssertEqualObjects(returnedRequestModel.timestamp, expectedRequestModel.timestamp);
    XCTAssertEqual(returnedRequestModel.ttl, expectedRequestModel.ttl);
    XCTAssertEqualObjects(returnedRequestModel.method, expectedRequestModel.method);
    XCTAssertEqualObjects(returnedRequestModel.extras, expectedRequestModel.extras);
    XCTAssertEqualObjects(returnedRequestModel.payload, expectedRequestModel.payload);
    XCTAssertEqualObjects(returnedRequestModel.headers, expectedRequestModel.headers);

    NSURLComponents *returnedUrlComponents = [NSURLComponents componentsWithURL:returnedRequestModel.url
                                                        resolvingAgainstBaseURL:NO];
    NSSet *returnedQueryItems = [NSSet setWithArray:returnedUrlComponents.queryItems];

    NSURLComponents *expectedUrlComponents = [NSURLComponents componentsWithURL:expectedRequestModel.url
                                                        resolvingAgainstBaseURL:NO];
    NSSet *expectedQueryItems = [NSSet setWithArray:expectedUrlComponents.queryItems];

    XCTAssertEqualObjects(returnedQueryItems, expectedQueryItems);
}

@end
