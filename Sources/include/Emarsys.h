//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"
#import "EMSConfig.h"
#import "EMSPushNotificationProtocol.h"
#import "EMSInboxProtocol.h"
#import "EMSInAppProtocol.h"
#import "EMSPredictProtocol.h"
#import "EMSConfigProtocol.h"
#import "EMSUserNotificationCenterDelegate.h"

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
