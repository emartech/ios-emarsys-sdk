//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInboxResultParser.h"
#import "EMSResponseModel.h"
#import "EMSInboxResult.h"
#import "EMSDictionaryValidator.h"
#import "NSDictionary+EMSCore.h"

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
                    [validate valueExistsForKey:@"title"
                                       withType:[NSString class]];
                    [validate valueExistsForKey:@"body"
                                       withType:[NSString class]];
                    [validate valueExistsForKey:@"receivedAt"
                                       withType:[NSNumber class]];
                }];
                if ([messageErrors count] == 0) {
                    EMSMessage *message = [[EMSMessage alloc] initWithId:[messageDict nullSafeValueForKey:@"id"]
                                                                   title:[messageDict nullSafeValueForKey:@"title"]
                                                                    body:[messageDict nullSafeValueForKey:@"body"]
                                                                imageUrl:[messageDict nullSafeValueForKey:@"imageUrl"]
                                                              receivedAt:[messageDict nullSafeValueForKey:@"receivedAt"]
                                                               updatedAt:[messageDict nullSafeValueForKey:@"updatedAt"]
                                                                     ttl:[messageDict nullSafeValueForKey:@"ttl"]
                                                                    tags:[messageDict nullSafeValueForKey:@"tags"]
                                                              properties:[messageDict nullSafeValueForKey:@"properties"]];
                    [resultMessages addObject:message];
                }
            }
            [result setMessages:resultMessages];
        }


    }
    return result;
}

@end