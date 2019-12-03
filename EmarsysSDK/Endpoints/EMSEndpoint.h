//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@class EMSValueProvider;

@interface EMSEndpoint : NSObject

- (instancetype)initWithClientServiceUrlProvider:(EMSValueProvider *)clientServiceUrlProvider
                         eventServiceUrlProvider:(EMSValueProvider *)eventServiceUrlProvider
                              predictUrlProvider:(EMSValueProvider *)predictUrlProvider;

- (NSString *)clientServiceUrl;

- (NSString *)eventServiceUrl;

- (NSString *)clientUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)pushTokenUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)contactUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)contactTokenUrlWithApplicationCode:(NSString *)applicationCode;

- (NSString *)eventUrlWithApplicationCode:(NSString *)applicationCode;

- (BOOL)isV3url:(NSString *)url;

- (NSString *)predictUrl;

@end