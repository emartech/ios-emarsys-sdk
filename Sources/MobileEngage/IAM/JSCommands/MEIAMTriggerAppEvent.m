//
//  Copyright © 2017 Emarsys. All rights reserved.
//

#import "EMSDictionaryValidator.h"
#import "MEIAMTriggerAppEvent.h"
#import "MEIAMCommandResultUtils.h"
#import "NSDictionary+EMSCore.h"

@interface MEIAMTriggerAppEvent ()

@property(nonatomic, strong, nullable) EMSEventHandlerBlock eventHandler;

@end

@implementation MEIAMTriggerAppEvent

- (instancetype)initWithEventHandler:(EMSEventHandlerBlock)eventHandler {
    if (self = [super init]) {
        _eventHandler = eventHandler;
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
        [validate valueExistsForKey:@"name"
                           withType:[NSString class]];
    }];

    if ([errors count] > 0) {
        resultBlock([MEIAMCommandResultUtils createErrorResultWith:eventId
                                                        errorArray:errors]);
    } else {
        NSString *name = message[@"name"];
        NSDictionary *payload = [message dictionaryValueForKey:@"payload"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.eventHandler(name, payload);
        });
        resultBlock([MEIAMCommandResultUtils createSuccessResultWith:eventId]);
    }
}

@end
