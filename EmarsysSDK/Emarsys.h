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
#import "EMSUserNotificationCenterDelegate.h"

@interface Emarsys : NSObject

@property(class, nonatomic, readonly) id <EMSPushNotificationProtocol> push;
@property(class, nonatomic, readonly) id <EMSInboxProtocol> inbox;
@property(class, nonatomic, readonly) id <EMSInAppProtocol> inApp;
@property(class, nonatomic, readonly) id <EMSPredictProtocol> predict;
@property(class, nonatomic, readonly) id <EMSUserNotificationCenterDelegate> notificationCenterDelegate;

+ (void)setupWithConfig:(EMSConfig *)config;

+ (void)setAnonymousContact;

+ (void)setAnonymousContactWithCompletionBlock:(EMSCompletionBlock)completionBlock;

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue;

+ (void)setContactWithContactFieldValue:(NSString *)contactFieldValue
                        completionBlock:(EMSCompletionBlock)completionBlock;

+ (void)clearContact;

+ (void)clearContactWithCompletionBlock:(EMSCompletionBlock)completionBlock;

+ (BOOL)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(EMSSourceHandler)sourceHandler;

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes;

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock;

@end