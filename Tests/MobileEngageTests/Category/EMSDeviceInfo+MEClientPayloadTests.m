//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <UserNotifications/UserNotifications.h>
#import <AdSupport/AdSupport.h>
#import "EMSDeviceInfo+MEClientPayload.h"
#import "EMSStorage.h"
#import "EMSUUIDProvider.h"
#import "XCTestCase+Helper.h"

@interface EMSDeviceInfo_MEClientPayloadTests : XCTestCase

@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation EMSDeviceInfo_MEClientPayloadTests

- (void)testClientPayload {
    NSOperationQueue *queue = [self createTestOperationQueue];
    EMSDeviceInfo *deviceInfo = [[EMSDeviceInfo alloc] initWithSDKVersion:@"testSDKVersion"
                                                       notificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                  storage:[[EMSStorage alloc] initWithSuiteNames:@[]
                                                                                                     accessGroup:nil
                                                                                                  operationQueue:queue]
                                                             uuidProvider:[EMSUUIDProvider new]];
    
    EMSDeviceInfo *partialMockDeviceInfo = OCMPartialMock(deviceInfo);
    
    NSDictionary *pushSettings = @{
        @"pushSettingKey1": @"pushSettingValue1",
        @"pushSettingKey2": @"pushSettingValue2"
    };
    
    OCMStub([partialMockDeviceInfo pushSettings]).andReturn(pushSettings);
    
    NSDictionary *expectedDictionary = @{
        @"platform": deviceInfo.platform,
        @"applicationVersion": deviceInfo.applicationVersion,
        @"deviceModel": deviceInfo.deviceModel,
        @"osVersion": deviceInfo.osVersion,
        @"sdkVersion": deviceInfo.sdkVersion,
        @"language": deviceInfo.languageCode,
        @"timezone": deviceInfo.timeZone,
        @"pushSettings": @{
            @"pushSettingKey1": @"pushSettingValue1",
            @"pushSettingKey2": @"pushSettingValue2"
        }
    };
    
    NSDictionary *clientPayload = partialMockDeviceInfo.clientPayload;
    
    XCTAssertEqualObjects(clientPayload, expectedDictionary);
}

@end
