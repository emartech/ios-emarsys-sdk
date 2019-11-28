//
// Copyright (c) 2019 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EMSRemoteConfig : NSObject

@property(nonatomic, strong) NSString *eventService;
@property(nonatomic, strong) NSString *clientService;
@property(nonatomic, strong) NSString *predictService;
@property(nonatomic, strong) NSString *mobileEngageV2Service;
@property(nonatomic, strong) NSString *deepLinkService;
@property(nonatomic, strong) NSString *inboxService;

- (instancetype)initWithEventService:(NSString *)eventService
                       clientService:(NSString *)clientService
                      predictService:(NSString *)predictService
               mobileEngageV2Service:(NSString *)mobileEngageV2Service
                     deepLinkService:(NSString *)deepLinkService
                        inboxService:(NSString *)inboxService;

@end