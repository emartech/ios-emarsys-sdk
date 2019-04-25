//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "EMSNotification.h"
#import "NSDictionary+MobileEngage.h"
#import "EMSTimestampProvider.h"

@implementation EMSNotification

- (instancetype)initWithUserInfo:(NSDictionary *)dictionary
               timestampProvider:(EMSTimestampProvider *)timestampProvider {
    if (self = [super init]) {
        _id = dictionary[@"id"];
        _sid = [dictionary messageId];

        NSObject *alert = dictionary[@"aps"][@"alert"];
        if ([alert isKindOfClass:[NSDictionary class]]) {
            _title = ((NSDictionary *) alert)[@"title"];
            _body = ((NSDictionary *) alert)[@"body"];
        } else {
            _title = (NSString *) alert;
        }

        _customData = [self customDataWithoutSid:dictionary];
        _expirationTime = @7200;
        _receivedAtTimestamp = @([[timestampProvider provideTimestamp] timeIntervalSince1970]);
    }
    return self;
}

- (instancetype)initWithNotificationDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _id = dictionary[@"id"];
        _sid = dictionary[@"sid"];
        _title = dictionary[@"title"];
        _body = dictionary[@"body"];
        _customData = dictionary[@"custom_data"];
        _rootParams = dictionary[@"root_params"];
        _expirationTime = dictionary[@"expiration_time"];
        _receivedAtTimestamp = dictionary[@"received_at"];
    }
    return self;
}

- (NSDictionary *)customDataWithoutSid:(NSDictionary *)dictionary {
    NSDictionary *u = [dictionary customData];
    NSMutableDictionary *customData = [u mutableCopy];
    [customData removeObjectForKey:@"sid"];
    return [NSDictionary dictionaryWithDictionary:customData];;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToNotification:other];
}

- (BOOL)isEqualToNotification:(EMSNotification *)notification {
    if (self == notification)
        return YES;
    if (notification == nil)
        return NO;
    if (self.id != notification.id && ![self.id isEqualToString:notification.id])
        return NO;
    if (self.sid != notification.sid && ![self.sid isEqualToString:notification.sid])
        return NO;
    if (self.title != notification.title && ![self.title isEqualToString:notification.title])
        return NO;
    if (self.body != notification.body && ![self.body isEqualToString:notification.body])
        return NO;
    if (self.customData != notification.customData && ![self.customData isEqualToDictionary:notification.customData])
        return NO;
    if (self.rootParams != notification.rootParams && ![self.rootParams isEqualToDictionary:notification.rootParams])
        return NO;
    if (self.expirationTime != notification.expirationTime && ![self.expirationTime isEqualToNumber:notification.expirationTime])
        return NO;
    if (self.receivedAtTimestamp != notification.receivedAtTimestamp && ![self.receivedAtTimestamp isEqualToNumber:notification.receivedAtTimestamp])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.id hash];
    hash = hash * 31u + [self.sid hash];
    hash = hash * 31u + [self.title hash];
    hash = hash * 31u + [self.body hash];
    hash = hash * 31u + [self.customData hash];
    hash = hash * 31u + [self.rootParams hash];
    hash = hash * 31u + [self.expirationTime hash];
    hash = hash * 31u + [self.receivedAtTimestamp hash];
    return hash;
}

@end