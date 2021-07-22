//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogger.h"

@interface EMSRemoteConfig : NSObject

@property(nonatomic, strong) NSString *eventService;
@property(nonatomic, strong) NSString *clientService;
@property(nonatomic, strong) NSString *predictService;
@property(nonatomic, strong) NSString *deepLinkService;
@property(nonatomic, strong) NSString *v3MessageInboxService;
@property(nonatomic, assign) LogLevel logLevel;
@property(nonatomic, strong) NSDictionary *features;

- (instancetype)initWithEventService:(NSString *)eventService
                       clientService:(NSString *)clientService
                      predictService:(NSString *)predictService
                     deepLinkService:(NSString *)deepLinkService
               v3MessageInboxService:(NSString *)v3MessageInboxService
                            logLevel:(LogLevel)logLevel
                            features:(NSDictionary *)features;

@end