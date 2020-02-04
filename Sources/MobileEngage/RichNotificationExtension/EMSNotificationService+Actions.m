//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import "EMSNotificationService.h"
#import "EMSNotificationService+Actions.h"
#import "EMSDictionaryValidator.h"

@implementation EMSNotificationService (Actions)

- (void)createCategoryForContent:(UNMutableNotificationContent *)content
               completionHandler:(ActionsCompletionHandler)completionHandler {
    NSArray *actionArray = [self extractActionsFromContent:content];
    if (actionArray) {
        NSMutableArray *actions = [NSMutableArray array];
        for (NSDictionary *actionDict in actionArray) {
            UNNotificationAction *action = [self createActionFromActionDictionary:actionDict];
            if (action) {
                [actions addObject:action];
            }
        }
        if (actions && [actions count] > 0) {
            NSString *const categoryIdentifier = [NSUUID UUID].UUIDString;
            UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryIdentifier
                                                                                      actions:actions
                                                                            intentIdentifiers:@[]
                                                                                      options:0];
            if (completionHandler) {
                completionHandler(category);
                return;
            }
        }
    }

    if (completionHandler) {
        completionHandler(nil);
    }
}

- (UNNotificationAction *)createActionFromActionDictionary:(NSDictionary *)actionDictionary {
    UNNotificationAction *result;
    NSArray *commonKeyErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"id" withType:[NSString class]];
        [validate valueExistsForKey:@"title" withType:[NSString class]];
        [validate valueExistsForKey:@"type" withType:[NSString class]];
    }];
    UNNotificationActionOptions option = UNNotificationActionOptionForeground;

    if ([commonKeyErrors count] == 0) {
        NSArray *typeSpecificErrors;
        NSString *type = actionDictionary[@"type"];
        if ([type isEqualToString:@"MEAppEvent"]) {
            typeSpecificErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"name" withType:[NSString class]];
            }];
        } else if ([type isEqualToString:@"OpenExternalUrl"]) {
            typeSpecificErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"url" withType:[NSString class]];
            }];
            NSString *const urlString = actionDictionary[@"url"];
            if ([typeSpecificErrors count] == 0 && [[NSURL alloc] initWithString:urlString] == nil) {
                typeSpecificErrors = @[[NSString stringWithFormat:@"Invalid URL: %@", urlString]];
            }
        } else if ([type isEqualToString:@"MECustomEvent"]) {
            typeSpecificErrors = [actionDictionary validate:^(EMSDictionaryValidator *validate) {
                [validate valueExistsForKey:@"name" withType:[NSString class]];
            }];
        } else if ([type isEqualToString:@"Dismiss"]) {
            typeSpecificErrors = @[];
            option = UNNotificationActionOptionDestructive;
        }
        if (typeSpecificErrors && [typeSpecificErrors count] == 0) {
            result = [UNNotificationAction actionWithIdentifier:actionDictionary[@"id"]
                                                          title:actionDictionary[@"title"]
                                                        options:option];
        }
    }
    return result;
}

- (NSArray *)extractActionsFromContent:(UNMutableNotificationContent *)content {
    NSArray *actions;
    NSArray *emsErrors = [content.userInfo validate:^(EMSDictionaryValidator *validate) {
        [validate valueExistsForKey:@"ems"
                           withType:[NSDictionary class]];
    }];
    if ([emsErrors count] == 0) {
        NSDictionary *ems = content.userInfo[@"ems"];
        NSArray *actionsErrors = [ems validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"actions"
                               withType:[NSArray class]];
        }];
        if ([actionsErrors count] == 0) {
            actions = content.userInfo[@"ems"][@"actions"];
        }
    }
    return actions;
}
@end
