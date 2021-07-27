//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMSBlocks.h"
#import "EMSConfig.h"
#import "EMSPushNotificationProtocol.h"
#import "EMSInAppProtocol.h"
#import "EMSPredictProtocol.h"
#import "EMSConfigProtocol.h"
#import "EMSGeofenceProtocol.h"
#import "EMSMessageInboxProtocol.h"
#import "EMSOnEventActionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface Emarsys : NSObject

@property(class, nonatomic, readonly) id <EMSPushNotificationProtocol> push;
@property(class, nonatomic, readonly) id <EMSMessageInboxProtocol> messageInbox;
@property(class, nonatomic, readonly) id <EMSInAppProtocol> inApp;
@property(class, nonatomic, readonly) id <EMSGeofenceProtocol> geofence;
@property(class, nonatomic, readonly) id <EMSPredictProtocol> predict;
@property(class, nonatomic, readonly) id <EMSConfigProtocol> config;
@property(class, nonatomic, readonly) id <EMSOnEventActionProtocol> onEventAction;

+ (void)setupWithConfig:(EMSConfig *)config
    NS_SWIFT_NAME(setup(config:));

+ (void)setAuthenticatedContactWithContactFieldId:(NSNumber* )contactFieldId
                                      openIdToken:(NSString *)openIdToken
    NS_SWIFT_NAME(setAuthenticatedContact(contactFieldId:openIdToken:));

+ (void)setAuthenticatedContactWithContactFieldId:(NSNumber *)contactFieldId
                                      openIdToken:(NSString *)openIdToken
                               completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(setAuthenticatedContact(contactFieldId:openIdToken:completionBlock:));

+ (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue
    NS_SWIFT_NAME(setContact(contactFieldId:contactFieldValue:));

+ (void)setContactWithContactFieldId:(NSNumber *)contactFieldId
                   contactFieldValue:(NSString *)contactFieldValue
                     completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(setContact(contactFieldId:contactFieldValue:completionBlock:));

+ (void)clearContact;

+ (void)clearContactWithCompletionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(clearContact(completionBlock:));

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
    NS_SWIFT_NAME(trackCustomEvent(eventName:eventAttributes:));

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(nullable NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(_Nullable EMSCompletionBlock)completionBlock
    NS_SWIFT_NAME(trackCustomEvent(eventName:eventAttributes:completionBlock:));

+ (BOOL)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(_Nullable EMSSourceHandler)sourceHandler
    NS_SWIFT_NAME(trackDeepLink(userActivity:sourceHandler:));

@end

NS_ASSUME_NONNULL_END
