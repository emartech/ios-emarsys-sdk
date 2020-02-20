//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSActionFactory.h"
#import "EMSActionProtocol.h"
#import "EMSDictionaryValidator.h"
#import "EMSBadgeCountAction.h"
#import "EMSAppEventAction.h"
#import "EMSOpenExternalUrlAction.h"
#import "EMSMobileEngageProtocol.h"
#import "EMSCustomEventAction.h"

@interface EMSActionFactory ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, weak) id <EMSMobileEngageProtocol> mobileEngage;

@end

@implementation EMSActionFactory

- (instancetype)initWithApplication:(UIApplication *)application
                       mobileEngage:(id <EMSMobileEngageProtocol>)mobileEngage {
    NSParameterAssert(application);
    NSParameterAssert(mobileEngage);
    if (self = [super init]) {
        _application = application;
        _mobileEngage = mobileEngage;
    }
    return self;
}

- (id <EMSActionProtocol>)createActionWithActionDictionary:(NSDictionary<NSString *, id> *)action {
    NSObject <EMSActionProtocol> *result = nil;
    NSArray *errors = [action validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"type" withType:[NSString class]];
    }];

    if ([errors count] == 0) {
        NSString *actionType = action[@"type"];
        if ([actionType isEqualToString:@"BadgeCount"]) {
            NSArray *badgeErrors = [action validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"method" withType:[NSString class]];
                [validate valueExistsForKey:@"value" withType:[NSNumber class]];
            }];
            result = [badgeErrors count] == 0 ? [[EMSBadgeCountAction alloc] initWithActionDictionary:action
                                                                                          application:self.application] : nil;
        } else if ([actionType isEqualToString:@"MEAppEvent"]) {
            NSArray *appEventErrors = [action validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"name" withType:[NSString class]];
            }];
            result = [appEventErrors count] == 0 && self.eventHandler ? [[EMSAppEventAction alloc] initWithActionDictionary:action
                                                                                                               eventHandler:self.eventHandler] : nil;
        } else if ([actionType isEqualToString:@"OpenExternalUrl"]) {
            NSArray *openUrlErrors = [action validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"url" withType:[NSString class]];
            }];
            result = [openUrlErrors count] == 0 ? [[EMSOpenExternalUrlAction alloc] initWithActionDictionary:action
                                                                                                 application:self.application] : nil;
        } else if ([actionType isEqualToString:@"MECustomEvent"]) {
            NSArray *customEventErrors = [action validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"name" withType:[NSString class]];
            }];
            result = [customEventErrors count] == 0 ? [[EMSCustomEventAction alloc] initWithAction:action
                                                                                      mobileEngage:self.mobileEngage] : nil;
        }
    }
    return result;
}

@end
