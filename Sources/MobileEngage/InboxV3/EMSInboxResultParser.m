//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSInboxResultParser.h"
#import "EMSResponseModel.h"
#import "EMSInboxResult.h"
#import "EMSServiceDictionaryValidator.h"

@implementation EMSInboxResultParser

- (EMSInboxResult *)parseFromResponse:(EMSResponseModel *)response {
    NSDictionary *body = response.parsedBody;
    EMSInboxResult *result = [EMSInboxResult new];
    if (body) {
        NSArray *errors = [body validateWithBlock:^(EMSServiceDictionaryValidator *validate) {
            [validate valueExistsForKey:@"messages"
                               withType:[NSArray class]];
        }];
        if ([errors count] == 0) {
            NSArray *messages = body[@"messages"];
            NSMutableArray *resultMessages = [NSMutableArray new];
            for (NSDictionary *messageDict in messages) {
                NSArray *messageErrors = [messageDict validateWithBlock:^(EMSServiceDictionaryValidator *validate) {
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
                    EMSMessage *message = [[EMSMessage alloc] initWithId:messageDict[@"id"]
                                                                   title:messageDict[@"title"]
                                                                    body:messageDict[@"body"]
                                                                imageUrl:messageDict[@"imageUrl"]
                                                              receivedAt:messageDict[@"receivedAt"]
                                                               updatedAt:messageDict[@"updatedAt"]
                                                                     ttl:messageDict[@"ttl"]
                                                                    tags:messageDict[@"tags"]
                                                              properties:messageDict[@"properties"]];
                    [resultMessages addObject:message];
                }
            }
            [result setMessages:resultMessages];
        }


    }
    return result;
}

@end