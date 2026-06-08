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
                    id ems = [messageDict nullSafeValueForKey:@"ems"];
                    id actions = [ems nullSafeValueForKey:@"actions"];
                    if (actions && [actions isKindOfClass:[NSArray class]] && [actions count] > 0) {
                        for (NSDictionary *actionDictionary in actions) {
                            id <EMSActionModelProtocol> action = [self createActionFromDictionary:actionDictionary];
                            if (action) {
                                if (!mutableActions) mutableActions = [NSMutableArray array];
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
                                                            imageAltText:[messageDict nullSafeValueForKey:@"imageAltText"]
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
    if (![actionDictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *actionId = [actionDictionary stringValueForKey:@"id"];
    NSString *title = [actionDictionary stringValueForKey:@"title"];
    NSString *type = [actionDictionary stringValueForKey:@"type"];
    if (!actionId || !title || !type) {
        return nil;
    }
    id <EMSActionModelProtocol> action = nil;
    if ([type isEqualToString:@"MEAppEvent"]) {
        NSString *name = [actionDictionary stringValueForKey:@"name"];
        if (!name) {
            return nil;
        }
        action = [[EMSAppEventActionModel alloc] initWithId:actionId
                                                      title:title
                                                       type:type
                                                       name:name
                                                    payload:actionDictionary[@"payload"]];
    } else if ([type isEqualToString:@"OpenExternalUrl"]) {
        NSString *urlString = [actionDictionary stringValueForKey:@"url"];
        if (!urlString) {
            return nil;
        }
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        if (!url || !url.scheme) {
            return nil;
        }
        action = [[EMSOpenExternalUrlActionModel alloc] initWithId:actionId
                                                             title:title
                                                              type:type
                                                               url:url];
    } else if ([type isEqualToString:@"MECustomEvent"]) {
        NSString *name = [actionDictionary stringValueForKey:@"name"];
        if (!name) {
            return nil;
        }
        action = [[EMSCustomEventActionModel alloc] initWithId:actionId
                                                         title:title
                                                          type:type
                                                          name:name
                                                       payload:actionDictionary[@"payload"]];
    } else if ([type isEqualToString:@"Dismiss"]) {
        action = [[EMSDismissActionModel alloc] initWithId:actionId
                                                     title:title
                                                      type:type];
    }
    return action;
}

@end
