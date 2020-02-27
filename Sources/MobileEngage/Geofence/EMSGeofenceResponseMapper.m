//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSGeofenceResponseMapper.h"
#import "EMSResponseModel.h"
#import "EMSGeofenceResponse.h"
#import "EMSDictionaryValidator.h"
#import "EMSGeofenceTrigger.h"
#import "EMSGeofence.h"
#import "EMSGeofenceGroup.h"

@implementation EMSGeofenceResponseMapper

- (nullable EMSGeofenceResponse *)mapFromResponseModel:(EMSResponseModel *)responseModel {
    EMSGeofenceResponse *result = nil;
    NSDictionary *geofenceDict = [responseModel parsedBody];
    if (geofenceDict) {
        NSArray *errors = [geofenceDict validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"groups" withType:[NSArray class]];
        }];
        NSMutableArray *mutableGroups = [NSMutableArray array];
        if ([errors count] == 0) {
            NSArray *groups = geofenceDict[@"groups"];
            for (NSDictionary *groupDict in groups) {
                EMSGeofenceGroup *group = [self groupFromDict:groupDict];
                if (group) {
                    [mutableGroups addObject:group];
                }
            }
        }
        if ([mutableGroups count] > 0) {
            result = [[EMSGeofenceResponse alloc] initWithGroups:[NSArray arrayWithArray:mutableGroups]
                                              refreshRadiusRatio:[geofenceDict[@"refreshRadiusRatio"] doubleValue]];
        }
    }
    return result;
}

- (EMSGeofenceGroup *)groupFromDict:(NSDictionary *)groupDict {
    EMSGeofenceGroup *result = nil;
    NSArray *errors = [groupDict validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"id" withType:[NSString class]];
        [validate valueExistsForKey:@"geofences" withType:[NSArray class]];
    }];
    NSMutableArray *mutableGeofences = [NSMutableArray array];
    if ([errors count] == 0) {
        NSArray *geofences = groupDict[@"geofences"];
        for (NSDictionary *geoDict in geofences) {
            EMSGeofence *geofence = [self geofenceFromDict:geoDict];
            if (geofence) {
                [mutableGeofences addObject:geofence];
            }
        }
    }
    if ([mutableGeofences count] > 0) {
        result = [[EMSGeofenceGroup alloc] initWithId:groupDict[@"id"]
                                         waitInterval:[groupDict[@"waitInterval"] doubleValue]
                                            geofences:[NSArray arrayWithArray:mutableGeofences]];
    }
    return result;
}

- (EMSGeofence *)geofenceFromDict:(NSDictionary *)geofenceDict {
    EMSGeofence *result = nil;
    NSArray *errors = [geofenceDict validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"id" withType:[NSString class]];
        [validate valueExistsForKey:@"triggers" withType:[NSArray class]];
    }];
    NSMutableArray *mutableTriggers = [NSMutableArray array];
    if ([errors count] == 0) {
        NSArray *triggers = geofenceDict[@"triggers"];
        for (NSDictionary *triggerDict in triggers) {
            EMSGeofenceTrigger *trigger = [self triggerFromDict:triggerDict];
            if (trigger) {
                [mutableTriggers addObject:trigger];
            }
        }
    }
    if ([mutableTriggers count] > 0) {
        result = [[EMSGeofence alloc] initWithId:geofenceDict[@"id"]
                                             lat:[geofenceDict[@"lat"] doubleValue]
                                             lon:[geofenceDict[@"lon"] doubleValue]
                                               r:[geofenceDict[@"r"] intValue]
                                    waitInterval:[geofenceDict[@"waitInterval"] doubleValue]
                                        triggers:[NSArray arrayWithArray:mutableTriggers]];
    }
    return result;
}

- (EMSGeofenceTrigger *)triggerFromDict:(NSDictionary *)triggerDict {
    EMSGeofenceTrigger *result = nil;
    NSArray *errors = [triggerDict validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"id" withType:[NSString class]];
        [validate valueExistsForKey:@"type" withType:[NSString class]];
        [validate valueExistsForKey:@"action" withType:[NSDictionary class]];
        if ([[triggerDict[@"type"] lowercaseString] isEqualToString:@"dwelling"]) {
            [validate valueExistsForKey:@"loiteringDelay" withType:[NSNumber class]];
        }
    }];
    if ([errors count] == 0) {
        NSString *triggerType = [triggerDict[@"type"] lowercaseString];
        if ([triggerType isEqualToString:@"enter"] || [triggerType isEqualToString:@"exit"] || [triggerType isEqualToString:@"dwelling"]) {
            result = [[EMSGeofenceTrigger alloc] initWithId:triggerDict[@"id"]
                                                       type:triggerDict[@"type"]
                                             loiteringDelay:[triggerDict[@"loiteringDelay"] intValue]
                                                     action:triggerDict[@"action"]];
        }
    }
    return result;
}

@end