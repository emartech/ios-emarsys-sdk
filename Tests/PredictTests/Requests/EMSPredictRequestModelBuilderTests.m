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
#import "EMSRecommendationFilter.h"
#import "EMSEndpoint.h"

@interface EMSPredictRequestModelBuilderTests : XCTestCase

@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUuidProvider;
@property(nonatomic, strong) PRERequestContext *mockContext;
@property(nonatomic, strong) EMSEndpoint *mockEndpoint;

@end

@implementation EMSPredictRequestModelBuilderTests

- (void)setUp {
    [super setUp];
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockContext = OCMClassMock([PRERequestContext class]);
    _mockEndpoint = OCMClassMock([EMSEndpoint class]);

    OCMStub([self.mockDeviceInfo osVersion]).andReturn(@"testOSVersion");
    OCMStub([self.mockDeviceInfo systemName]).andReturn(@"testSystemName");
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn([NSDate date]);
    OCMStub([self.mockUuidProvider provideUUIDString]).andReturn(@"testUUUIDString");
    OCMStub([self.mockContext timestampProvider]).andReturn(self.mockTimestampProvider);
    OCMStub([self.mockContext uuidProvider]).andReturn(self.mockUuidProvider);
    OCMStub([self.mockContext deviceInfo]).andReturn(self.mockDeviceInfo);
    OCMStub([self.mockContext merchantId]).andReturn(@"testMerchantId");
    OCMStub([self.mockContext xp]).andReturn(@"testXP");
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockEndpoint predictUrl]).andReturn(@"https://recommender.scarabresearch.com");
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilder alloc] initWithContext:nil
                                                      endpoint:self.mockEndpoint];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testInit_endpoint_mustNotBeNil {
    @try {
        [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext
                                                      endpoint:nil];
        XCTFail(@"Expected Exception when endpoint is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: endpoint");
    }
}

- (void)testBuild_requestModelUrlContainsCorrectMerchantId {
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:nil
          builderBlock:nil];
}

- (void)testCookie {
    NSDictionary *expectedHeaders = @{
        @"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                  self.mockContext.deviceInfo.osVersion,
                                                  self.mockContext.deviceInfo.systemName]
    };

    EMSDeviceInfo *mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    EMSTimestampProvider *mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    EMSUUIDProvider *mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    PRERequestContext *mockContext = OCMClassMock([PRERequestContext class]);

    OCMStub([mockDeviceInfo osVersion]).andReturn(@"testOSVersion");
    OCMStub([mockDeviceInfo systemName]).andReturn(@"testSystemName");
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn([NSDate date]);
    OCMStub([mockUuidProvider provideUUIDString]).andReturn(@"testUUUIDString");
    OCMStub([mockContext timestampProvider]).andReturn(self.mockTimestampProvider);
    OCMStub([mockContext uuidProvider]).andReturn(self.mockUuidProvider);
    OCMStub([mockContext deviceInfo]).andReturn(self.mockDeviceInfo);
    OCMStub([mockContext merchantId]).andReturn(@"testMerchantId");

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:mockContext
                                                                                           endpoint:self.mockEndpoint];

    EMSRequestModel *requestModel = [builder build];

    XCTAssertEqualObjects(requestModel.headers, expectedHeaders);
}

- (void)testVisitorId_isNotInCookie_butThereIsXp {
    NSDictionary *expectedHeaders = @{
        @"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                  self.mockContext.deviceInfo.osVersion,
                                                  self.mockContext.deviceInfo.systemName],
        @"Cookie": @"xp=testXp;"
    };

    EMSDeviceInfo *mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    EMSTimestampProvider *mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    EMSUUIDProvider *mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    PRERequestContext *mockContext = OCMClassMock([PRERequestContext class]);

    OCMStub([mockDeviceInfo osVersion]).andReturn(@"testOSVersion");
    OCMStub([mockDeviceInfo systemName]).andReturn(@"testSystemName");
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn([NSDate date]);
    OCMStub([mockUuidProvider provideUUIDString]).andReturn(@"testUUUIDString");
    OCMStub([mockContext timestampProvider]).andReturn(self.mockTimestampProvider);
    OCMStub([mockContext uuidProvider]).andReturn(self.mockUuidProvider);
    OCMStub([mockContext deviceInfo]).andReturn(self.mockDeviceInfo);
    OCMStub([mockContext merchantId]).andReturn(@"testMerchantId");
    OCMStub([mockContext xp]).andReturn(@"testXp");

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:mockContext
                                                                                           endpoint:self.mockEndpoint];

    EMSRequestModel *requestModel = [builder build];

    XCTAssertEqualObjects(requestModel.headers, expectedHeaders);
}

