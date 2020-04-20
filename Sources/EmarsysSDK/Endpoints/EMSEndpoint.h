//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSValueProvider;
@class EMSRemoteConfig;

@interface EMSEndpoint : NSObject

- (instancetype)initWithClientServiceUrlProvider:(EMSValueProvider *)clientServiceUrlProvider
                         eventServiceUrlProvider:(EMSValueProvider *)eventServiceUrlProvider
                              predictUrlProvider:(EMSValueProvider *)predictUrlProvider
                             deeplinkUrlProvider:(EMSValueProvider *)deeplinkUrlProvider
                       v2EventServiceUrlProvider:(EMSValueProvider *)v2EventServiceUrlProvider
                                inboxUrlProvider:(EMSValueProvider *)inboxUrlProvider
                       v3MessageInboxUrlProvider:(EMSValueProvider *)v3MessageInboxUrlProvider;

- (NSString *)clientServiceUrl;

- (NSString *)eventServiceUrl;

- (NSString *)clientUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)pushTokenUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)contactUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)contactTokenUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)eventUrlWithApplicationCode:(NSString *)applicationCode;

- (BOOL)isV3url:(NSString *)url;

- (NSString *)predictUrl;

- (NSString *)deeplinkUrl;

- (NSString *)v2EventServiceUrl;

- (NSString *)inboxUrl;

- (NSString *)v3MessageInboxUrlApplicationCode:(NSString *)applicationCode;

- (NSString *)geofenceUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)remoteConfigUrl:(NSString *)applicationCode;

- (NSString *)remoteConfigSignatureUrl:(NSString *)applicationCode;

- (void)updateUrlsWithRemoteConfig:(EMSRemoteConfig *)remoteConfig;

- (void)reset;

@end