//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import "EMSEndpoint.h"
#import "EMSValueProvider.h"
#import "EMSRemoteConfig.h"
#import "EMSInnerFeature.h"
#import "MEExperimental.h"

@interface EMSEndpoint ()

@property(nonatomic, strong) EMSValueProvider *clientServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *eventServiceUrlProvider;
@property(nonatomic, strong) EMSValueProvider *predictUrlProvider;
@property(nonatomic, strong) EMSValueProvider *deeplinkUrlProvider;
@property(nonatomic, strong) EMSValueProvider *v3MessageInboxUrlProvider;

@end

@implementation EMSEndpoint

- (instancetype)initWithClientServiceUrlProvider:(EMSValueProvider *)clientServiceUrlProvider
                         eventServiceUrlProvider:(EMSValueProvider *)eventServiceUrlProvider
                              predictUrlProvider:(EMSValueProvider *)predictUrlProvider
                             deeplinkUrlProvider:(EMSValueProvider *)deeplinkUrlProvider
                       v3MessageInboxUrlProvider:(EMSValueProvider *)v3MessageInboxUrlProvider {
    NSParameterAssert(clientServiceUrlProvider);
    NSParameterAssert(eventServiceUrlProvider);
    NSParameterAssert(predictUrlProvider);
    NSParameterAssert(deeplinkUrlProvider);
    NSParameterAssert(v3MessageInboxUrlProvider);

    if (self = [super init]) {
        _clientServiceUrlProvider = clientServiceUrlProvider;
        _eventServiceUrlProvider = eventServiceUrlProvider;
        _predictUrlProvider = predictUrlProvider;
        _deeplinkUrlProvider = deeplinkUrlProvider;
        _v3MessageInboxUrlProvider = v3MessageInboxUrlProvider;
    }
    return self;
}

- (NSString *)clientServiceUrl {
    return [self.clientServiceUrlProvider provideValue];
}

- (NSString *)eventServiceUrl {
    return [self.eventServiceUrlProvider provideValue];
}

- (NSString *)v3MessageInboxServiceUrl {
    return [self.v3MessageInboxUrlProvider provideValue];
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
    NSString *url = [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] ?
            @"%@/v4/apps/%@/client/events" : @"%@/v3/apps/%@/client/events";
    return [NSString stringWithFormat:url, self.eventServiceUrl, applicationCode];
}

- (NSString *)inlineInappUrlWithApplicationCode:(NSString *)applicationCode {
    NSString *url = [MEExperimental isFeatureEnabled:EMSInnerFeature.eventServiceV4] ?
            @"%@/v4/apps/%@/inline-messages": @"%@/v3/apps/%@/inline-messages";
    return [NSString stringWithFormat:url, self.eventServiceUrl, applicationCode];
}

- (NSString *)baseUrlWithServiceUrl:(NSString *)serviceUrl
                    applicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/v3/apps/%@/client", serviceUrl, applicationCode];
}

- (NSString *)deeplinkUrl {
    return [self.deeplinkUrlProvider provideValue];
}

- (NSString *)v3MessageInboxUrlApplicationCode:(NSString *)applicationCode{
    return [NSString stringWithFormat:@"%@/v3/apps/%@/inbox", self.v3MessageInboxServiceUrl, applicationCode];
}

- (NSString *)geofenceUrlWithApplicationCode:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"%@/v3/apps/%@/geo-fences", self.clientServiceUrl, applicationCode];
}

- (NSString *)remoteConfigUrl:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"https://mobile-sdk-config.gservice.emarsys.net/%@", applicationCode];
}

- (NSString *)remoteConfigSignatureUrl:(NSString *)applicationCode {
    return [NSString stringWithFormat:@"https://mobile-sdk-config.gservice.emarsys.net/signature/%@", applicationCode];
}

- (void)updateUrlsWithRemoteConfig:(EMSRemoteConfig *)remoteConfig {
    [self.clientServiceUrlProvider updateValue:remoteConfig.clientService];
    [self.eventServiceUrlProvider updateValue:remoteConfig.eventService];
    [self.predictUrlProvider updateValue:remoteConfig.predictService];
    [self.deeplinkUrlProvider updateValue:remoteConfig.deepLinkService];
    [self.v3MessageInboxUrlProvider updateValue:remoteConfig.v3MessageInboxService];
}

- (void)reset {
    [self.clientServiceUrlProvider updateValue:nil];
    [self.eventServiceUrlProvider updateValue:nil];
    [self.predictUrlProvider updateValue:nil];
    [self.deeplinkUrlProvider updateValue:nil];
    [self.v3MessageInboxUrlProvider updateValue:nil];
}

- (BOOL)isMobileEngageUrl:(NSString *)url {
    return ([url hasPrefix:[self clientServiceUrl]] || [url hasPrefix:[self eventServiceUrl]] || [url hasPrefix:self.v3MessageInboxServiceUrl]);
}

- (BOOL)isPushToInAppUrl:(NSString *)url {
    return [url hasPrefix:[self eventServiceUrl]] && [url containsString:@"/messages"];
}

- (BOOL)isCustomEventUrl:(NSString *)url {
    return [url hasPrefix:[self eventServiceUrl]] && [url hasSuffix:@"/events"];
}

- (BOOL)isInlineInAppUrl:(NSString *)url {
    return [url hasPrefix:[self eventServiceUrl]] && [url hasSuffix:@"/inline-messages"];
}

- (NSString *)predictUrl {
    return [self.predictUrlProvider provideValue];
}

@end