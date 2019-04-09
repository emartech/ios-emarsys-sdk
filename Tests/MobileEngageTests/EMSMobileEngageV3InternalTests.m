//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSTimestampProvider.h"
#import "EMSUUIDProvider.h"
#import "MERequestContext.h"

@interface EMSMobileEngageV3InternalTests : XCTestCase

@property(nonatomic, strong) EMSMobileEngageV3Internal *internal;
@property(nonatomic, strong) EMSRequestFactory *mockRequestFactory;
@property(nonatomic, strong) EMSRequestManager *mockRequestManager;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) NSString *contactFieldValue;
@property(nonatomic, strong) EMSTimestampProvider *timestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *uuidProvider;
@property(nonatomic, strong) NSString *eventName;
@property(nonatomic, strong) NSDictionary *eventAttributes;
@property(nonatomic, copy) void (^completionBlock)(NSError *);

@end

@implementation EMSMobileEngageV3InternalTests

- (void)setUp {
    _timestampProvider = [EMSTimestampProvider new];
    _uuidProvider = [EMSUUIDProvider new];

    _contactFieldValue = @"testContactFieldValue";
    _eventName = @"testEventName";
    _eventAttributes = @{
        @"TestKey": @"TestValue"
    };
    _completionBlock = ^(NSError *error) {
    };

    _mockRequestFactory = OCMClassMock([EMSRequestFactory class]);
    _mockRequestManager = OCMClassMock([EMSRequestManager class]);
    _mockRequestContext = OCMClassMock([MERequestContext class]);

    _internal = [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                           requestManager:self.mockRequestManager
                                                           requestContext:self.mockRequestContext];
}

- (void)testInit_requestFactory_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:nil
                                                   requestManager:self.mockRequestManager
                                                   requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when requestFactory is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestFactory");
    }
}

- (void)testInit_requestManager_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:nil
                                                   requestContext:self.mockRequestContext];
        XCTFail(@"Expected Exception when requestManager is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestManager");
    }
}


- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSMobileEngageV3Internal alloc] initWithRequestFactory:self.mockRequestFactory
                                                   requestManager:self.mockRequestManager
                                                   requestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: requestContext");
    }
}

- (void)testSetContactWithContactFieldValue {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal setContactWithContactFieldValue:self.contactFieldValue];

    OCMVerify([partialMockInternal setContactWithContactFieldValue:self.contactFieldValue
                                                   completionBlock:nil]);
}

- (void)testSetContactWithContactFieldValueCompletionBlock {
    EMSRequestModel *requestModel = [self createRequestModel];
    NSNumber *contactFieldId = @3;

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(contactFieldId);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setContactWithContactFieldValue:self.contactFieldValue
                                   completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestContext setContactFieldValue:self.contactFieldValue]);

    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
}

- (void)testClearContact {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal clearContact];

    OCMVerify([partialMockInternal clearContactWithCompletionBlock:nil];);
}

- (void)testClearContactWithCompletionBlock {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    OCMStub([partialMockInternal setContactWithContactFieldValue:nil
                                                 completionBlock:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        OCMVerify([self.mockRequestContext reset]);
    });

    [partialMockInternal clearContactWithCompletionBlock:self.completionBlock];

    OCMVerify([partialMockInternal setContactWithContactFieldValue:nil
                                                   completionBlock:self.completionBlock]);
}

- (void)testTrackCustomEventWithNameEventAttributes_eventName_mustNotBeNil {
    @try {
        [self.internal trackCustomEventWithName:nil
                                eventAttributes:@{}];
        XCTFail(@"Expected Exception when eventName is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventName");
    }
}

- (void)testTrackCustomEventWithNameEventAttributesCompletionBlock_eventName_mustNotBeNil {
    @try {
        [self.internal trackCustomEventWithName:nil
                                eventAttributes:@{}
                                completionBlock:self.completionBlock];
        XCTFail(@"Expected Exception when eventName is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: eventName");
    }
}

- (void)testTrackCustomEventWithNameEventAttributes {
    EMSMobileEngageV3Internal *partialMockInternal = OCMPartialMock(self.internal);

    [partialMockInternal trackCustomEventWithName:self.eventName
                                  eventAttributes:self.eventAttributes];

    OCMVerify([partialMockInternal trackCustomEventWithName:self.eventName
                                            eventAttributes:self.eventAttributes
                                            completionBlock:nil]);
}

- (void)testTrackCustomEventWithNameEventAttributesCompletionBlock {
    EMSRequestModel *requestModel = [self createRequestModel];

    OCMStub([self.mockRequestFactory createEventRequestModelWithEventName:self.eventName
                                                          eventAttributes:self.eventAttributes
                                                                eventType:EventTypeCustom]).andReturn(requestModel);

    [self.internal trackCustomEventWithName:self.eventName
                            eventAttributes:self.eventAttributes
                            completionBlock:self.completionBlock];

    OCMVerify([self.mockRequestFactory createEventRequestModelWithEventName:self.eventName
                                                            eventAttributes:self.eventAttributes
                                                                  eventType:EventTypeCustom]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:self.completionBlock]);
}

- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
            [builder setUrl:@"https://www.emarsys.com"];
        }                 timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end
