//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInboxResultParser.h"
#import "EMSResponseModel.h"
#import "EMSInboxResult.h"
#import "EMSDictionaryValidator.h"
#import "NSDictionary+EMSCore.h"
#import "EMSAppEventActionModel.h"
#import "EMSOpenExternalUrlActionModel.h"
#import "EMSCustomEventActionModel.h"
#import "EMSDismissActionModel.h"

@implementation EMSInboxResultParser

- (EMSInboxResult *)parseFromResponse:(EMSResponseModel *)response {
    NSDictionary *body = response.parsedBody;
    EMSInboxResult *result = [EMSInboxResult new];
    if (body) {
        NSArray *errors = [body validate:^(EMSDictionaryValidator *validate) {
            [validate valueExistsForKey:@"messages"
                               withType:[NSArray class]];
        }];
        if ([errors count] == 0) {
            NSArray *messages = body[@"messages"];
            NSMutableArray *resultMessages = [NSMutableArray new];
            for (NSDictionary *messageDict in messages) {
                NSArray *messageErrors = [messageDict validate:^(EMSDictionaryValidator *validate) {
                    [validate valueExistsForKey:@"id"
                                       withType:[NSString class]];
                    [validate valueExistsForKey:@"campaignId"
                                       withType:[NSString class]];
                    [validate valueExistsForKey:@"title"
                                       withType:[NSString class]];
                    [validate valueExistsForKey:@"body"
                                       withType:[NSString class]];
                    [validate valueExistsForKey:@"receivedAt"
                                       withType:[NSNumber class]];
                }];
                if ([messageErrors count] == 0) {
                    NSMutableArray<id <EMSActionModelProtocol>> *mutableActions = nil;
                    id actions = [messageDict nullSafeValueForKey:@"actions"];
                    if (actions && [actions isKindOfClass:[NSArray class]] && [actions count] > 0) {
                        mutableActions = [NSMutableArray array];
                        for (NSDictionary *actionDictionary in actions) {
                            id <EMSActionModelProtocol> action = [self createActionFromDictionary:actionDictionary];
                            if (action) {
                                [mutableActions addObject:action];
                            }
                        }
                    }
                    EMSMessage *message = [[EMSMessage alloc] initWithId:[messageDict nullSafeValueForKey:@"id"]
                                                              campaignId:[messageDict nullSafeValueForKey:@"campaignId"]
                                                              collapseId:[messageDict nullSafeValueForKey:@"collapseId"]
                                                                   title:[messageDict nullSafeValueForKey:@"title"]
                                                                    body:[messageDict nullSafeValueForKey:@"body"]
                                                                imageUrl:[messageDict nullSafeValueForKey:@"imageUrl"]
                                                              receivedAt:[messageDict nullSafeValueForKey:@"receivedAt"]
                                                               updatedAt:[messageDict nullSafeValueForKey:@"updatedAt"]
                                                               expiresAt:[messageDict nullSafeValueForKey:@"expiresAt"]
                                                                    tags:[messageDict nullSafeValueForKey:@"tags"]
                                                              properties:[messageDict nullSafeValueForKey:@"properties"]
                                                                 actions:mutableActions ? [NSArray arrayWithArray:mutableActions] : nil];
                    [resultMessages addObject:message];
                }
            }
            [result setMessages:resultMessages];
        }


    }
    return result;
}

- (id <EMSActionModelProtocol>)createActionFromDictionary:(NSDictionary *)actionDictionary {
    id <EMSActionModelProtocol> action = nil;
    if ([actionDictionary[@"type"] isEqualToString:@"MEAppEvent"]) {
        action = [[EMSAppEventActionModel alloc] initWithId:actionDictionary[@"id"]
                                                      title:actionDictionary[@"title"]
                                                       type:actionDictionary[@"type"]
                                                       name:actionDictionary[@"name"]
                                                    payload:actionDictionary[@"payload"]];
    } else if ([actionDictionary[@"type"] isEqualToString:@"OpenExternalUrl"]) {
        action = [[EMSOpenExternalUrlActionModel alloc] initWithId:actionDictionary[@"id"]
                                                             title:actionDictionary[@"title"]
                                                              type:actionDictionary[@"type"]
                                                               url:actionDictionary[@"url"] ? [[NSURL alloc] initWithString:actionDictionary[@"url"]] : nil];
    } else if ([actionDictionary[@"type"] isEqualToString:@"MECustomEvent"]) {
        action = [[EMSCustomEventActionModel alloc] initWithId:actionDictionary[@"id"]
                                                         title:actionDictionary[@"title"]
                                                          type:actionDictionary[@"type"]
                                                          name:actionDictionary[@"name"]
                                                       payload:actionDictionary[@"payload"]];
    } else if ([actionDictionary[@"type"] isEqualToString:@"Dismiss"]) {
        action = [[EMSDismissActionModel alloc] initWithId:actionDictionary[@"id"]
                                                     title:actionDictionary[@"title"]
                                                      type:actionDictionary[@"type"]];
    }
    return action;
}

@end