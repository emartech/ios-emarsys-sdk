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

- (void)testProvideScene {
    if (@available(iOS 13.0, *)) {
        UIApplication *mockApplication = OCMClassMock([UIApplication class]);
        UIScene *mockScene1 = OCMClassMock([UIScene class]);
        UIScene *mockScene2 = OCMClassMock([UIScene class]);
        UIScene *mockScene3 = OCMClassMock([UIScene class]);

        NSSet *connectedScenes = [NSSet setWithArray:@[mockScene1, mockScene2, mockScene3]];

        OCMStub([mockScene2 activationState]).andReturn(UISceneActivationStateForegroundActive);
        OCMStub([mockScene1 activationState]).andReturn(UISceneActivationStateForegroundInactive);
        OCMStub([mockScene3 activationState]).andReturn(UISceneActivationStateBackground);
        OCMStub([mockApplication connectedScenes]).andReturn(connectedScenes);

        EMSSceneProvider *provider = [[EMSSceneProvider alloc] initWithApplication:mockApplication];

        UIScene *result = [provider provideScene];

        XCTAssertEqualObjects(result, mockScene2);
    } else {
        EMSSceneProvider *provider = [[EMSSceneProvider alloc] initWithApplication:[UIApplication sharedApplication]];

        UIScene *result = [provider provideScene];

        XCTAssertNil(result);
    }
}

@end
