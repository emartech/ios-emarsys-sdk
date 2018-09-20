//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInboxProtocol.h"
#import "MEUserNotificationCenterDelegate.h"
#import "MEInApp.h"

@class EMSConfig;
@protocol MobileEngageStatusDelegate;
@class MERequestContext;
@class EMSRequestManager;

NS_ASSUME_NONNULL_BEGIN

typedef void(^MESourceHandler)(NSString *source);

@interface MobileEngage : NSObject

@property(class, nonatomic, weak, nullable) id <MobileEngageStatusDelegate> statusDelegate;
@property(class, nonatomic, readonly) id<MEInboxProtocol> inbox;
@property(class, nonatomic, readonly) MEInApp *inApp;
@property(class, nonatomic, readonly) id<MEUserNotificationCenterDelegate> notificationCenterDelegate;

+ (void)setupWithConfig:(EMSConfig *)config
          launchOptions:(nullable NSDictionary *)launchOptions;

+ (void)setPushToken:(NSData *)deviceToken;

+ (BOOL)trackDeepLinkWith:(NSUserActivity *)userActivity
            sourceHandler:(nullable MESourceHandler)sourceHandler;

+ (NSString *)appLogin;

+ (NSString *)appLoginWithContactFieldId:(nullable NSNumber *)contactFieldId
                       contactFieldValue:(nullable NSString *)contactFieldValue;

+ (NSString *)trackMessageOpenWithUserInfo:(NSDictionary *)userInfo;

+ (NSString *)trackCustomEvent:(NSString *)eventName
               eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

+ (NSString *)appLogout;

@end

NS_ASSUME_NONNULL_END