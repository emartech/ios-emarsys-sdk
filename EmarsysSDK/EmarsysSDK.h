//
//  Copyright © 2018. Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMAConfig.h"
#import "EMAConstants.h"
#import "EMAPushNotificationProtocol.h"
#import "EMAInboxProtocol.h"
#import "EMAInAppProtocol.h"
#import "EMAPredictProtocol.h"

@interface EmarsysSDK : NSObject

@property(class, nonatomic, readonly) id<EMAPushNotificationProtocol> pushNotification;
@property(class, nonatomic, readonly) id<EMAInboxProtocol> inbox;
@property(class, nonatomic, readonly) id<EMAInAppProtocol> inApp;
@property(class, nonatomic, readonly) id<EMAPredictProtocol> predict;

+ (void)setupWithConfig:(EMAConfig *)config;

+ (void)setCustomerWithCustomerId:(NSString *)customerId
                      resultBlock:(EMAResultBlock)resultBlock;

+ (void)clearCustomerWithResultBlock:(EMAResultBlock)resultBlock;

+ (void)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(EMASourceHandler)sourceHandler
                          resultBlock:(EMAResultBlock)resultBlock;

+ (void)trackCustomEventWithEventName:(NSString *)eventName
                      eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                          resultBlock:(EMAResultBlock)resultBlock;

@end