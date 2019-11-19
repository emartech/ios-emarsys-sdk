//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSBlocks.h>
#import <EmarsysSDK/EMSConfig.h>
#import <EmarsysSDK/EMSPushNotificationProtocol.h>
#import <EmarsysSDK/EMSInboxProtocol.h>
#import <EmarsysSDK/EMSInAppProtocol.h>
#import <EmarsysSDK/EMSPredictProtocol.h>
#import <EmarsysSDK/EMSConfigProtocol.h>
#import <EmarsysSDK/EMSUserNotificationCenterDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface Emarsys : NSObject

@property(class, nonatomic, readonly) id <EMSPushNotificationProtocol> push;
@property(class, nonatomic, readonly) id <EMSInboxProtocol> inbox;
@property(class, nonatomic, readonly) id <EMSInAppProtocol> inApp;
@property(class, nonatomic, readonly) id <EMSUserNotificationCenterDelegate> notificationCenterDelegate;
@property(class, nonatomic, readonly) id <EMSPredictProtocol> predict;
@property(class, nonatomic, readonly) id <EMSConfigProtocol> config;

+ (void)setupWithConfig:(EMSConfig *)config;

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue;

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

+ (void)clearContact;

+ (void)clearContactWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock;

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes;

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(_Nullable EMSCompletionBlock)completionBlock;

+ (BOOL)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(_Nullable EMSSourceHandler)sourceHandler;

@end

NS_ASSUME_NONNULL_END
