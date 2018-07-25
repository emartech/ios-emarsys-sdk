//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSDictionaryValidator.h"
#import "MEIAMTriggerMEEvent.h"
#import "MEIAMCommandResultUtils.h"
#import "MobileEngage.h"
#import "NSDictionary+EMSCore.h"

@implementation MEIAMTriggerMEEvent

+ (NSString *)commandName {
    return @"triggerMEEvent";
}

- (void)handleMessage:(NSDictionary *)message
          resultBlock:(MEIAMJSResultBlock)resultBlock {
    NSString *eventId = message[@"id"];

    NSArray<NSString *> *errors = [message validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"name" withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId errorArray:errors]);
    } else {
        NSString *name = message[@"name"];
        NSDictionary *payload = [message dictionaryValueForKey:@"payload"];
        resultBlock(@{
                @"success": @YES,
                @"id": eventId,
                @"meEventId": [MobileEngage trackCustomEvent:name
                                             eventAttributes:payload]
        });
    }
}

@end