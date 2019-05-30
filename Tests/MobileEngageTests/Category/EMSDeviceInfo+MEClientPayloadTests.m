//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UserNotifications/UserNotifications.h>
#import "EMSDeviceInfo+MEClientPayload.h"

@interface EMSDeviceInfo_MEClientPayloadTests : XCTestCase

@end

@implementation EMSDeviceInfo_MEClientPayloadTests

- (void)testClientPayload {
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"testSDKVersion"
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]];
    NSDictionary *expectedDictionary = @{
        @"platform": deviceInfo.platform,
        @"applicationVersion": deviceInfo.applicationVersion,
        @"deviceModel": deviceInfo.deviceModel,
        @"osVersion": deviceInfo.osVersion,
        @"sdkVersion": deviceInfo.sdkVersion,
        @"language": deviceInfo.languageCode,
        @"timezone": deviceInfo.timeZone
    };

    XCTAssertEqualObjects(deviceInfo.clientPayload, expectedDictionary);
}

@end