- (void)testVisitorId_isInCookie_butThereIsNotXp {
    NSDictionary *expectedHeaders = @{
        @"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                  self.mockContext.deviceInfo.osVersion,
                                                  self.mockContext.deviceInfo.systemName],
        @"Cookie": @"cdv=testVisitorId;"
    };

    EMSDeviceInfo *mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    EMSTimestampProvider *mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    EMSUUIDProvider *mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    PRERequestContext *mockContext = OCMClassMock([PRERequestContext class]);

    OCMStub([mockDeviceInfo osVersion]).andReturn(@"testOSVersion");
    OCMStub([mockDeviceInfo systemName]).andReturn(@"testSystemName");
    OCMStub([mockTimestampProvider provideTimestamp]).andReturn([NSDate date]);
    OCMStub([mockUuidProvider provideUUIDString]).andReturn(@"testUUUIDString");
    OCMStub([mockContext timestampProvider]).andReturn(self.mockTimestampProvider);
    OCMStub([mockContext uuidProvider]).andReturn(self.mockUuidProvider);
    OCMStub([mockContext deviceInfo]).andReturn(self.mockDeviceInfo);
    OCMStub([mockContext merchantId]).andReturn(@"testMerchantId");
    OCMStub([mockContext visitorId]).andReturn(@"testVisitorId");

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:mockContext
                                                                                           endpoint:self.mockEndpoint];

    EMSRequestModel *requestModel = [builder build];

    XCTAssertEqualObjects(requestModel.headers, expectedHeaders);
}

- (void)testLimit_defaultValue_whenNil {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"vi"] = @"testVisitorId";
    mutableQueryParams[@"ci"] = @"testCustomerId";
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
              [builder withLimit:nil];
          }];
}

- (void)testLimit_defaultValue_whenLimitIsZero {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"vi"] = @"testVisitorId";
    mutableQueryParams[@"ci"] = @"testCustomerId";
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
              [builder withLimit:@0];
          }];
}

- (void)testLimit_defaultValue_whenLimitIsNegative {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"vi"] = self.mockContext.visitorId;
    mutableQueryParams[@"ci"] = self.mockContext.customerId;
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
              [builder withLimit:@-321];
          }];
}

- (void)testLimit {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:123,o:0", logic.logic];
    mutableQueryParams[@"vi"] = self.mockContext.visitorId;
    mutableQueryParams[@"ci"] = self.mockContext.customerId;
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
              [builder withLimit:@123];
          }];
}

- (void)testVisitorId_whenNil {
    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"vi"] = self.mockContext.visitorId;


    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
          }];
}

- (void)testCustomerId_whenNil {
    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"ci"] = self.mockContext.customerId;
    mutableQueryParams[@"vi"] = self.mockContext.visitorId;

    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
          }];
}

- (void)testFilter {
    NSArray<NSDictionary<NSString *, NSString *> *> *expectedFilterQueryRawValue = @[
        @{
            @"f": @"testField1",
            @"r": @"HAS",
            @"v": @"testValue1",
            @"n": @NO
        },
        @{
            @"f": @"testField2",
            @"r": @"IS",
            @"v": @"testValue2",
            @"n": @NO
        },
        @{
            @"f": @"testField3",
            @"r": @"IN",
            @"v": @"testValue31|testValue32",
            @"n": @NO
        },
        @{
            @"f": @"testField4",
            @"r": @"OVERLAPS",
            @"v": @"testValue41|testValue42",
            @"n": @NO
        },
        @{
            @"f": @"testField5",
            @"r": @"HAS",
            @"v": @"testValue5",
            @"n": @YES
        },
        @{
            @"f": @"testField6",
            @"r": @"IS",
            @"v": @"testValue6",
            @"n": @YES
        },
        @{
            @"f": @"testField7",
            @"r": @"IN",
            @"v": @"testValue71|testValue72",
            @"n": @YES
        },
        @{
            @"f": @"testField8",
            @"r": @"OVERLAPS",
            @"v": @"testValue81|testValue82",
            @"n": @YES
        }
    ];

    NSString *expectedFilterQueryValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:expectedFilterQueryRawValue
                                                                                                        options:NSJSONWritingPrettyPrinted
                                                                                                          error:nil]
                                                               encoding:NSUTF8StringEncoding];

    EMSLogic *logic = EMSLogic.search;
    NSMutableDictionary *mutableQueryParams = [NSMutableDictionary dictionary];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"ex"] = expectedFilterQueryValue;
    mutableQueryParams[@"vi"] = self.mockContext.visitorId;
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
              [builder withFilter:@[
                  [EMSRecommendationFilter excludeFilterWithField:@"testField1"
                                                         hasValue:@"testValue1"],
                  [EMSRecommendationFilter excludeFilterWithField:@"testField2"
                                                          isValue:@"testValue2"],
                  [EMSRecommendationFilter excludeFilterWithField:@"testField3"
                                                         inValues:@[@"testValue31", @"testValue32"]],
                  [EMSRecommendationFilter excludeFilterWithField:@"testField4"
                                                   overlapsValues:@[@"testValue41", @"testValue42"]],
                  [EMSRecommendationFilter includeFilterWithField:@"testField5"
                                                         hasValue:@"testValue5"],
                  [EMSRecommendationFilter includeFilterWithField:@"testField6"
                                                          isValue:@"testValue6"],
                  [EMSRecommendationFilter includeFilterWithField:@"testField7"
                                                         inValues:@[@"testValue71", @"testValue72"]],
                  [EMSRecommendationFilter includeFilterWithField:@"testField8"
                                                   overlapsValues:@[@"testValue81", @"testValue82"]]
              ]];
          }];
}

