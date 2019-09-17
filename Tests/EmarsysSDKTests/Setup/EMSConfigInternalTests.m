//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSConfigInternal.h"

@interface EMSConfigInternalTests : XCTestCase

@property(nonatomic, strong) EMSConfigInternal *testConfigInternal;
@property(nonatomic, strong) NSString *applicationCode;
@property(nonatomic, strong) NSString *merchantId;
@property(nonatomic, strong) NSNumber *contactFieldId;
@property(nonatomic, strong) NSArray<id<EMSFlipperFeature>> *features;

@end

@implementation EMSConfigInternalTests

- (void)setUp {
    _applicationCode = @"testApplicationCode";
    _merchantId = @"testMerchantId";
    _contactFieldId = @3;
    id<EMSFlipperFeature> feature = OCMProtocolMock(@protocol(EMSFlipperFeature));
    _features = @[feature];

    EMSConfig *testConfig = [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
        [builder setMobileEngageApplicationCode:self.applicationCode];
        [builder setMerchantId:self.merchantId];
        [builder setContactFieldId:self.contactFieldId];
        [builder setExperimentalFeatures:self.features];
    }];

    _testConfigInternal = [[EMSConfigInternal alloc] initWithConfig:testConfig];
}


- (void)testInit_config_mustNotBeNil {
    @try {
        [[EMSConfigInternal alloc] initWithConfig:nil];
        XCTFail(@"Expected Exception when config is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: config");
    }
}

- (void)testApplicationCode {
    XCTAssertEqualObjects(self.applicationCode, self.testConfigInternal.applicationCode);
}

- (void)testChangeApplicationCode {
    NSString *changedAppCode = @"changedApplicationCode";

    [self.testConfigInternal changeApplicationCode:changedAppCode
                                 completionHandler:^(NSError *error) {
                                 }];

    XCTAssertEqualObjects(changedAppCode, self.testConfigInternal.applicationCode);
}

- (void)testChangeApplicationCode_completionHandler_mustNotBeNil {
    @try {
        [self.testConfigInternal changeApplicationCode:@"newApplicationCode"
                                     completionHandler:nil];
        XCTFail(@"Expected Exception when completionHandler is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: completionHandler");
    }
}

- (void)testMerchantId {
    XCTAssertEqualObjects(self.merchantId, self.testConfigInternal.merchantId);
}

- (void)testChangeMerchantId {
    NSString *newMerchantId = @"newMerchantId";

    [self.testConfigInternal changeMerchantId:newMerchantId];

    XCTAssertEqualObjects(newMerchantId, self.testConfigInternal.merchantId);
}

- (void)testContactFieldId {
    XCTAssertEqualObjects(self.contactFieldId, self.testConfigInternal.contactFieldId);
}

- (void)testSetContactFieldId {
    NSNumber *newContactFieldId = @5;
    [self.testConfigInternal setContactFieldId:newContactFieldId];

    XCTAssertEqualObjects(newContactFieldId, self.testConfigInternal.contactFieldId);
}

- (void)testSetContactFieldId_contactFieldId_mustNotBeNil {
    @try {
        [self.testConfigInternal setContactFieldId:nil];
        XCTFail(@"Expected Exception when contactFieldId is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: contactFieldId");
    }
}

- (void)testExperimentalFeatures {
    XCTAssertEqualObjects(self.features, self.testConfigInternal.experimentalFeatures);
}


@end
