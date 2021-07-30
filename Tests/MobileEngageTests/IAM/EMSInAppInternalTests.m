//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSInAppInternal.h"
#import "EMSRequestManager.h"
#import "EMSRequestFactory.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MEInAppMessage.h"
#import "MEInApp.h"

@interface EMSInAppInternalTests : XCTestCase

@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) EMSInAppInternal *internal;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) MEInApp *mockMEInApp;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUuidProvider;

@end

@implementation EMSInAppInternalTests

- (void)setUp {
    _timestampProvider = [EMSTimestampProvider new];
    _uuidProvider = [EMSUUIDProvider new];

    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockMEInApp = OCMClassMock([MEInApp class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUuidProvider = OCMClassMock([EMSUUIDProvider class]);
    _internal = [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                                  requestFactory:self.mockRequestFactory
                                                         meInApp:self.mockMEInApp
                                               timestampProvider:self.mockTimestampProvider
                                                    uuidProvider:self.mockUuidProvider];
}

- (void)tearDown {
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:nil
                                          requestFactory:self.mockRequestFactory
                                                 meInApp:self.mockMEInApp
                                       timestampProvider:self.mockTimestampProvider
                                            uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                          requestFactory:nil
                                                 meInApp:self.mockMEInApp
                                       timestampProvider:self.mockTimestampProvider
                                            uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_meInApp_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                          requestFactory:self.mockRequestFactory
                                                 meInApp:nil
                                       timestampProvider:self.mockTimestampProvider
                                            uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when meInApp is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: meInApp");
    }
}

- (void)testInit_timestampProvider_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                          requestFactory:self.mockRequestFactory
                                                 meInApp:self.mockMEInApp
                                       timestampProvider:nil
                                            uuidProvider:self.mockUuidProvider];
        XCTFail(@"Expected Exception when timestampProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: timestampProvider");
    }
}

- (void)testInit_uuidProvider_mustNotBeNil {
    @try {
        [[EMSInAppInternal alloc] initWithRequestManager:self.mockRequestManager
                                          requestFactory:self.mockRequestFactory
                                                 meInApp:self.mockMEInApp
                                       timestampProvider:self.mockTimestampProvider
                                            uuidProvider:nil];
        XCTFail(@"Expected Exception when uuidProvider is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: uuidProvider");
    }
}

- (void)testTrackInAppDisplay {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *campaignId = @"testCampaignId";
    NSString *eventName = @"inapp:viewed";
    NSDictionary *eventAttributes = @{
        @"campaignId": campaignId,
        @"sid": @"1cf3f_JhIPRzBvNtQF",
        @"url": @"https://www.test.com"
    };

    MEInAppMessage *message = [[MEInAppMessage alloc] initWithCampaignId:campaignId
                                                                     sid:@"1cf3f_JhIPRzBvNtQF"
                                                                     url:@"https://www.test.com"
                                                                    html:@"</HTML>"
                                                       responseTimestamp:[NSDate date]];

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    [self.internal trackInAppDisplay:message];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
}


- (void)testTrackInAppDisplay_whenOnlyMessageIdIsAvailable {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *campaignId = @"testCampaignId";
    NSString *eventName = @"inapp:viewed";
    NSDictionary *eventAttributes = @{
        @"campaignId": campaignId
    };

    MEInAppMessage *message = [[MEInAppMessage alloc] initWithCampaignId:campaignId
                                                                     sid:nil
                                                                     url:nil
                                                                    html:@"</HTML>"
                                                       responseTimestamp:[NSDate date]];

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    [self.internal trackInAppDisplay:message];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
}

- (void)testTrackInAppDisplay_shouldNotCallRequestFactory_andRequestManager_whenCampaignId_isNil {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);
    [self.internal trackInAppDisplay:nil];
}

- (void)testTrackInAppClickButtonId {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *campaignId = @"testCampaignId";
    NSString *buttonId = @"testButtonId";
    NSString *eventName = @"inapp:click";

    NSDictionary *eventAttributes = @{
        @"campaignId": campaignId,
        @"sid": @"1cf3f_JhIPRzBvNtQF",
        @"url": @"https://www.test.com",
        @"buttonId": buttonId
    };

    MEInAppMessage *message = [[MEInAppMessage alloc] initWithCampaignId:campaignId
                                                                     sid:@"1cf3f_JhIPRzBvNtQF"
                                                                     url:@"https://www.test.com"
                                                                    html:@"</HTML>"
                                                       responseTimestamp:[NSDate date]];

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    [self.internal trackInAppClick:message
                          buttonId:buttonId];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
}