- (void)testRecommendationLogic {
    [self assertWithParameterizedSel:@selector(searchWithSearchTerm:)
                            emptySel:@selector(search)
                               param:@"testSearchTerm"
                           lastParam:@"lastTestSearchTerm"
                        builderBlock:^(EMSPredictRequestModelBuilder *builder) {
                            [builder withLastSearchTerm:@"lastTestSearchTerm"];
                            [builder withLastCategoryPath:@"lastTestCategoryPath"];
                        }];

    EMSCartItem *cartItem1 = [[EMSCartItem alloc] initWithItemId:@"cartItemId1"
                                                           price:123
                                                        quantity:1];
    EMSCartItem *cartItem2 = [[EMSCartItem alloc] initWithItemId:@"cartItemId2"
                                                           price:456
                                                        quantity:2];
    EMSCartItem *cartItem3 = [[EMSCartItem alloc] initWithItemId:@"cartItemId3"
                                                           price:469
                                                        quantity:3];
    EMSCartItem *cartItem4 = [[EMSCartItem alloc] initWithItemId:@"cartItemId4"
                                                           price:478
                                                        quantity:4];
    [self assertWithParameterizedSel:@selector(cartWithCartItems:)
                            emptySel:@selector(cart)
                               param:@[cartItem1, cartItem2]
                           lastParam:@[cartItem3, cartItem4]
                        builderBlock:^(EMSPredictRequestModelBuilder *builder) {
                            [builder withLastCartItems:@[cartItem3, cartItem4]];
                            [builder withLastCategoryPath:@"lastTestCategoryPath"];
                        }];

    [self assertWithParameterizedSel:@selector(relatedWithViewItemId:)
                            emptySel:@selector(related)
                               param:@"testViewId"
                           lastParam:@"lastTestViewId"
                        builderBlock:^(EMSPredictRequestModelBuilder *builder) {
                            [builder withLastViewItemId:@"lastTestViewId"];
                            [builder withLastCategoryPath:@"lastTestCategoryPath"];
                        }];
    [self assertWithParameterizedSel:@selector(categoryWithCategoryPath:)
                            emptySel:@selector(category)
                               param:@"testCategoryPath"
                           lastParam:@"lastTestCategoryPath"
                        builderBlock:^(EMSPredictRequestModelBuilder *builder) {
                            [builder withLastCategoryPath:@"lastTestCategoryPath"];
                            [builder withLastViewItemId:@"lastTestViewId"];
                        }];
    [self assertWithParameterizedSel:@selector(alsoBoughtWithViewItemId:)
                            emptySel:@selector(alsoBought)
                               param:@"testViewId"
                           lastParam:@"lastTestViewId"
                        builderBlock:^(EMSPredictRequestModelBuilder *builder) {
                            [builder withLastViewItemId:@"lastTestViewId"];
                            [builder withLastCategoryPath:@"lastTestCategoryPath"];
                        }];
    [self assertWithParameterizedSel:@selector(popularWithCategoryPath:)
                            emptySel:@selector(popular)
                               param:@"testCategoryPath"
                           lastParam:@"lastTestCategoryPath"
                        builderBlock:^(EMSPredictRequestModelBuilder *builder) {
                            [builder withLastCategoryPath:@"lastTestCategoryPath"];
                            [builder withLastViewItemId:@"lastViewItemId"];
                        }];
}

