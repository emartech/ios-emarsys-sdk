//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEInboxProtocol.h"
#import "MEUserNotificationCenterDelegate.h"
#import "MEInApp.h"

@class MEConfig;
@protocol MobileEngageStatusDelegate;

typedef void(^MESourceHandler)(NSString *source);

NS_ASSUME_NONNULL_BEGIN

@interface MobileEngage : NSObject

@property(class, nonatomic, weak, nullable) id <MobileEngageStatusDelegate> statusDelegate;
@property(class, nonatomic, readonly) id<MEInboxProtocol> inbox;
@property(class, nonatomic, readonly) MEInApp *inApp;
@property(class, nonatomic, readonly) id<MEUserNotificationCenterDelegate> notificationCenterDelegate;

+ (void)setupWithConfig:(MEConfig *)config
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