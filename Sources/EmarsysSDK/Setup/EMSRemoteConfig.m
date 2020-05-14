//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSRemoteConfig.h"

@implementation EMSRemoteConfig

- (instancetype)initWithEventService:(NSString *)eventService
                       clientService:(NSString *)clientService
                      predictService:(NSString *)predictService
               mobileEngageV2Service:(NSString *)mobileEngageV2Service
                     deepLinkService:(NSString *)deepLinkService
                        inboxService:(NSString *)inboxService
               v3MessageInboxService:(NSString *)v3MessageInboxService
                            logLevel:(LogLevel)logLevel {
    if (self = [super init]) {
        _eventService = eventService;
        _clientService = clientService;
        _predictService = predictService;
        _mobileEngageV2Service = mobileEngageV2Service;
        _deepLinkService = deepLinkService;
        _inboxService = inboxService;
        _v3MessageInboxService = v3MessageInboxService;
        _logLevel = logLevel;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToConfig:other];
}

- (BOOL)isEqualToConfig:(EMSRemoteConfig *)config {
    if (self == config)
        return YES;
    if (config == nil)
        return NO;
    if (self.eventService != config.eventService && ![self.eventService isEqualToString:config.eventService])
        return NO;
    if (self.clientService != config.clientService && ![self.clientService isEqualToString:config.clientService])
        return NO;
    if (self.predictService != config.predictService && ![self.predictService isEqualToString:config.predictService])
        return NO;
    if (self.mobileEngageV2Service != config.mobileEngageV2Service && ![self.mobileEngageV2Service isEqualToString:config.mobileEngageV2Service])
        return NO;
    if (self.deepLinkService != config.deepLinkService && ![self.deepLinkService isEqualToString:config.deepLinkService])
        return NO;
    if (self.inboxService != config.inboxService && ![self.inboxService isEqualToString:config.inboxService])
        return NO;
    if (self.v3MessageInboxService != config.v3MessageInboxService && ![self.v3MessageInboxService isEqualToString:config.v3MessageInboxService])
        return NO;
    if (self.logLevel != config.logLevel)
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.eventService hash];
    hash = hash * 31u + [self.clientService hash];
    hash = hash * 31u + [self.predictService hash];
    hash = hash * 31u + [self.mobileEngageV2Service hash];
    hash = hash * 31u + [self.deepLinkService hash];
    hash = hash * 31u + [self.inboxService hash];
    hash = hash * 31u + [self.v3MessageInboxService hash];
    hash = hash * 31u + (NSUInteger) self.logLevel;
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ",
                                                                     NSStringFromClass([self class])];
    [description appendFormat:@"self.eventService=%@",
                              self.eventService];
    [description appendFormat:@", self.clientService=%@",
                              self.clientService];
    [description appendFormat:@", self.predictService=%@",
                              self.predictService];
    [description appendFormat:@", self.mobileEngageV2Service=%@",
                              self.mobileEngageV2Service];
    [description appendFormat:@", self.deepLinkService=%@",
                              self.deepLinkService];
    [description appendFormat:@", self.inboxService=%@",
                              self.inboxService];
    [description appendFormat:@", self.v3MessageInboxService=%@",
                              self.v3MessageInboxService];
    [description appendFormat:@", self.logLevel=%d",
                              self.logLevel];
    [description appendString:@">"];
    return description;
}

@end