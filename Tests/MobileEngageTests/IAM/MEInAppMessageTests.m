//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MEInAppMessage.h"

@interface MEInAppMessageTests : XCTestCase

@end

@implementation MEInAppMessageTests

- (void)testInit_shouldNotAccept_nilResponseModel {
    @try {
        [[MEInAppMessage alloc] initWithResponse:nil];
        XCTFail(@"Expected Exception when threshold is less then responseModel!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseModel");
    }
}

- (void)testInit_shouldNotAccept_nilCampaignId {
    @try {
        [[MEInAppMessage alloc] initWithCampaignId:nil
                                               sid:@"testSid"
                                               url:@"testUrl"
                                              html:@""
                                 responseTimestamp:[NSDate date]];
        XCTFail(@"Expected Exception when threshold is less then campaignId!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: campaignId");
    }
}

- (void)testInit_shouldNotAccept_nilHtml {
    @try {
        [[MEInAppMessage alloc] initWithCampaignId:@"campaignId"
                                               sid:@"testSid"
                                               url:@"testUrl"
                                              html:nil
                                 responseTimestamp:[NSDate date]];
        XCTFail(@"Expected Exception when threshold is less then html!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: html");
    }
}

- (void)testInit_shouldNotAccept_nilResponseTimestamp {
    @try {
        [[MEInAppMessage alloc] initWithCampaignId:@"campaignId"
                                               sid:@"testSid"
                                               url:@"testUrl"
                                              html:@"html"
                                 responseTimestamp:nil];
        XCTFail(@"Expected Exception when threshold is less then responseTimestamp!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: responseTimestamp");
    }
}

@end
