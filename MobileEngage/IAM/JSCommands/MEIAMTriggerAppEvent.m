//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "EMSDictionaryValidator.h"
#import "MEIAMTriggerAppEvent.h"
#import "EMSEventHandler.h"
#import "MEIAMCommandResultUtils.h"
#import "NSDictionary+EMSCore.h"

@interface MEIAMTriggerAppEvent()

@property(nonatomic, weak, nullable) id <EMSEventHandler> inAppMessageHandler;

@end

@implementation MEIAMTriggerAppEvent

- (instancetype)initWithInAppMessageHandler:(id <EMSEventHandler>)inAppMessageHandler {
    if (self = [super init]) {
        _inAppMessageHandler = inAppMessageHandler;
    }
    return self;
}


+ (NSString *)commandName {
    return @"triggerAppEvent";
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
        [self.inAppMessageHandler handleEvent:name
                                      payload:payload];
        resultBlock([MEIAMCommandResultUtils createSuccessResultWith:eventId]);
    }
}

@end
