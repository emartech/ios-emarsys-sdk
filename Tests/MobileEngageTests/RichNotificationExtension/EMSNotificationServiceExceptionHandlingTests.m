//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSNotificationService.h"
#import "MEDownloader.h"

@interface EMSNotificationServiceExceptionHandlingTests : XCTestCase

@end

@implementation EMSNotificationServiceExceptionHandlingTests

- (void)testDidReceiveNotificationRequest {
    NSException *expectedException = [NSException exceptionWithName:@"TESTDownloaderInitializationException"
                                                             reason:@"TESTDownloaderInitializationException"
                                                           userInfo:nil];
    id downloaderMock = OCMClassMock([MEDownloader class]);
    OCMStub(ClassMethod([downloaderMock new])).andThrow(expectedException);
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notificationRequestId"
                                                                          content:[UNNotificationContent new]
                                                                          trigger:nil];
    __block UNNotificationContent *returnedContent = nil;

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"waitForContent"];
    [[[EMSNotificationService alloc] init] didReceiveNotificationRequest:request
                                                      withContentHandler:^(UNNotificationContent *contentToDeliver) {
                                                          returnedContent = contentToDeliver;
                                                          [expectation fulfill];
                                                      }];
    [XCTWaiter waitForExpectations:@[expectation]
                           timeout:20];
    NSException *caughtException = returnedContent.userInfo[@"exception"];
    XCTAssertEqualObjects(caughtException.userInfo[@"exception"], expectedException);

    [downloaderMock stopMocking];
}

@end
