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

@interface Emarsys : NSObject

typedef void (^EMSSourceHandler)(NSString *source);

@property(class, nonatomic, readonly) id <EMSPushNotificationProtocol> push;
@property(class, nonatomic, readonly) id <EMSInboxProtocol> inbox;
@property(class, nonatomic, readonly) id <EMSInAppProtocol> inApp;
@property(class, nonatomic, readonly) id <EMSPredictProtocol> predict;

+ (void)setupWithConfig:(EMSConfig *)config;

+ (void)setCustomerWithId:(NSString *)customerId;

+ (void)setCustomerWithId:(NSString *)customerId
          completionBlock:(EMSCompletionBlock)completionBlock;

+ (void)clearCustomer;

+ (void)clearCustomer:(EMSCompletionBlock)completionBlock;

+ (BOOL)trackDeepLinkWithUserActivity:(NSUserActivity *)userActivity
                        sourceHandler:(EMSSourceHandler)sourceHandler;

+ (void)trackCustomEventWithName:(NSString *)eventName
                 eventAttributes:(NSDictionary<NSString *, NSString *> *)eventAttributes
                 completionBlock:(EMSCompletionBlock)completionBlock;

@end