- (void)testTrackInAppClickButtonId_whenOnlyMessageIdIsAvailable {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSString *campaignId = @"testCampaignId";
    NSString *buttonId = @"testButtonId";
    NSString *eventName = @"inapp:click";

    NSDictionary *eventAttributes = @{
        @"campaignId": campaignId,
        @"buttonId": buttonId
    };

    MEInAppMessage *message = [[MEInAppMessage alloc] initWithCampaignId:campaignId
                                                                     sid:nil
                                                                     url:nil
                                                                    html:@"</HTML>"
                                                       responseTimestamp:[NSDate date]];

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                          eventAttributes:eventAttributes
                                                                eventType:EventTypeInternal]).andReturn(requestModel);

    [self.internal trackInAppClick:message
                          buttonId:buttonId];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:eventName
                                                            eventAttributes:eventAttributes
                                                                  eventType:EventTypeInternal]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
}

- (void)testTrackInAppClickButtonId_shouldNotCallRequestFactory_andRequestManager_whenCampaignId_isNil {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);
    [self.internal trackInAppClick:nil
                          buttonId:@"testButtonId"];
}

- (void)testTrackInAppClickButtonId_shouldNotCallRequestFactory_andRequestManager_whenButtonId_isNil {
    EMSRequestModel *requestModel = [self createRequestModel];

    MEInAppMessage *message = [[MEInAppMessage alloc] initWithCampaignId:@"testCampaignId"
                                                                     sid:@"1cf3f_JhIPRzBvNtQF"
                                                                     url:@"https://www.test.com"
                                                                    html:@"</HTML>"
                                                       responseTimestamp:[NSDate date]];

    OCMReject([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                            eventAttributes:[OCMArg any]
                                                                  eventType:EventTypeInternal]);
    OCMReject([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:nil]);
    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:[OCMArg any]
                                                          eventAttributes:[OCMArg any]
                                                                eventType:EventTypeInternal]).andReturn(requestModel);
    [self.internal trackInAppClick:message
                          buttonId:nil];
}

- (void)testShouldCall_showMessageCompletionHandler_onIAMWithInAppMessage_whenDidReceiveNotificationResponseWithCompletionHandler_isCalledWithInAppPayload {
    NSDate *responseTimestamp = [NSDate date];
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(responseTimestamp);

    MEInAppMessage *expectation = [[MEInAppMessage new] initWithCampaignId:@"42"
                                                                       sid:@"123456789"
                                                                       url:@"https://www.test.com"
                                                                      html:@"<html/>"
                                                         responseTimestamp:responseTimestamp];

    NSDictionary *inAppDictionary = @{
            @"campaign_id": @"42",
            @"url": @"https://www.test.com",
            @"inAppData": [@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
    };

    NSDictionary *userInfo = @{@"ems": @{
            @"inapp": inAppDictionary},
            @"u": @"{\"sid\": \"123456789\"}"};

    [self.internal handleInApp:userInfo
                         inApp:inAppDictionary];

    OCMVerify([self.mockMEInApp showMessage:expectation
                        completionHandler:[OCMArg any]]);
}

- (void)testShouldDownloadInappAndTriggerIt_whenInAppDataMissing {
    NSDate *responseTimestamp = [NSDate date];
    OCMStub([self.mockTimestampProvider provideTimestamp]).andReturn(responseTimestamp);

    NSDictionary *inAppDictionary = @{
            @"campaign_id": @"42",
            @"url": @"https://www.test.com"
    };

    NSDictionary *userInfo = @{@"ems": @{
            @"inapp": inAppDictionary},
            @"u": @"{\"sid\": \"123456789\"}"};

    EMSResponseModel *responseModel = [[EMSResponseModel alloc] initWithStatusCode:200
                                                                           headers:@{}
                                                                              body:[@"<html/>" dataUsingEncoding:NSUTF8StringEncoding]
                                                                        parsedBody:nil
                                                                      requestModel:OCMClassMock([EMSRequestModel class])
                                                                         timestamp:responseTimestamp];

    MEInAppMessage *inAppMessage = [[MEInAppMessage alloc] initWithCampaignId:@"42"
                                                                          sid:@"123456789"
                                                                          url:@"https://www.test.com"
                                                                         html:@"<html/>"
                                                            responseTimestamp:responseTimestamp];

    OCMStub([self.mockRequestManager submitRequestModelNow:[OCMArg any]
                                              successBlock:([OCMArg invokeBlockWithArgs:@"testRequestId",
                                                                                        responseModel,
                                                                                        nil])
                                                errorBlock:[OCMArg any]]);

    [self.internal handleInApp:userInfo
                         inApp:inAppDictionary];

    OCMVerify([self.mockMEInApp showMessage:inAppMessage
                        completionHandler:[OCMArg any]]);
    OCMVerify([self.mockTimestampProvider provideTimestamp]);
    OCMVerify([self.mockTimestampProvider provideTimestamp]);
}

- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }             timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end
