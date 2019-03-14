//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSMobileEngageV3Internal.h"
#import "EMSRequestFactory.h"
#import "EMSRequestManager.h"
#import "EMSRequestModel.h"
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

@end

@implementation EMSMobileEngageV3InternalTests

- (void)setUp {
    _timestampProvider = [EMSTimestampProvider new];
    _uuidProvider = [EMSUUIDProvider new];

    _contactFieldValue = @"testContactFieldValue";
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

- (void)testSetContactWithContactFieldValue_contactFieldValue_mustNotBeNil {
    @try {
        [self.internal setContactWithContactFieldValue:nil];
        XCTFail(@"Expected Exception when contactFieldValue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: contactFieldValue");
    }
}

- (void)testSetContactWithContactFieldValueCompletionBlock_contactFieldValue_mustNotBeNil {
    @try {
        [self.internal setContactWithContactFieldValue:nil
                                       completionBlock:^(NSError *error) {
                                       }];
        XCTFail(@"Expected Exception when contactFieldValue is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: contactFieldValue");
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
    void (^completionBlock)(NSError *) = ^(NSError *error) {
    };
    NSNumber *contactFieldId = @3;

    OCMStub([self.mockRequestContext contactFieldId]).andReturn(contactFieldId);
    OCMStub([self.mockRequestFactory createContactRequestModel]).andReturn(requestModel);

    [self.internal setContactWithContactFieldValue:self.contactFieldValue
                                   completionBlock:completionBlock];

    OCMVerify([self.mockRequestContext contactFieldId]);
    OCMVerify([self.mockRequestContext setAppLoginParameters:[[MEAppLoginParameters alloc] initWithContactFieldId:contactFieldId
                                                                                                contactFieldValue:self.contactFieldValue]]);
    OCMVerify([self.mockRequestFactory createContactRequestModel]);
    OCMVerify([self.mockRequestManager submitRequestModel:requestModel
                                      withCompletionBlock:completionBlock]);
}

- (EMSRequestModel *)createRequestModel {
    return [EMSRequestModel makeWithBuilder:^(EMSRequestModelBuilder *builder) {
                [builder setUrl:@"https://www.emarsys.com"];
            }             timestampProvider:self.timestampProvider
                               uuidProvider:self.uuidProvider];
}

@end
