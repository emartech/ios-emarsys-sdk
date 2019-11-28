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
                        inboxService:(NSString *)inboxService {
    if (self = [super init]) {
        _eventService = eventService;
        _clientService = clientService;
        _predictService = predictService;
        _mobileEngageV2Service = mobileEngageV2Service;
        _deepLinkService = deepLinkService;
        _inboxService = inboxService;
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
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.eventService hash];
    hash = hash * 31u + [self.clientService hash];
    hash = hash * 31u + [self.predictService hash];
    hash = hash * 31u + [self.mobileEngageV2Service hash];
    hash = hash * 31u + [self.deepLinkService hash];
    hash = hash * 31u + [self.inboxService hash];
    return hash;
}

@end