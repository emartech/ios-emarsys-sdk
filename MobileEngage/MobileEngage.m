//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import "MobileEngage.h"
#import "EMSConfig.h"
#import "MobileEngageInternal.h"
#import "MEInboxNotificationProtocol.h"
#import "EMSSQLiteHelper.h"
#import "MESchemaDelegate.h"
#import "MENotificationCenterManager.h"
#import "MEInApp+Private.h"
#import "MERequestModelRepositoryFactory.h"
#import "MEInboxV2.h"
#import "EMSShardRepository.h"
#import "MEUserNotificationDelegate.h"

#define DB_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MEDB.db"]

@implementation MobileEngage

static MobileEngageInternal *_mobileEngageInternal;
static id <MEInboxNotificationProtocol> _inbox;
static MEInApp *_iam;
static id <MEUserNotificationCenterDelegate> _notification;
static EMSSQLiteHelper *_dbHelper;


+ (void)setupWithMobileEngageInternal:(MobileEngageInternal *)mobileEngageInternal
                               config:(EMSConfig *)config
                        launchOptions:(NSDictionary *)launchOptions {

    _dbHelper = [[EMSSQLiteHelper alloc] initWithDatabasePath:DB_PATH
                                               schemaDelegate:[MESchemaDelegate new]];
    [_dbHelper open];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [_dbHelper close];
                                                  }];

    _mobileEngageInternal = mobileEngageInternal;

    MERequestContext *requestContext = [[MERequestContext alloc] initWithConfig:config];


    MELogRepository *logRepository = [MELogRepository new];

    _iam = [MEInApp new];
    _iam.logRepository = logRepository;
    _iam.timestampProvider = [EMSTimestampProvider new];

    _mobileEngageInternal.notificationCenterManager = [MENotificationCenterManager new];


    [_mobileEngageInternal setupWithConfig:config
                             launchOptions:launchOptions
                  requestRepositoryFactory:[[MERequestModelRepositoryFactory alloc] initWithInApp:_iam
                                                                                   requestContext:requestContext]
                           shardRepository:[[EMSShardRepository alloc] initWithDbHelper:_dbHelper]
                             logRepository:logRepository
                            requestContext:requestContext];

    _iam.inAppTracker = _mobileEngageInternal;

    _notification = [[MEUserNotificationDelegate alloc] initWithApplication:[UIApplication sharedApplication]
                                                       mobileEngageInternal:_mobileEngageInternal
                                                                      inApp:_iam];
}

+ (void)setupWithConfig:(EMSConfig *)config
          launchOptions:(NSDictionary *)launchOptions {
    [MobileEngage setupWithMobileEngageInternal:[MobileEngageInternal new]
                                         config:config
                                  launchOptions:launchOptions];
}

+ (void)setPushToken:(NSData *)deviceToken {
    [_mobileEngageInternal setPushToken:deviceToken];
}

+ (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler {
    return [_mobileEngageInternal trackDeepLinkWith:userActivity
                                      sourceHandler:sourceHandler];
}

+ (NSString *)appLogin {
    return [_mobileEngageInternal appLogin];
}

+ (NSString *)appLoginWithContactFieldId:(NSNumber *)contactFieldId
                       contactFieldValue:(NSString *)contactFieldValue {
    return [_mobileEngageInternal appLoginWithContactFieldValue:contactFieldValue];
}

+ (NSString *)appLogout {
    return [_mobileEngageInternal appLogout];
}

+ (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo {
    NSNumber *inbox = userInfo[@"inbox"];
    if (inbox && [inbox boolValue]) {
        EMSNotification *notification = [[EMSNotification alloc] initWithUserInfo:userInfo];
        [_inbox addNotification:notification];

    }
    [_mobileEngageInternal trackMessageOpenWithUserInfo:userInfo];
    return nil;
}

+ (NSString *)trackCustomEvent:(NSString *)eventName
               eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes {
    return [_mobileEngageInternal trackCustomEvent:eventName
                                   eventAttributes:eventAttributes];
}

+ (void)setStatusDelegate:(id <MobileEngageStatusDelegate>)statusDelegate {
    [_mobileEngageInternal setStatusDelegate:statusDelegate];
}

+ (id <MobileEngageStatusDelegate>)statusDelegate {
    return [_mobileEngageInternal statusDelegate];
}

+ (id <MEInboxProtocol>)inbox {
    return _inbox;
}

+ (MEInApp *)inApp {
    return _iam;
}

+ (void)setInApp:(MEInApp *)inApp {
    _iam = inApp;
}

+ (id <MEUserNotificationCenterDelegate>)notificationCenterDelegate {
    return _notification;
}

+ (EMSSQLiteHelper *)dbHelper {
    return _dbHelper;
}

+ (void)setDbHelper:(EMSSQLiteHelper *)dbHelper {
    _dbHelper = dbHelper;
}

@end
