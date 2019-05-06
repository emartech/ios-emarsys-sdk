//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EMSConfig.h"

@interface EMSConfigTests : XCTestCase

@end

@implementation EMSConfigTests

- (void)testMakeWithBuilder_builderBlock_mustNotBeNil {
    @try {
        [EMSConfig makeWithBuilder:nil];
        XCTFail(@"Expected Exception when builderBlock is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: builderBlock");
    }
}

- (void)testMakeWithBuilder_applicationCode_mustNotBeNil {
    @try {
        [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setContactFieldId:@3];
            [builder setMerchantId:@"testMerchantId"];
            [builder setMobileEngageApplicationCode:nil
                                applicationPassword:@"testApplicationPassword"];

        }];
        XCTFail(@"Expected Exception when applicationCode is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: builder.applicationCode");
    }
}

- (void)testMakeWithBuilder_applicationPassword_mustNotBeNil {
    @try {
        [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setContactFieldId:@3];
            [builder setMerchantId:@"testMerchantId"];
            [builder setMobileEngageApplicationCode:@"testApplicationCode"
                                applicationPassword:nil];

        }];
        XCTFail(@"Expected Exception when applicationPassword is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: builder.applicationPassword");
    }
}

- (void)testMakeWithBuilder_contactFieldId_mustNotBeNil {
    @try {
        [EMSConfig makeWithBuilder:^(EMSConfigBuilder *builder) {
            [builder setMerchantId:@"testMerchantId"];
            [builder setMobileEngageApplicationCode:@"testApplicationCode"
                                applicationPassword:@"testApplicationPassword"];

        }];
        XCTFail(@"Expected Exception when contactFieldId is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: builder.contactFieldId");
    }
}

@end
