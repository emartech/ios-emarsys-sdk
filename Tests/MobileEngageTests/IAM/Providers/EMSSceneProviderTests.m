//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSSceneProvider.h"

@interface EMSSceneProviderTests : XCTestCase

@end

@implementation EMSSceneProviderTests

- (void)testInit_application_mustNotBeNil {
    @try {
        [[EMSSceneProvider alloc] initWithApplication:nil];
        XCTFail(@"Expected Exception when application is nil!");
    } @catch (NSException *exception) {
        XCTAssertEqualObjects(exception.reason, @"Invalid parameter not satisfying: application");
    }
}

- (void)testProvideScene_active {
    if (@available(iOS 13.0, *)) {
        UIApplication *mockApplication = OCMClassMock([UIApplication class]);
        UIScene *mockScene1 = OCMClassMock([UIScene class]);
        UIScene *mockScene2 = OCMClassMock([UIScene class]);

        NSSet *connectedScenes = [NSSet setWithArray:@[mockScene1, mockScene2]];

        OCMStub([mockScene1 activationState]).andReturn(UISceneActivationStateForegroundActive);
        OCMStub([mockScene2 activationState]).andReturn(UISceneActivationStateBackground);
        OCMStub([mockApplication connectedScenes]).andReturn(connectedScenes);

        EMSSceneProvider *provider = [[EMSSceneProvider alloc] initWithApplication:mockApplication];

        UIScene *result = [provider provideScene];

        XCTAssertEqualObjects(result, mockScene1);
    } else {
        EMSSceneProvider *provider = [[EMSSceneProvider alloc] initWithApplication:[UIApplication sharedApplication]];

        UIScene *result = [provider provideScene];

        XCTAssertNil(result);
    }
}

- (void)testProvideScene_inactive {
    if (@available(iOS 13.0, *)) {
        UIApplication *mockApplication = OCMClassMock([UIApplication class]);
        UIScene *mockScene1 = OCMClassMock([UIScene class]);
        UIScene *mockScene2 = OCMClassMock([UIScene class]);

        NSSet *connectedScenes = [NSSet setWithArray:@[mockScene1, mockScene2]];

        OCMStub([mockScene1 activationState]).andReturn(UISceneActivationStateForegroundInactive);
        OCMStub([mockScene2 activationState]).andReturn(UISceneActivationStateBackground);
        OCMStub([mockApplication connectedScenes]).andReturn(connectedScenes);

        EMSSceneProvider *provider = [[EMSSceneProvider alloc] initWithApplication:mockApplication];

        UIScene *result = [provider provideScene];

        XCTAssertEqualObjects(result, mockScene1);
    } else {
        EMSSceneProvider *provider = [[EMSSceneProvider alloc] initWithApplication:[UIApplication sharedApplication]];

        UIScene *result = [provider provideScene];

        XCTAssertNil(result);
    }
}

@end
