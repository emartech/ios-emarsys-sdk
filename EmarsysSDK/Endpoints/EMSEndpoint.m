//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"

@interface EMSEndpoint ()

@property(nonatomic, strong) EMSValueProvider *clientServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *eventServiceUrlProvider;

@end

@implementation EMSEndpoint

- (instancetype)initWithClientServiceUrlProvider:(EMSValueProvider *)clientServiceUrlProvider
                         eventServiceUrlProvider:(EMSValueProvider *)eventServiceUrlProvider {
    NSParameterAssert(clientServiceUrlProvider);
    NSParameterAssert(eventServiceUrlProvider);

    if (self = [super init]) {
        _clientServiceUrlProvider = clientServiceUrlProvider;
        _eventServiceUrlProvider = eventServiceUrlProvider;
    }
    return self;
}

- (NSString *)clientServiceUrl {
    return [self.clientServiceUrlProvider provideValue];
}

- (NSString *)eventServiceUrl {
    return [self.eventServiceUrlProvider provideValue];
}

- (NSString *)clientUrlWithApplicationCode:(NSString *)applicationCode {
    return [self baseUrlWithServiceUrl:[self clientServiceUrl]
                       applicationCode:applicationCode];
}

- (NSString *)pushTokenUrlWithApplicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/push-token", [self clientUrlWithApplicationCode:applicationCode]];
}

- (NSString *)contactUrlWithApplicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/contact", [self clientUrlWithApplicationCode:applicationCode]];
}

- (NSString *)contactTokenUrlWithApplicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/contact-token", [self clientUrlWithApplicationCode:applicationCode]];
}

- (NSString *)eventUrlWithApplicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/v3/apps/%@/client/events", self.eventServiceUrl, applicationCode];
}

- (NSString *)baseUrlWithServiceUrl:(NSString *)serviceUrl
                    applicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/v3/apps/%@/client", serviceUrl, applicationCode];
}

@end