- (void)testPersonalLogic {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    EMSLogic *logic = [EMSLogic personalWithVariants:@[@"1", @"2", @"3"]];

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext
                                                                                           endpoint:self.mockEndpoint];
    [builder withLogic:logic];
    EMSRequestModel *requestModel = [builder build];

    XCTAssertEqualObjects(requestModel.url.absoluteString, @"https://recommender.scarabresearch.com/merchants/testMerchantId/?f=f:PERSONAL_1,l:5,o:0%7Cf:PERSONAL_2,l:5,o:0%7Cf:PERSONAL_3,l:5,o:0&ci=testCustomerId&vi=testVisitorId");
}

- (void)testHomeLogic {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    EMSLogic *logic = [EMSLogic homeWithVariants:@[@"1", @"2", @"3"]];

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext
                                                                                           endpoint:self.mockEndpoint];
    [builder withLogic:logic];
    EMSRequestModel *requestModel = [builder build];

    XCTAssertEqualObjects(requestModel.url.absoluteString, @"https://recommender.scarabresearch.com/merchants/testMerchantId/?f=f:HOME_1,l:5,o:0%7Cf:HOME_2,l:5,o:0%7Cf:HOME_3,l:5,o:0&ci=testCustomerId&vi=testVisitorId");
}

- (void)assertWithParameterizedSel:(SEL)parameterizedSel
                          emptySel:(SEL)emptySel
                             param:(id)param
                         lastParam:(id)lastParam
                      builderBlock:(void (^)(EMSPredictRequestModelBuilder *builder))builderBlock {
    EMSLogic *logic = [EMSLogic performSelector:emptySel];
    EMSLogic *logicWithParam = [EMSLogic performSelector:parameterizedSel
                                              withObject:param];
    EMSLogic *logicWithLastParam = [EMSLogic performSelector:parameterizedSel
                                                  withObject:lastParam];
    [self assertForLogic:logicWithParam
         withQueryParams:logicWithParam.data
            builderBlock:nil];
    [self assertForLogic:logic
         withQueryParams:logicWithLastParam.data
            builderBlock:builderBlock];
    [self assertForLogic:logicWithParam
         withQueryParams:logicWithParam.data
            builderBlock:builderBlock];
    [self assertForLogic:logic
         withQueryParams:@{}
            builderBlock:nil];
}

- (void)assertForLogic:(EMSLogic *)logic
       withQueryParams:(NSDictionary *)queryParams
          builderBlock:(void (^)(EMSPredictRequestModelBuilder *builder))builderBlock {
    OCMStub([self.mockContext visitorId]).andReturn(@"testVisitorId");
    OCMStub([self.mockContext customerId]).andReturn(@"testCustomerId");

    NSMutableDictionary *mutableQueryParams = [queryParams mutableCopy];
    mutableQueryParams[@"f"] = [NSString stringWithFormat:@"f:%@,l:5,o:0", logic.logic];
    mutableQueryParams[@"vi"] = self.mockContext.visitorId;
    mutableQueryParams[@"ci"] = self.mockContext.customerId;
    [self assertForUrl:@"https://recommender.scarabresearch.com/merchants/testMerchantId/"
       queryParameters:[NSDictionary dictionaryWithDictionary:mutableQueryParams]
          builderBlock:^(EMSPredictRequestModelBuilder *builder) {
              [builder withLogic:logic];
              if (builderBlock) {
                  builderBlock(builder);
              }
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
            [builder setHeaders:@{
                @"User-Agent": [NSString stringWithFormat:@"EmarsysSDK|osversion:%@|platform:%@",
                                                          self.mockContext.deviceInfo.osVersion,
                                                          self.mockContext.deviceInfo.systemName],
                @"Cookie": [NSString stringWithFormat:@"xp=%@;cdv=%@;", self.mockContext.xp, self.mockContext.visitorId]
            }];
        }
                                                           timestampProvider:self.mockTimestampProvider
                                                                uuidProvider:self.mockUuidProvider];

    EMSPredictRequestModelBuilder *builder = [[EMSPredictRequestModelBuilder alloc] initWithContext:self.mockContext
                                                                                           endpoint:self.mockEndpoint];
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
