//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "EMSLogger.h"

@interface EMSRemoteConfig : NSObject

@property(nonatomic, strong) NSString *eventService;
@property(nonatomic, strong) NSString *clientService;
@property(nonatomic, strong) NSString *predictService;
@property(nonatomic, strong) NSString *mobileEngageV2Service;
@property(nonatomic, strong) NSString *deepLinkService;
@property(nonatomic, strong) NSString *inboxService;
@property(nonatomic, strong) NSString *v3MessageInboxService;
@property(nonatomic, assign) LogLevel logLevel;

- (instancetype)initWithEventService:(NSString *)eventService
                       clientService:(NSString *)clientService
                      predictService:(NSString *)predictService
               mobileEngageV2Service:(NSString *)mobileEngageV2Service
                     deepLinkService:(NSString *)deepLinkService
                        inboxService:(NSString *)inboxService
               v3MessageInboxService:(NSString *)v3MessageInboxService
                            logLevel:(LogLevel)logLevel;

@end