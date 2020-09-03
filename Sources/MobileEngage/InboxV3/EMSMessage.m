//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import "EMSMessage.h"

@implementation EMSMessage

- (instancetype)initWithId:(NSString *)id
                campaignId:(NSString *)campaignId
                collapseId:(nullable NSString *)collapseId
                     title:(NSString *)title
                      body:(NSString *)body
                  imageUrl:(nullable NSString *)imageUrl
                receivedAt:(NSNumber *)receivedAt
                 updatedAt:(nullable NSNumber *)updatedAt
                 expiresAt:(nullable NSNumber *)expiresAt
                      tags:(nullable NSArray<NSString *> *)tags
                properties:(nullable NSDictionary<NSString *, NSString *> *)properties {
    if (self = [super init]) {
        _id = id;
        _campaignId = campaignId;
        _collapseId = collapseId;
        _title = title;
        _body = body;
        _imageUrl = imageUrl;
        _receivedAt = receivedAt;
        _updatedAt = updatedAt;
        _expiresAt = expiresAt;
        _tags = tags;
        _properties = properties;
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
    if (self.campaignId != message.campaignId && ![self.campaignId isEqualToString:message.campaignId])
        return NO;
    if (self.collapseId != message.collapseId && ![self.collapseId isEqualToString:message.collapseId])
        return NO;
    if (self.title != message.title && ![self.title isEqualToString:message.title])
        return NO;
    if (self.body != message.body && ![self.body isEqualToString:message.body])
        return NO;
    if (self.imageUrl != message.imageUrl && ![self.imageUrl isEqualToString:message.imageUrl])
        return NO;
    if (self.receivedAt != message.receivedAt && ![self.receivedAt isEqualToNumber:message.receivedAt])
        return NO;
    if (self.updatedAt != message.updatedAt && ![self.updatedAt isEqualToNumber:message.updatedAt])
        return NO;
    if (self.expiresAt != message.expiresAt && ![self.expiresAt isEqualToNumber:message.expiresAt])
        return NO;
    if (self.tags != message.tags && ![self.tags isEqualToArray:message.tags])
        return NO;
    if (self.properties != message.properties && ![self.properties isEqualToDictionary:message.properties])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.campaignId hash];
    hash = hash * 31u + [self.collapseId hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.body hash];
    hash = hash * 31u + [self.imageUrl hash];
    hash = hash * 31u + [self.receivedAt hash];
    hash = hash * 31u + [self.updatedAt hash];
    hash = hash * 31u + [self.expiresAt hash];
    hash = hash * 31u + [self.tags hash];
    hash = hash * 31u + [self.properties hash];
    return hash;
}

@end