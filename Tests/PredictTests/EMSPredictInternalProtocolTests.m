//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSPredictInternal.h"
#import "PRERequestContext.h"
#import "EMSRequestManager.h"
#import "EMSProductMapper.h"
#import "EMSPredictRequestModelBuilderProvider.h"
#import "EMSLogic.h"

typedef void (^TriggerBlock)(EMSPredictInternal *mockInternal);

@interface EMSPredictInternalProtocolTests : XCTestCase

@property(nonatomic, strong) EMSPredictInternal *predictInternal;
@property(nonatomic, strong) PRERequestContext *requestContext;
@property(nonatomic, strong) EMSRequestManager *requestManager;
@property(nonatomic, strong) EMSPredictRequestModelBuilderProvider *predictRequestModelBuilderProvider;
@property(nonatomic, strong) EMSProductMapper *productMapper;
@property(nonatomic, strong) EMSLogic *testLogic;
@property(nonatomic, strong) NSArray *testFilters;
@property(nonatomic, strong) NSNumber *testLimit;
@property(nonatomic, strong) NSString *testAvailabilityZone;
@property(nonatomic, strong) EMSProductsBlock testBlock;

@end

@implementation EMSPredictInternalProtocolTests

- (void)setUp {
    _requestContext = OCMClassMock([PRERequestContext class]);
    _requestManager = OCMClassMock([EMSRequestManager class]);
    _predictRequestModelBuilderProvider = OCMClassMock([EMSPredictRequestModelBuilderProvider class]);
    _productMapper = OCMClassMock([EMSProductMapper class]);

    _predictInternal = [[EMSPredictInternal alloc] initWithRequestContext:self.requestContext
                                                           requestManager:self.requestManager
                                                   requestBuilderProvider:self.predictRequestModelBuilderProvider
                                                            productMapper:self.productMapper];
    _testLogic = OCMClassMock([EMSLogic class]);
    _testFilters = @[@"filter1", @"filter2"];
    _testLimit = @43;
    _testAvailabilityZone = @"az";
    _testBlock = ^(NSArray<EMSProduct *> *products, NSError *error) {
    };
}

- (void)testRecommendationWithLogicBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:nil
                                  limit:nil
                       availabilityZone:nil
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                          productsBlock:self.testBlock];
                           }];
}

- (void)testRecommendationWithLogicLimitBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:nil
                                  limit:self.testLimit
                       availabilityZone:nil
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                                filters:nil
                                                                  limit:self.testLimit
                                                          productsBlock:self.testBlock];
                           }];
}

- (void)testRecommendationWithLogicFiltersBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:self.testFilters
                                  limit:nil
                       availabilityZone:nil
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                                filters:self.testFilters
                                                          productsBlock:self.testBlock];
                           }];
}

- (void)testRecommendationWithLogicFiltersLimitBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:self.testFilters
                                  limit:self.testLimit
                       availabilityZone:nil
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                                filters:self.testFilters
                                                                  limit:self.testLimit
                                                          productsBlock:self.testBlock];
                           }];
}

- (void)testRecommendationWithLogicAvailabilityZoneBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:nil
                                  limit:nil
                       availabilityZone:self.testAvailabilityZone
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                       availabilityZone:self.testAvailabilityZone
                                                          productsBlock:self.testBlock];
                           }];
}

- (void)testRecommendationWithLogicLimitAvailabilityZoneBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:nil
                                  limit:self.testLimit
                       availabilityZone:self.testAvailabilityZone
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                                  limit:self.testLimit
                                                       availabilityZone:self.testAvailabilityZone
                                                          productsBlock:self.testBlock];
                           }];
}

- (void)testRecommendationWithLogicFilterAvailabilityZoneBlock {
    [self assertRecommendationWithLogic:self.testLogic
                                 filter:self.testFilters
                                  limit:nil
                       availabilityZone:self.testAvailabilityZone
                          productsBlock:self.testBlock
                           triggerBlock:^(EMSPredictInternal *mockInternal) {
                               [mockInternal recommendProductsWithLogic:self.testLogic
                                                                filters:self.testFilters
                                                       availabilityZone:self.testAvailabilityZone
                                                          productsBlock:self.testBlock];
                           }];
}


- (void)assertRecommendationWithLogic:(EMSLogic *)logic
                               filter:(NSArray *)filters
                                limit:(NSNumber *)limit
                     availabilityZone:(NSString *)availabilityZone
                        productsBlock:(EMSProductsBlock)productsBlock
                         triggerBlock:(TriggerBlock)triggerBlock {

    EMSPredictInternal *mockInternal = OCMPartialMock(self.predictInternal);

    triggerBlock(mockInternal);

    OCMVerify([mockInternal recommendProductsWithLogic:logic
                                               filters:filters
                                                 limit:limit
                                      availabilityZone:availabilityZone
                                         productsBlock:productsBlock]);
}

@end
