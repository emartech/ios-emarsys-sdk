//
//  Copyright © 2020 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSGeofenceMapper.h"
#import "EMSRequestModel.h"
#import "EMSResponseModel.h"
#import "EMSGeofenceResponse.h"
#import "EMSGeofenceGroup.h"
#import "EMSGeofence.h"
#import "EMSGeofenceTrigger.h"

@interface EMSGeofenceMapperTests : XCTestCase

@property(nonatomic, strong) EMSGeofenceMapper *mapper;

@property(nonatomic, copy) NSString *jsonString;
@end

@implementation EMSGeofenceMapperTests

- (void)setUp {
    _mapper = [[EMSGeofenceMapper alloc] init];
    _jsonString = [self createJSONStringFromDict:[self createGeofenceDict]];
}

- (void)testMapFromResponseModel_whenSuccess {
    EMSResponseModel *responseModel = [self createResponse];

    EMSGeofenceResponse *expected = [self createExpectedResponse];

    EMSGeofenceResponse *result = [self.mapper mapFromResponseModel:responseModel];

    XCTAssertEqualObjects(result, expected);
}

- (void)testMapFromResponseModel_whenBodyIsEmpty {
    _jsonString = @"";
    EMSResponseModel *responseModel = [self createResponse];

    EMSGeofenceResponse *result = [self.mapper mapFromResponseModel:responseModel];

    XCTAssertNil(result);
}

- (void)testMapFromResponseModel_whenTriggerTypeIsInvalid {
    EMSGeofenceResponse *expected = [self createExpectedResponse];
    NSMutableArray *mutableTriggers = [expected.groups.firstObject.geofences.firstObject.triggers mutableCopy];
    [mutableTriggers removeObjectAtIndex:0];
    expected.groups.firstObject.geofences.firstObject.triggers = [NSArray arrayWithArray:mutableTriggers];

    NSDictionary *geofenceDict = [self createGeofenceDictWithType:@"TEST_WRONG_TYPE"];

    _jsonString = [self createJSONStringFromDict:[NSDictionary dictionaryWithDictionary:geofenceDict]];

    EMSResponseModel *responseModel = [self createResponse];

    EMSGeofenceResponse *result = [self.mapper mapFromResponseModel:responseModel];

    XCTAssertEqualObjects(result, expected);
}

- (void)testMapFromResponseModel_whenLoiteringDelayIsMissing {
    EMSGeofenceResponse *expected = [self createExpectedResponse];
    NSMutableArray *mutableTriggers = [expected.groups.firstObject.geofences.firstObject.triggers mutableCopy];
    [mutableTriggers removeObjectAtIndex:0];
    expected.groups.firstObject.geofences.firstObject.triggers = [NSArray arrayWithArray:mutableTriggers];

    NSDictionary *geofenceDict = [self createGeofenceDictWithType:@"DWELLING"
                                                   loiteringDelay:nil];

    _jsonString = [self createJSONStringFromDict:[NSDictionary dictionaryWithDictionary:geofenceDict]];

    EMSResponseModel *responseModel = [self createResponse];

    EMSGeofenceResponse *result = [self.mapper mapFromResponseModel:responseModel];

    XCTAssertEqualObjects(result, expected);
}

- (void)testMapFromResponseModel_whenNoGeofences {
    NSDictionary *geofenceDict = [self createGeofenceDictWithoutGeofences];

    _jsonString = [self createJSONStringFromDict:[NSDictionary dictionaryWithDictionary:geofenceDict]];

    EMSResponseModel *responseModel = [self createResponse];

    EMSGeofenceResponse *result = [self.mapper mapFromResponseModel:responseModel];

    XCTAssertNil(result);
}

- (EMSResponseModel *)createResponse {
    return [[EMSResponseModel alloc] initWithHttpUrlResponse:[[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] initWithString:@"https://www.emarsys.com"]
                                                                                         statusCode:200
                                                                                        HTTPVersion:nil
                                                                                       headerFields:@{@"responseHeaderKey": @"responseHeaderValue"}]
                                                        data:[self.jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                requestModel:OCMClassMock([EMSRequestModel class])
                                                   timestamp:[NSDate date]];
}

