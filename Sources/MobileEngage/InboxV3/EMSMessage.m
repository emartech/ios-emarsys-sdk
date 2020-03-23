//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSMessage.h"

@implementation EMSMessage

- (instancetype)initWithId:(NSString *)id
            multichannelId:(nullable NSNumber *)multichannelId
                campaignId:(nullable NSString *)campaignId
                     title:(NSString *)title
                      body:(NSString *)body
                  imageUrl:(nullable NSString *)imageUrl
                    action:(nullable NSString *)action
                receivedAt:(NSNumber *)receivedAt
                 updatedAt:(nullable NSNumber *)updatedAt
                       ttl:(nullable NSNumber *)ttl
                      tags:(nullable NSArray<NSString *> *)tags
                  sourceId:(NSNumber *)sourceId
               sourceRunId:(nullable NSString *)sourceRunId
                sourceType:(NSString *)sourceType {
    if (self = [super init]) {
        _id = id;
        _multichannelId = multichannelId;
        _campaignId = campaignId;
        _title = title;
        _body = body;
        _imageUrl = imageUrl;
        _action = action;
        _receivedAt = receivedAt;
        _updatedAt = updatedAt;
        _ttl = ttl;
        _tags = tags;
        _sourceId = sourceId;
        _sourceRunId = sourceRunId;
        _sourceType = sourceType;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToMessage:other];
}

- (BOOL)isEqualToMessage:(EMSMessage *)message {
    if (self == message)
        return YES;
    if (message == nil)
        return NO;
    if (self.id != message.id && ![self.id isEqualToString:message.id])
        return NO;
    if (self.multichannelId != message.multichannelId && ![self.multichannelId isEqualToNumber:message.multichannelId])
        return NO;
    if (self.campaignId != message.campaignId && ![self.campaignId isEqualToString:message.campaignId])
        return NO;
    if (self.title != message.title && ![self.title isEqualToString:message.title])
        return NO;
    if (self.body != message.body && ![self.body isEqualToString:message.body])
        return NO;
    if (self.imageUrl != message.imageUrl && ![self.imageUrl isEqualToString:message.imageUrl])
        return NO;
    if (self.action != message.action && ![self.action isEqualToString:message.action])
        return NO;
    if (self.receivedAt != message.receivedAt && ![self.receivedAt isEqualToNumber:message.receivedAt])
        return NO;
    if (self.updatedAt != message.updatedAt && ![self.updatedAt isEqualToNumber:message.updatedAt])
        return NO;
    if (self.ttl != message.ttl && ![self.ttl isEqualToNumber:message.ttl])
        return NO;
    if (self.tags != message.tags && ![self.tags isEqualToArray:message.tags])
        return NO;
    if (self.sourceId != message.sourceId && ![self.sourceId isEqualToNumber:message.sourceId])
        return NO;
    if (self.sourceRunId != message.sourceRunId && ![self.sourceRunId isEqualToString:message.sourceRunId])
        return NO;
    if (self.sourceType != message.sourceType && ![self.sourceType isEqualToString:message.sourceType])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.multichannelId hash];
    hash = hash * 31u + [self.campaignId hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.body hash];
    hash = hash * 31u + [self.imageUrl hash];
    hash = hash * 31u + [self.action hash];
    hash = hash * 31u + [self.receivedAt hash];
    hash = hash * 31u + [self.updatedAt hash];
    hash = hash * 31u + [self.ttl hash];
    hash = hash * 31u + [self.tags hash];
    hash = hash * 31u + [self.sourceId hash];
    hash = hash * 31u + [self.sourceRunId hash];
    hash = hash * 31u + [self.sourceType hash];
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ",
                                                                     NSStringFromClass([self class])];
    [description appendFormat:@"self.id=%@",
                              self.id];
    [description appendFormat:@", self.multichannelId=%@",
                              self.multichannelId];
    [description appendFormat:@", self.campaignId=%@",
                              self.campaignId];
    [description appendFormat:@", self.title=%@",
                              self.title];
    [description appendFormat:@", self.body=%@",
                              self.body];
    [description appendFormat:@", self.imageUrl=%@",
                              self.imageUrl];
    [description appendFormat:@", self.action=%@",
                              self.action];
    [description appendFormat:@", self.receivedAt=%@",
                              self.receivedAt];
    [description appendFormat:@", self.updatedAt=%@",
                              self.updatedAt];
    [description appendFormat:@", self.ttl=%@",
                              self.ttl];
    [description appendFormat:@", self.tags=%@",
                              self.tags];
    [description appendFormat:@", self.sourceId=%@",
                              self.sourceId];
    [description appendFormat:@", self.sourceRunId=%@",
                              self.sourceRunId];
    [description appendFormat:@", self.sourceType=%@",
                              self.sourceType];
    [description appendString:@">"];
    return description;
}

@end