- (NSDictionary *)createGeofenceDictWithoutGeofences {
    return @{
            @"refreshRadiusRatio": @(0.3),
            @"groups": @[
                    @{
                            @"id": @"geoGroupId1",
                            @"waitInterval": @(20.0),
                            @"geofences": @[

                    ]
                    }
            ]
    };
}

- (NSDictionary *)createGeofenceDictWithType:(NSString *)type
                              loiteringDelay:(NSNumber *)loiteringDelay {
    NSMutableDictionary *mutableTriggerDict = [@{
            @"id": @"triggerId1",
            @"type": type,
            @"action": @{
                    @"id": @"testActionId1",
                    @"title": @"Custom event",
                    @"type": @"MECustomEvent",
                    @"name": @"nameValue",
                    @"payload": @{
                            @"someKey": @"someValue"
                    }
            }
    } mutableCopy];
    mutableTriggerDict[@"loiteringDelay"] = loiteringDelay;
    return @{
            @"refreshRadiusRatio": @(0.3),
            @"groups": @[
                    @{
                            @"id": @"geoGroupId1",
                            @"waitInterval": @(20.0),
                            @"geofences": @[
                            @{
                                    @"id": @"geofenceId1",
                                    @"lat": @(34.5),
                                    @"lon": @(12.789),
                                    @"r": @(5),
                                    @"waitInterval": @(30.0),
                                    @"triggers": @[
                                    [NSDictionary dictionaryWithDictionary:mutableTriggerDict],
                                    @{
                                            @"id": @"triggerId2",
                                            @"type": @"ENTER",
                                            @"loiteringDelay": @(13),
                                            @"action": @{
                                            @"id": @"testActionId2",
                                            @"title": @"Custom event",
                                            @"type": @"MECustomEvent",
                                            @"name": @"nameValue",
                                            @"payload": @{
                                                    @"someKey": @"someValue"
                                            }
                                    }
                                    }
                            ]
                            }
                    ]
                    }
            ]
    };
}

- (NSDictionary *)createGeofenceDictWithType:(NSString *)type {
    return [self createGeofenceDictWithType:type
                             loiteringDelay:@7];
}

- (NSDictionary *)createGeofenceDict {
    return [self createGeofenceDictWithType:@"ENTER"];
}

- (NSString *)createJSONStringFromDict:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict
                                                                          options:0
                                                                            error:nil]
                                 encoding:NSUTF8StringEncoding];
}

- (EMSGeofenceResponse *)createExpectedResponse {
    return [[EMSGeofenceResponse alloc] initWithGroups:@[[[EMSGeofenceGroup alloc] initWithId:@"geoGroupId1"
                                                                                 waitInterval:20
                                                                                    geofences:@[[[EMSGeofence alloc] initWithId:@"geofenceId1"
                                                                                                                            lat:34.5
                                                                                                                            lon:12.789
                                                                                                                              r:5
                                                                                                                   waitInterval:30
                                                                                                                       triggers:@[[[EMSGeofenceTrigger alloc] initWithId:@"triggerId1"
                                                                                                                                                                    type:@"ENTER"
                                                                                                                                                          loiteringDelay:7
                                                                                                                                                                  action:@{@"id": @"testActionId1",
                                                                                                                                                                          @"title": @"Custom event",
                                                                                                                                                                          @"type": @"MECustomEvent",
                                                                                                                                                                          @"name": @"nameValue",
                                                                                                                                                                          @"payload": @{
                                                                                                                                                                                  @"someKey": @"someValue"
                                                                                                                                                                          }}],
                                                                                                                               [[EMSGeofenceTrigger alloc] initWithId:@"triggerId2"
                                                                                                                                                                 type:@"ENTER"
                                                                                                                                                       loiteringDelay:13
                                                                                                                                                               action:@{@"id": @"testActionId2",
                                                                                                                                                                       @"title": @"Custom event",
                                                                                                                                                                       @"type": @"MECustomEvent",
                                                                                                                                                                       @"name": @"nameValue",
                                                                                                                                                                       @"payload": @{
                                                                                                                                                                               @"someKey": @"someValue"
                                                                                                                                                                       }}]
                                                                                                                       ]]]]]
                                    refreshRadiusRatio:0.3];
}

@end
